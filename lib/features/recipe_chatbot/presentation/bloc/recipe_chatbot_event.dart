import 'package:equatable/equatable.dart';

class RecipeChatbotEvent extends Equatable {
  const RecipeChatbotEvent();

  @override
  List<Object?> get props => [];
}

class FetchRecipes extends RecipeChatbotEvent {
  final Map<String, dynamic> filters;

  const FetchRecipes(this.filters);

  @override
  List<Object?> get props => [filters];
}

class RecipeSelected extends RecipeChatbotEvent {
  final Map<String, dynamic> recipe;

  const RecipeSelected(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class RecipeUnselected extends RecipeChatbotEvent {
  const RecipeUnselected();

  @override
  List<Object?> get props => [];
}
