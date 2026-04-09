import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:calorieai/core/data/repository/intake_repository.dart';
import 'package:calorieai/core/data/repository/tracked_day_repository.dart';
import 'package:calorieai/core/data/repository/user_activity_repository.dart';
import 'package:calorieai/core/data/repository/water_repository.dart';
import 'package:calorieai/core/data/repository/weight_repository.dart';

class ExportDataUsecase {
  final UserActivityRepository _userActivityRepository;
  final IntakeRepository _intakeRepository;
  final TrackedDayRepository _trackedDayRepository;
  final WaterRepository _waterRepository;
  final WeightRepository _weightRepository;

  ExportDataUsecase(
      this._userActivityRepository,
      this._intakeRepository,
      this._trackedDayRepository,
      this._waterRepository,
      this._weightRepository);

  /// Exports user activity, intake, tracked day, water, and weight data to a zip of json
  /// files at a user specified location.
  Future<bool> exportData(
      String exportZipFileName,
      String userActivityJsonFileName,
      String userIntakeJsonFileName,
      String trackedDayJsonFileName,
      String waterJsonFileName,
      String weightJsonFileName) async {
    // Export user activity data to Json File Bytes
    final fullUserActivity =
        await _userActivityRepository.getAllUserActivityDBO();
    final fullUserActivityJson = jsonEncode(
        fullUserActivity.map((activity) => activity.toJson()).toList());
    final userActivityJsonBytes = utf8.encode(fullUserActivityJson);

    // Export intake data to Json File Bytes
    final fullIntake = await _intakeRepository.getAllIntakesDBO();
    final fullIntakeJson =
        jsonEncode(fullIntake.map((intake) => intake.toJson()).toList());
    final intakeJsonBytes = utf8.encode(fullIntakeJson);

    // Export tracked day data to Json File Bytes
    final fullTrackedDay = await _trackedDayRepository.getAllTrackedDaysDBO();
    final fullTrackedDayJson = jsonEncode(
        fullTrackedDay.map((trackedDay) => trackedDay.toJson()).toList());
    final trackedDayJsonBytes = utf8.encode(fullTrackedDayJson);

    // Export water data to Json File Bytes
    final fullWater = await _waterRepository.getAllWaterEntriesDBO();
    final fullWaterJson =
        jsonEncode(fullWater.map((water) => water.toJson()).toList());
    final waterJsonBytes = utf8.encode(fullWaterJson);

    // Export weight data to Json File Bytes
    final fullWeight = await _weightRepository.getAllWeightEntriesDBO();
    final fullWeightJson =
        jsonEncode(fullWeight.map((weight) => weight.toJson()).toList());
    final weightJsonBytes = utf8.encode(fullWeightJson);

    // Create a zip file with the exported data
    final archive = Archive();
    archive.addFile(
      ArchiveFile(userActivityJsonFileName, userActivityJsonBytes.length,
          userActivityJsonBytes),
    );
    archive.addFile(
      ArchiveFile(
          userIntakeJsonFileName, intakeJsonBytes.length, intakeJsonBytes),
    );
    archive.addFile(
      ArchiveFile(trackedDayJsonFileName, trackedDayJsonBytes.length,
          trackedDayJsonBytes),
    );
    archive.addFile(
      ArchiveFile(waterJsonFileName, waterJsonBytes.length, waterJsonBytes),
    );
    archive.addFile(
      ArchiveFile(weightJsonFileName, weightJsonBytes.length, weightJsonBytes),
    );

    // Save the zip file to the user specified location
    final zipBytes = ZipEncoder().encode(archive);
    final result = await FilePicker.platform.saveFile(
      fileName: exportZipFileName,
      type: FileType.custom,
      allowedExtensions: ['zip'],
      bytes: Uint8List.fromList(zipBytes),
    );

    return result != null && result.isNotEmpty;
  }
}
