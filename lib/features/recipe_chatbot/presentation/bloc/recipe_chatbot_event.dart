import 'package:equatable/equatable.dart';

abstract class RecipeChatbotEvent extends Equatable {
  const RecipeChatbotEvent();

  @override
  List<Object> get props => [];
}

class RecipeChatbotLoad extends RecipeChatbotEvent {}

class RecipeChatbotUpdateParameter extends RecipeChatbotEvent {
  final String key;
  final String value;

  const RecipeChatbotUpdateParameter({required this.key, required this.value});

  @override
  List<Object> get props => [key, value];
}

class RecipeChatbotClear extends RecipeChatbotEvent {}