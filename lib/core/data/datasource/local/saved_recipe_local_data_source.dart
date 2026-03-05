import 'package:hive/hive.dart';
import 'package:calorieai/core/data/dbo/saved_recipe_dbo.dart';

class SavedRecipeLocalDataSource {
  static const String _boxName = 'saved_recipes';
  Box<SavedRecipeDBO>? _box;

  Future<Box<SavedRecipeDBO>> get box async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<SavedRecipeDBO>(_boxName);
    }
    return _box!;
  }

  Future<List<SavedRecipeDBO>> getAllSavedRecipes() async {
    final b = await box;
    return b.values.toList();
  }

  Future<SavedRecipeDBO?> getSavedRecipe(String id) async {
    final b = await box;
    return b.get(id);
  }

  Future<bool> isRecipeSaved(String id) async {
    final b = await box;
    return b.containsKey(id);
  }

  Future<void> saveRecipe(SavedRecipeDBO recipe) async {
    final b = await box;
    await b.put(recipe.id, recipe);
  }

  Future<void> deleteSavedRecipe(String id) async {
    final b = await box;
    await b.delete(id);
  }

  Future<void> toggleSavedRecipe(SavedRecipeDBO recipe) async {
    final b = await box;
    if (b.containsKey(recipe.id)) {
      await b.delete(recipe.id);
    } else {
      await b.put(recipe.id, recipe);
    }
  }
}
