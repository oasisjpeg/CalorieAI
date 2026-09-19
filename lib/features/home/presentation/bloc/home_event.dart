part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadItemsEvent extends HomeEvent {
  const LoadItemsEvent();
}

class RefreshStepsEvent extends HomeEvent {
  const RefreshStepsEvent();
}
