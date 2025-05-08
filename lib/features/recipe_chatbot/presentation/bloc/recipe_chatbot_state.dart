import 'package:equatable/equatable.dart';

class RecipeChatbotState extends Equatable {
  final Map<String, dynamic>? selectedRecipe;

  const RecipeChatbotState({this.selectedRecipe});

  @override
  List<Object?> get props => [selectedRecipe];
}

class RecipeChatbotInitial extends RecipeChatbotState {}

class RecipeChatbotLoading extends RecipeChatbotState {}

class RecipeChatbotSuccess extends RecipeChatbotState {
  final List<Map<String, dynamic>> recipes;

  const RecipeChatbotSuccess({
    required this.recipes,
    Map<String, dynamic>? selectedRecipe,
  }) : super(selectedRecipe: selectedRecipe);

  @override
  List<Object?> get props => [recipes, selectedRecipe];
}

class RecipeChatbotError extends RecipeChatbotState {
  final String message;

  const RecipeChatbotError({required this.message});

  @override
  List<Object?> get props => [message];
}
