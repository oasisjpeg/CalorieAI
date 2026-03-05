import 'package:flutter/material.dart';
import 'package:calorieai/core/utils/locator.dart';
import 'package:calorieai/core/data/datasource/local/saved_recipe_local_data_source.dart';
import 'package:calorieai/core/data/dbo/saved_recipe_dbo.dart';
import 'package:calorieai/l10n/app_localizations.dart';

typedef S = AppLocalizations;

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  final SavedRecipeLocalDataSource _dataSource = locator<SavedRecipeLocalDataSource>();
  List<SavedRecipeDBO> _savedRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedRecipes();
  }

  Future<void> _loadSavedRecipes() async {
    final recipes = await _dataSource.getAllSavedRecipes();
    setState(() {
      _savedRecipes = recipes;
      _isLoading = false;
    });
  }

  Future<void> _deleteRecipe(String id) async {
    await _dataSource.deleteSavedRecipe(id);
    await _loadSavedRecipes();
  }

  void _showRecipeDetails(SavedRecipeDBO recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Header with delete button
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recipe.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await _deleteRecipe(recipe.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: S.of(context).deleteRecipeTooltip,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${recipe.calories} kcal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Nutrition chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildNutritionChip('Protein', recipe.protein, Colors.green),
                    _buildNutritionChip('Carbs', recipe.carbs, Colors.blue),
                    _buildNutritionChip('Fat', recipe.fat, Colors.orange),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Time
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.prepTime}m prep · ${recipe.cookTime}m cook',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  S.of(context).descriptionLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(recipe.description),
                const SizedBox(height: 24),
                
                // Ingredients
                Text(
                  S.of(context).ingredientsLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...recipe.ingredients.map((ing) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '• ${ing['quantity']} ${ing['unit']} ${ing['name']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )),
                const SizedBox(height: 24),
                
                // Instructions
                Text(
                  S.of(context).instructionsLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...recipe.instructions.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${entry.key + 1}. ${entry.value}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )),
                
                if (recipe.servingSuggestion.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    S.of(context).servingSuggestionLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.servingSuggestion,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionChip(String label, int value, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${value}g',
            style: TextStyle(
              fontSize: 14,
              color: color[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).savedRecipesTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedRecipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        S.of(context).noSavedRecipesYet,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        S.of(context).tapHeartToSave,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _savedRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _savedRecipes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showRecipeDetails(recipe),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.title,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${recipe.calories} kcal · ${recipe.prepTime + recipe.cookTime} min',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        _buildMiniChip('P: ${recipe.protein}g', Colors.green),
                                        _buildMiniChip('C: ${recipe.carbs}g', Colors.blue),
                                        _buildMiniChip('F: ${recipe.fat}g', Colors.orange),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _deleteRecipe(recipe.id),
                                icon: const Icon(Icons.favorite, color: Colors.red),
                                tooltip: S.of(context).unsaveLabel,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildMiniChip(String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color[700],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
