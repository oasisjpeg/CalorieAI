import 'package:equatable/equatable.dart';
import 'package:opennutritracker/features/recipe_chatbot/domain/recipe_entity.dart';

abstract class RecipeChatbotState extends Equatable {
  const RecipeChatbotState();

  @override
  List<Object> get props => [];
}

class RecipeChatbotInitial extends RecipeChatbotState {
  const RecipeChatbotInitial();
}

class RecipeChatbotLoading extends RecipeChatbotState {
  const RecipeChatbotLoading();
}

class RecipeChatbotLoaded extends RecipeChatbotState {
  final List<RecipeEntity> recipes;
  const RecipeChatbotLoaded(this.recipes);
    @override
  List<Object> get props => [recipes];
}

class RecipeChatbotError extends RecipeChatbotState {
  final String message;
  const RecipeChatbotError(this.message);
  @override
  List<Object> get props => [message];
}