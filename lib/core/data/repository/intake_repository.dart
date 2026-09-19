import 'package:calorieai/core/data/data_source/intake_data_source.dart';
import 'package:calorieai/core/data/dbo/intake_dbo.dart';
import 'package:calorieai/core/data/dbo/intake_type_dbo.dart';
import 'package:calorieai/core/domain/entity/intake_entity.dart';
import 'package:calorieai/core/domain/entity/intake_type_entity.dart';
import 'package:calorieai/core/services/apple_health_service.dart';
import 'package:calorieai/core/services/synology_health_service.dart';
import 'package:calorieai/core/data/repository/config_repository.dart';

class IntakeRepository {
  final IntakeDataSource _intakeDataSource;
  final ConfigRepository? _configRepository;
  final SynologyHealthService? _synologyHealthService;

  IntakeRepository(this._intakeDataSource, [this._configRepository, this._synologyHealthService]);

  Future<void> addIntake(IntakeEntity intakeEntity) async {
    final intakeDBO = IntakeDBO.fromIntakeEntity(intakeEntity);

    await _intakeDataSource.addIntake(intakeDBO);

    // Sync to Apple Health if enabled
    if (_configRepository != null) {
      final appleHealthSyncEnabled = await _configRepository!.getAppleHealthSyncEnabled();
      if (appleHealthSyncEnabled) {
        final appleHealthService = AppleHealthService();
        await appleHealthService.syncIntake(intakeEntity);
      }
    }

    // Sync to Synology Health Service if enabled
    if (_configRepository != null && _synologyHealthService != null) {
      final synologyHealthSyncEnabled = await _configRepository!.getSynologyHealthSyncEnabled();
      if (synologyHealthSyncEnabled) {
        await _synologyHealthService!.syncIntake(intakeEntity);
      }
    }
  }

  Future<void> addAllIntakeDBOs(List<IntakeDBO> intakeDBOs) async {
    await _intakeDataSource.addAllIntakes(intakeDBOs);
  }

  Future<void> deleteIntake(IntakeEntity intakeEntity) async {
    await _intakeDataSource.deleteIntakeFromId(intakeEntity.id);
  }

  Future<IntakeEntity?> updateIntake(
      String intakeId, Map<String, dynamic> fields) async {
    var result = await _intakeDataSource.updateIntake(intakeId, fields);
    return result == null ? null : IntakeEntity.fromIntakeDBO(result);
  }

  Future<List<IntakeDBO>> getAllIntakesDBO() async {
    return await _intakeDataSource.getAllIntakes();
  }

  Future<List<IntakeEntity>> getAllIntakes() async {
    final intakeDBOList = await _intakeDataSource.getAllIntakes();
    return intakeDBOList
        .map((intakeDBO) => IntakeEntity.fromIntakeDBO(intakeDBO))
        .toList();
  }

  Future<List<IntakeEntity>> getIntakeByDateAndType(
      IntakeTypeEntity intakeType, DateTime date) async {
    final intakeDBOList = await _intakeDataSource.getAllIntakesByDate(
        IntakeTypeDBO.fromIntakeTypeEntity(intakeType), date);

    return intakeDBOList
        .map((intakeDBO) => IntakeEntity.fromIntakeDBO(intakeDBO))
        .toList();
  }

  Future<List<IntakeEntity>> getAllIntakesForDate(DateTime date) async {
    final intakeDBOList = await _intakeDataSource.getAllIntakesForDate(date);
    return intakeDBOList
        .map((intakeDBO) => IntakeEntity.fromIntakeDBO(intakeDBO))
        .toList();
  }

  Future<List<IntakeEntity>> getRecentIntake() async {
    final intakeList = await _intakeDataSource.getRecentlyAddedIntake();

    return intakeList
        .map((intakeDBO) => IntakeEntity.fromIntakeDBO(intakeDBO))
        .toList();
  }

  Future<IntakeEntity?> getIntakeById(String intakeId) async {
    final result = await _intakeDataSource.getIntakeById(intakeId);
    return result == null ? null : IntakeEntity.fromIntakeDBO(result);
  }
}
