import 'package:flutter/material.dart';
import 'package:calorieai/core/utils/locator.dart';
import 'package:calorieai/core/data/datasource/local/saved_recipe_local_data_source.dart';
import 'package:calorieai/features/recipe_chatbot/presentation/bloc/recipe_chatbot_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calorieai/features/recipe_chatbot/presentation/bloc/recipe_chatbot_event.dart';
import 'package:calorieai/features/recipe_chatbot/presentation/bloc/recipe_chatbot_state.dart';
import 'package:calorieai/features/recipe_chatbot/presentation/saved_recipes_screen.dart';
import 'package:calorieai/core/services/gemini_service.dart';
import 'package:calorieai/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_intake_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:calorieai/l10n/app_localizations.dart';

typedef S = AppLocalizations;

class RecipeChatbotScreen extends StatefulWidget {
  const RecipeChatbotScreen({super.key});

  @override
  State<RecipeChatbotScreen> createState() => _RecipeChatbotScreenState();
}

class _RecipeChatbotScreenState extends State<RecipeChatbotScreen> {
  late RecipeChatbotBloc _bloc;
  final _geminiService = locator<GeminiService>();
  final _getKcalGoalUsecase = locator<GetKcalGoalUsecase>();
  final _getMacroGoalUsecase = locator<GetMacroGoalUsecase>();
  final _getIntakeUseCase = locator<GetIntakeUsecase>();
  final Map<String, dynamic> _filters = {
    'LANGUAGE': 'English',
    'RECIPE_TYPE': 'Any',
    'DIETARY_RESTRICTIONS': <String>[],
    'CONTEXT': '',
  };
  
  final TextEditingController _contextController = TextEditingController();

  bool _filtersCollapsed = false;

  @override
  void initState() {
    super.initState();
    _bloc = RecipeChatbotBloc(
      _geminiService,
      _getKcalGoalUsecase,
      _getMacroGoalUsecase,
      _getIntakeUseCase,
      locator<SavedRecipeLocalDataSource>(),
    );
    _bloc.add(LoadSavedRecipes());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize with device locale
    final locale = Localizations.localeOf(context);
    _filters['LANGUAGE'] = locale.languageCode == 'de' ? 'German' : 'English';
  }

  @override
  void dispose() {
    _bloc.close();
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return BlocProvider<RecipeChatbotBloc>.value(
        value: _bloc,
        child: BlocBuilder<RecipeChatbotBloc, RecipeChatbotState>(
          builder: (context, state) {
            if (state.selectedRecipe != null) {
              final recipe = state.selectedRecipe;
              return Scaffold(
                appBar: AppBar(
                  title: Text(S.of(context).recipeDetailsTitle),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      _bloc.add(RecipeUnselected());
                    },
                  ),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withAlpha(150),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Recipe Image
                              // if (recipe?['imageUrl'] != null)
                              //   ClipRRect(
                              //     borderRadius: BorderRadius.circular(16),
                              //     child: Image.network(
                              //       recipe!['imageUrl'],
                              //       height: 200,
                              //       width: double.infinity,
                              //       fit: BoxFit.cover,
                              //     ),
                              //   )
                              // else
                              //   Container(
                              //     height: 200,
                              //     width: double.infinity,
                              //     decoration: BoxDecoration(
                              //       color: Theme.of(context).brightness ==
                              //               Brightness.dark
                              //           ? Colors.grey[900]
                              //           : Colors.grey[200],
                              //       borderRadius: BorderRadius.circular(16),
                              //     ),
                              //     child: Icon(Icons.restaurant_menu,
                              //         size: 64, color: Colors.grey[600]),
                              //   ),
                              const SizedBox(height: 20),

                              // Recipe Name
                              Text(
                                recipe?['name'] ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),

                              Text(
                                "${recipe?['calories'] ?? ''} kcal",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),

                              // Nutrition Info as Chips
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _nutritionChip(
                                    context,
                                    "💪",
                                    "Protein",
                                    "${recipe?['protein'] ?? 0}",
                                    isDark
                                        ? Colors.green[900]!
                                        : Colors.green[100]!,
                                    isDark
                                        ? Colors.green[200]!
                                        : Colors.green[700]!,
                                  ),
                                  const SizedBox(width: 8),
                                  _nutritionChip(
                                    context,
                                    "🌾",
                                    "Carbs",
                                    "${recipe?['carbs'] ?? 0}",
                                    isDark
                                        ? Colors.blue[900]!
                                        : Colors.blue[100]!,
                                    isDark
                                        ? Colors.blue[200]!
                                        : Colors.blue[700]!,
                                  ),
                                  const SizedBox(width: 8),
                                  _nutritionChip(
                                    context,
                                    "🥑",
                                    "Fat",
                                    "${recipe?['fat'] ?? 0}",
                                    isDark
                                        ? Colors.orange[900]!
                                        : Colors.orange[100]!,
                                    isDark
                                        ? Colors.orange[200]!
                                        : Colors.orange[700]!,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Prep/Cook Time
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("🔥", style: Theme.of(context).textTheme.bodyMedium),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${recipe?['calories']} kcal",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("🕓", style: Theme.of(context).textTheme.bodyMedium),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${S.of(context).prepTimeLabel}: ${recipe?['prep_time']} min",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("🍳", style: Theme.of(context).textTheme.bodyMedium),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${S.of(context).cookTimeLabel}: ${recipe?['cook_time']} min",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Divider(),

                              // Ingredients
                              Row(
                                children: [
                                  Text("🍃", style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(width: 8),
                                  Text(
                                    S.of(context).ingredientsLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...recipe?['ingredients']
                                  .map<Widget>((ingredient) => Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, top: 4),
                                        child: Text(
                                          '• ${ingredient['quantity']} ${ingredient['unit']} ${ingredient['name']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      )),
                              const SizedBox(height: 20),
                              Divider(),

                              // Instructions
                              Row(
                                children: [
                                  Text("📜", style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(width: 8),
                                  Text(
                                    S.of(context).instructionsLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...?recipe?['instructions']
                                  ?.asMap()
                                  .entries
                                  .map<Widget>((entry) => Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, top: 4),
                                        child: Text(
                                          "${entry.value}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      )),
                              if (recipe?['serving_suggestion'] != null) ...[
                                const SizedBox(height: 20),
                                Divider(),
                                Row(
                                  children: [
                                    Text("🍽️", style: Theme.of(context).textTheme.bodyMedium),
                                    const SizedBox(width: 8),
                                    Text(
                                      S.of(context).servingSuggestionLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    recipe?['serving_suggestion'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Saved Recipes Button
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SavedRecipesScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        label: Text(S.of(context).savedRecipesButton),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: ExpansionTile(
                          title: Text(S.of(context).filtersLabel),
                          key: GlobalKey(),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: const RoundedRectangleBorder(
                            side: BorderSide.none,
                          ),
                          initiallyExpanded: !_filtersCollapsed,
                          onExpansionChanged: (expanded) {
                            setState(() {
                            _filtersCollapsed = !expanded;
                          });
                        },
                        children: [
                          _buildFilterSection(context),
                        ],
                      ),
                      ),
                      const SizedBox(height: 24),
                      _buildRecipeList(state),
                    ],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    _filtersCollapsed = true;
                    _filters['CONTEXT'] = _contextController.text;
                  });
                  _bloc.add(FetchRecipes(_filters));
                },
                icon: const Icon(Icons.search),
                label: Text(S.of(context).findRecipesLabel),
              ),
            );
          },
        ));
  }

  Widget _buildFilterSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recipe Context Input
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).describeRecipeHint,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contextController,
                decoration: InputDecoration(
                  hintText: S.of(context).recipeContextExample,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                ),
                maxLines: 3,
                onChanged: (value) {
                  _filters['CONTEXT'] = value;
                },
                onSubmitted: (value) {
                  _filters['CONTEXT'] = value;
                },
              ),
            ],
          ),
        ),
        
        // Language is now auto-detected from device settings
        // Removed manual language selection
        
        // Recipe Type
        _buildSingleSelectFilter(
          context,
          S.of(context).mealTypeLabel,
          ['Any', 'Main Course', 'Side Dish', 'Snack', 'Dessert', 'Breakfast'],
          _filters['RECIPE_TYPE'],
          (value) => setState(() => _filters['RECIPE_TYPE'] = value),
        ),
        
        // Dietary Restrictions
        _buildMultiSelectFilter(
          S.of(context).dietaryNeedsLabel,
          [
            'Vegetarian',
            'Vegan',
            'Gluten-Free',
            'Dairy-Free',
            'Keto',
            'Low-Carb'
          ],
          _filters['DIETARY_RESTRICTIONS'] as List<String>,
          (values) => setState(() => _filters['DIETARY_RESTRICTIONS'] = values),
        ),
      ],
    );
  }

  Widget _buildSingleSelectFilter(
    BuildContext context,
    String label,
    List<String> options,
    String selectedValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map((option) => FilterChip(
                    label: Text(option),
                    selected: option == selectedValue,
                    onSelected: (bool selected) {
                      if (selected) {
                        onChanged(option);
                      }
                    },
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMultiSelectFilter(
    String label,
    List<String> options,
    List<String> selectedValues,
    Function(List<String>) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map((option) => FilterChip(
                    label: Text(option),
                    selected: selectedValues.contains(option),
                    onSelected: (bool selected) {
                      final newValues = List<String>.from(selectedValues);
                      if (selected && !newValues.contains(option)) {
                        newValues.add(option);
                      } else if (!selected && newValues.contains(option)) {
                        newValues.remove(option);
                      }
                      onChanged(newValues);
                    },
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }



  Widget _buildRecipeList(RecipeChatbotState state) {
    if (state is RecipeChatbotLoading && !state.isLoadingMore) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is RecipeChatbotError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(
                S.of(context).recipeErrorTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                S.of(context).recipeErrorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _bloc.add(FetchRecipes(_filters));
                },
                icon: const Icon(Icons.refresh),
                label: Text(S.of(context).tryAgainLabel),
              ),
            ],
          ),
        ),
      );
    } else if (state is RecipeChatbotSuccess || (state is RecipeChatbotLoading && state.isLoadingMore)) {
      final recipes = state is RecipeChatbotSuccess ? state.recipes : (state as RecipeChatbotLoading).existingRecipes ?? [];
      final isLoadingMore = state is RecipeChatbotLoading && state.isLoadingMore;
      final savedIds = state is RecipeChatbotSuccess ? state.savedRecipeIds : <String>{};
      
      if (recipes.isEmpty && !isLoadingMore) {
        return Center(child: Text(S.of(context).noRecipesFound));
      }
      
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      return Column(
        children: [
          // Recipe Grid
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 1.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, idx) {
              final recipe = recipes[idx];
              final recipeId = recipe['id'] ?? recipe['name'];
              final isSaved = savedIds.contains(recipeId);
              
              return _buildRecipeCard(
                recipe: recipe,
                isSaved: isSaved,
                isDark: isDark,
                theme: theme,
                onSaveToggle: () {
                  context.read<RecipeChatbotBloc>().add(ToggleSaveRecipe(recipe));
                },
                onTap: () {
                  context.read<RecipeChatbotBloc>().add(RecipeSelected(recipe));
                },
              );
            },
          ),
          
          // Skeleton loading cards when loading more
          if (isLoadingMore)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 3,
                itemBuilder: (context, idx) => _buildSkeletonCard(isDark),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Find More Recipes button
          if (!isLoadingMore)
            ElevatedButton.icon(
              onPressed: () {
                _bloc.add(const FetchMoreRecipes());
              },
              icon: const Icon(Icons.add),
              label: Text(S.of(context).findMoreRecipesLabel),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),

          
          const SizedBox(height: 100),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildRecipeCard({
    required Map<String, dynamic> recipe,
    required bool isSaved,
    required bool isDark,
    required ThemeData theme,
    required VoidCallback onSaveToggle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with save button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      recipe['name'] ?? S.of(context).untitledRecipe,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onSaveToggle,
                    icon: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: isSaved ? Colors.red : theme.iconTheme.color,
                    ),
                    tooltip: isSaved ? S.of(context).unsaveRecipeTooltip : S.of(context).saveRecipeTooltip,
                  ),
                ],
              ),
            ),
            
            // Calories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "${recipe['calories'] ?? 0} kcal",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Nutrition chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _nutritionChip(
                    context,
                    "💪",
                    S.of(context).proteinLabel,
                    "${recipe['protein'] ?? 0}",
                    isDark ? Colors.green[900]! : Colors.green[100]!,
                    isDark ? Colors.green[200]! : Colors.green[700]!,
                  ),
                  _nutritionChip(
                    context,
                    "🌾",
                    S.of(context).carbsLabel,
                    "${recipe['carbs'] ?? 0}",
                    isDark ? Colors.blue[900]! : Colors.blue[100]!,
                    isDark ? Colors.blue[200]! : Colors.blue[700]!,
                  ),
                  _nutritionChip(
                    context,
                    "🥑",
                    S.of(context).fatLabel,
                    "${recipe['fat'] ?? 0}",
                    isDark ? Colors.orange[900]! : Colors.orange[100]!,
                    isDark ? Colors.orange[200]! : Colors.orange[700]!,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Time info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 16, color: theme.hintColor),
                  const SizedBox(width: 4),
                  Text(
                    "${recipe['prep_time'] ?? 0}m prep · ${recipe['cook_time'] ?? 0}m cook",
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Ingredients preview
            if (recipe['ingredients'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).ingredientsLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...List.generate(
                      (recipe['ingredients'] as List).length > 2
                          ? 2
                          : (recipe['ingredients'] as List).length,
                      (i) {
                        final ing = recipe['ingredients'][i];
                        return Text(
                          "• ${ing['quantity']} ${ing['unit']} ${ing['name']}",
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                    if ((recipe['ingredients'] as List).length > 2)
                      Text(
                        S.of(context).andMoreIngredients((recipe['ingredients'] as List).length - 2),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            
            const SizedBox(height: 12),
            
            // See Details button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(S.of(context).seeDetailsLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonCard(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    
    return Card(
      elevation: 8,
      color: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title skeleton
            Container(
              height: 24,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle skeleton
            Container(
              height: 16,
              width: 100,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            // Chips skeleton
            Row(
              children: [
                for (int i = 0; i < 3; i++) ...[
                  Container(
                    height: 32,
                    width: 70,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  if (i < 2) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 16),
            // Time skeleton
            Container(
              height: 14,
              width: 120,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Spacer(),
            // Ingredients skeleton
            for (int i = 0; i < 3; i++) ...[
              const SizedBox(height: 4),
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Button skeleton
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutritionChip(
    BuildContext context,
    String icon,
    String label,
    String value,
    Color bgColor,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: theme.textTheme.bodyMedium),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
              Text(
                "${value}g",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
