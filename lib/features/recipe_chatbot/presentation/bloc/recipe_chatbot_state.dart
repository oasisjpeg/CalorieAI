import 'package:equatable/equatable.dart';

class RecipeChatbotState extends Equatable {
  final Map<String, dynamic>? selectedRecipe;

  const RecipeChatbotState({this.selectedRecipe});

  @override
  List<Object?> get props => [selectedRecipe];
}

class RecipeChatbotInitial extends RecipeChatbotState {}

class RecipeChatbotLoading extends RecipeChatbotState {
  final List<Map<String, dynamic>>? existingRecipes;
  final bool isLoadingMore;

  const RecipeChatbotLoading({
    this.existingRecipes,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [existingRecipes, isLoadingMore];
}

class RecipeChatbotSuccess extends RecipeChatbotState {
  final List<Map<String, dynamic>> recipes;
  final Set<String> savedRecipeIds;

  const RecipeChatbotSuccess({
    required this.recipes,
    this.savedRecipeIds = const {},
    Map<String, dynamic>? selectedRecipe,
  }) : super(selectedRecipe: selectedRecipe);

  @override
  List<Object?> get props => [recipes, savedRecipeIds, selectedRecipe];

  RecipeChatbotSuccess copyWith({
    List<Map<String, dynamic>>? recipes,
    Set<String>? savedRecipeIds,
    Map<String, dynamic>? selectedRecipe,
  }) {
    return RecipeChatbotSuccess(
      recipes: recipes ?? this.recipes,
      savedRecipeIds: savedRecipeIds ?? this.savedRecipeIds,
      selectedRecipe: selectedRecipe ?? this.selectedRecipe,
    );
  }
}

class RecipeChatbotError extends RecipeChatbotState {
  final String message;

  const RecipeChatbotError({required this.message});

  @override
  List<Object?> get props => [message];
}
