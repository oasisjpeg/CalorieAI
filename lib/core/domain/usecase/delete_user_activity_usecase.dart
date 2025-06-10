import 'package:calorieai/core/data/repository/user_activity_repository.dart';
import 'package:calorieai/core/domain/entity/user_activity_entity.dart';

class DeleteUserActivityUsecase {
  final UserActivityRepository _userActivityRepository;

  DeleteUserActivityUsecase(this._userActivityRepository);

  Future<void> deleteUserActivity(UserActivityEntity activityEntity) async {
    await _userActivityRepository.deleteUserActivity(activityEntity);
  }
}
