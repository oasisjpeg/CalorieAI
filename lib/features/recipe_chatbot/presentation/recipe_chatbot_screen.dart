import 'package:flutter/material.dart';
import 'package:calorieai/core/utils/locator.dart';
import 'package:calorieai/features/recipe_chatbot/presentation/bloc/recipe_chatbot_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calorieai/features/recipe_chatbot/presentation/bloc/recipe_chatbot_event.dart';
import 'package:calorieai/features/recipe_chatbot/presentation/bloc/recipe_chatbot_state.dart';
import 'package:calorieai/core/services/gemini_service.dart';
import 'package:calorieai/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_intake_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_kcal_goal_usecase.dart';

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
    );
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
                  title: const Text('Recipe Details'),
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
                                        "Prep: ${recipe?['prep_time']} min",
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
                                        "Cook: ${recipe?['cook_time']} min",
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
                                    'Ingredients',
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
                                    'Instructions',
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
                                      'Serving Suggestion',
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
                      const Text(
                        'Recipe Finder',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: ExpansionTile(
                          title: const Text('Filters'),
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
                label: const Text('Find Recipes'),
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
                'Describe what you\'re looking for 🍳',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contextController,
                decoration: InputDecoration(
                  hintText: 'e.g., Quick dinner with chicken and vegetables',
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
          'Meal Type 🍽️',
          ['Any', 'Main Course', 'Side Dish', 'Snack', 'Dessert', 'Breakfast'],
          _filters['RECIPE_TYPE'],
          (value) => setState(() => _filters['RECIPE_TYPE'] = value),
        ),
        
        // Dietary Restrictions
        _buildMultiSelectFilter(
          'Dietary Needs 🍎',
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
    if (state is RecipeChatbotLoading) {
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
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We couldn\'t fetch your recipes right now. Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _bloc.add(FetchRecipes(_filters));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    } else if (state is RecipeChatbotSuccess) {
      if (state.recipes.isEmpty) {
        return const Center(child: Text('No recipes found'));
      }
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.recipes.length,
        itemBuilder: (context, idx) {
          final recipe = state.recipes[idx];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 8,
                  color: Theme.of(context).colorScheme.onPrimary.withAlpha(150),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      context
                          .read<RecipeChatbotBloc>()
                          .add(RecipeSelected(recipe));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Recipe Image (placeholder if not available)
                          // ClipRRect(
                          //   borderRadius: BorderRadius.circular(16),
                          //   child: recipe['imageUrl'] != null
                          //       ? Image.network(
                          //           recipe['imageUrl'],
                          //           height: 180,
                          //           width: double.infinity,
                          //           fit: BoxFit.cover,
                          //         )
                          //       : Container(
                          //           height: 180,
                          //           width: double.infinity,
                          //           color: isDark
                          //               ? Colors.grey[900]
                          //               : Colors.grey[200],
                          //           child: Icon(Icons.restaurant_menu,
                          //               size: 64,
                          //               color: isDark
                          //                   ? Colors.grey[700]
                          //                   : Colors.grey),
                          //         ),
                          // ),
                          const SizedBox(height: 16),
                          Text(
                            recipe['name'],
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${recipe['calories'] ?? 0} kcal",
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          // Nutrition Row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _nutritionChip(
                                  context,
                                  "💪",
                                  "Protein",
                                  "${recipe['protein'] ?? 0}",
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
                                  "${recipe['carbs'] ?? 0}",
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
                                  "${recipe['fat'] ?? 0}",
                                  isDark
                                      ? Colors.orange[900]!
                                      : Colors.orange[100]!,
                                  isDark
                                      ? Colors.orange[200]!
                                      : Colors.orange[700]!,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Prep/Cook time
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("🔥", style: theme.textTheme.bodyMedium),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Prep: ${recipe['prep_time']} min",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("🍳", style: theme.textTheme.bodyMedium),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Cook: ${recipe['cook_time']} min",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          // Ingredients preview
                          if (recipe['ingredients'] != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  "Ingredients",
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                ...List.generate(
                                  (recipe['ingredients'] as List).length > 3
                                      ? 3
                                      : (recipe['ingredients'] as List).length,
                                  (i) {
                                    final ing = recipe['ingredients'][i];
                                    return Text(
                                      "- ${ing['quantity']} ${ing['unit']} ${ing['name']}",
                                      style: theme.textTheme.bodyMedium,
                                    );
                                  },
                                ),
                                if ((recipe['ingredients'] as List).length > 3)
                                  Text("...and more",
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: theme.hintColor)),
                              ],
                            ),
                          const SizedBox(height: 10),
                          // "See Details" button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: theme.colorScheme.onSecondary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            onPressed: () {
                              context
                                  .read<RecipeChatbotBloc>()
                                  .add(RecipeSelected(recipe));
                            },
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text("See Full Recipe"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _nutritionDetailsChip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color bgColor,
    Color iconColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? bgColor.withOpacity(0.3) : bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: iconColor),
          ),
        ],
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
