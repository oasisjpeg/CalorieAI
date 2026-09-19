import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import 'package:calorieai/core/data/data_source/config_data_source.dart';
import 'package:calorieai/core/data/dbo/pending_health_sync_dbo.dart';
import 'package:calorieai/core/domain/entity/intake_entity.dart';
import 'package:calorieai/core/domain/entity/intake_type_entity.dart';
import 'package:calorieai/core/utils/env_loader.dart';

class _SendResult {
  final bool success;
  final int successCount;

  const _SendResult(this.success, this.successCount);
}

class SynologyHealthService {
  static final _log = Logger('SynologyHealthService');
  static final SynologyHealthService _instance = SynologyHealthService._internal();

  factory SynologyHealthService() => _instance;
  SynologyHealthService._internal();

  ConfigDataSource? _configDataSource;
  Box<PendingHealthSyncDBO>? _pendingBox;
  String? _cachedUrl;
  String? _cachedSecret;
  bool _envLoaded = false;
  bool _serverReachable = true;

  void init(ConfigDataSource configDataSource, Box<PendingHealthSyncDBO> pendingBox) {
    _configDataSource = configDataSource;
    _pendingBox = pendingBox;
  }

  Future<void> _ensureEnv() async {
    if (_envLoaded) return;
    _cachedUrl = await EnvLoader.get('SYNOLOGY_HEALTH_URL');
    _cachedSecret = await EnvLoader.get('HEALTH_SECRET');
    _envLoaded = true;
    _log.info('Synology env loaded: url=$_cachedUrl');
  }

  bool get _isConfigured => _cachedUrl != null && _cachedUrl!.isNotEmpty && _cachedSecret != null && _cachedSecret!.isNotEmpty;

  bool get isServerReachable => _serverReachable;

  String _mealTypeString(IntakeTypeEntity type) {
    return switch (type) {
      IntakeTypeEntity.breakfast => 'breakfast',
      IntakeTypeEntity.lunch => 'lunch',
      IntakeTypeEntity.dinner => 'dinner',
      IntakeTypeEntity.snack => 'snack',
    };
  }

  Map<String, dynamic> _buildNutritionPayload(IntakeEntity intake) {
    return {
      "type": "nutrition",
      "payload": {
        "meal_type": _mealTypeString(intake.type),
        "name": intake.meal.name ?? 'Meal',
        "date": "${intake.dateTime.year.toString().padLeft(4, '0')}-${intake.dateTime.month.toString().padLeft(2, '0')}-${intake.dateTime.day.toString().padLeft(2, '0')}",
        "timestamp": intake.dateTime.toUtc().toIso8601String(),
        "calories": intake.totalKcal,
        "fat_g": intake.totalFatsGram,
        "carbs_g": intake.totalCarbsGram,
        "protein_g": intake.totalProteinsGram,
        "sugar_g": intake.totalSugarsGram,
        "saturated_fat_g": intake.totalSaturatedFatGram,
        "fiber_g": intake.totalFiberGram,
      }
    };
  }

  Future<bool> _sendPayload(Map<String, dynamic> payload) async {
    final result = await _sendRawPayload(jsonEncode(payload));
    return result.success;
  }

  Future<_SendResult> _sendRawPayload(String body) async {
    await _ensureEnv();
    if (!_isConfigured) {
      _log.warning('Synology Health Service not configured. Set SYNOLOGY_HEALTH_URL and HEALTH_SECRET in .env');
      return const _SendResult(false, 0);
    }

    try {
      final response = await http.post(
        Uri.parse(_cachedUrl!),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_cachedSecret!}',
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      final status = response.statusCode;
      if (status == 200) {
        _serverReachable = true;
        _log.fine('Successfully sent health payload to Synology');
        return const _SendResult(true, 1);
      } else if (status == 207) {
        // Partial success: check how many entries failed
        try {
          final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
          final failed = jsonBody['failed'] as int? ?? 0;
          final success = jsonBody['success'] as int? ?? 0;
          if (failed > 0) {
            _serverReachable = true;
            _log.warning('Synology partial success: $success ok, $failed failed: $jsonBody');
            return _SendResult(true, success);
          }
          _serverReachable = true;
          _log.fine('Synology partial success: all entries accepted');
          return _SendResult(true, success);
        } catch (_) {
          _serverReachable = true;
          _log.warning('Synology returned 207 with unparseable body: ${response.body}');
          return const _SendResult(false, 0);
        }
      } else if (status == 502) {
        _serverReachable = false;
        _log.warning('Synology server unreachable (502). Skipping future syncs until recovered.');
        return const _SendResult(false, 0);
      } else {
        _log.warning('Synology Health Service returned ${response.statusCode}: ${response.body}');
        return const _SendResult(false, 0);
      }
    } on SocketException catch (e) {
      _serverReachable = false;
      _log.warning('Synology Health Service unreachable: $e');
      return const _SendResult(false, 0);
    } on Exception catch (e) {
      _log.warning('Error sending to Synology Health Service: $e');
      return const _SendResult(false, 0);
    }
  }

  /// Sends a batch of payloads in a single request.
  /// Returns the number of items the server reported as successful.
  Future<int> _sendBatch(List<Map<String, dynamic>> payloads) async {
    if (payloads.isEmpty) return 0;
    final result = await _sendRawPayload(jsonEncode(payloads));
    return result.successCount;
  }

  /// Send a single intake to the Synology health service.
  /// If it fails, the payload is queued for retry.
  Future<bool> syncIntake(IntakeEntity intake) async {
    if (_pendingBox == null) {
      _log.warning('SynologyHealthService not initialized. Call init() first.');
      return false;
    }

    final payload = _buildNutritionPayload(intake);

    if (_serverReachable) {
      final success = await _sendPayload(payload);
      if (success) return true;
    } else {
      _log.info('Server marked unreachable, skipping HTTP call for intake ${intake.id}');
    }

    await _queuePayload(payload);
    _log.info('Queued intake sync for retry: ${intake.id}');
    return false;
  }

  /// Sync all historic intakes. Should be called once when the user first enables Synology sync.
  /// Sends payloads in batches of 50 for much faster sync.
  Future<int> syncHistoricIntakes(List<IntakeEntity> allIntakes) async {
    if (_configDataSource == null || _pendingBox == null) {
      _log.warning('SynologyHealthService not initialized. Call init() first.');
      return 0;
    }

    _log.info('Starting historic sync of ${allIntakes.length} intakes to Synology (batched)');
    int successCount = 0;
    int failCount = 0;

    const batchSize = 50;
    final payloads = allIntakes.map(_buildNutritionPayload).toList();

    for (var i = 0; i < payloads.length; i += batchSize) {
      final end = math.min(i + batchSize, payloads.length);
      final batch = payloads.sublist(i, end);

      final batchSuccess = await _sendBatch(batch);
      successCount += batchSuccess;
      failCount += batch.length - batchSuccess;

      if (!_serverReachable) {
        _log.info('Server unreachable, queuing remaining ${payloads.length - i - batch.length} items');
        for (var j = end; j < payloads.length; j++) {
          await _queuePayload(payloads[j]);
          failCount++;
        }
        break;
      }

      // Small delay between batches to avoid flooding
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _log.info('Historic sync complete: $successCount succeeded, $failCount queued for retry');

    // Mark historic sync as completed
    await _configDataSource!.setSynologyHealthHistoricSyncedAt(DateTime.now());

    return successCount;
  }

  /// Retry all queued pending payloads.
  Future<int> retryPending() async {
    if (_pendingBox == null) return 0;

    final pending = _pendingBox!.values.toList();
    if (pending.isEmpty) return 0;

    _log.info('Retrying ${pending.length} pending health sync items');
    int successCount = 0;

    for (final item in pending) {
      if (item.retryCount >= 5) {
        _log.warning('Dropping pending sync item ${item.id} after 5 retries');
        await item.delete();
        continue;
      }

      try {
        final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
        final success = await _sendPayload(payload);
        if (success) {
          await item.delete();
          successCount++;
        } else {
          item.retryCount++;
          await item.save();
          if (!_serverReachable) {
            _log.info('Server became unreachable during retry, pausing queue');
            break;
          }
        }
      } catch (e) {
        _log.warning('Error retrying pending sync item ${item.id}: $e');
        item.retryCount++;
        await item.save();
      }
    }

    _log.info('Retry complete: $successCount/${pending.length} items sent');
    return successCount;
  }

  Future<void> _queuePayload(Map<String, dynamic> payload) async {
    final item = PendingHealthSyncDBO(
      id: const Uuid().v4(),
      payloadJson: jsonEncode(payload),
      createdAt: DateTime.now(),
      retryCount: 0,
    );
    await _pendingBox!.add(item);
  }
}
