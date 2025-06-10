import 'package:flutter/material.dart';
import 'package:calorieai/features/recipe_chatbot/domain/recipe_entity.dart';

class RecipeCard extends StatelessWidget {
  final RecipeEntity recipe;
  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: ExpansionTile(
          title: Text(recipe.title, style: const TextStyle(fontSize: 16),),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(recipe.description),
                  ),
                  ListTile(
                    title: const Text("Ingredients", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recipe.ingredients
                          .map((ingredient) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text('- $ingredient'),
                              ))
                          .toList(),
                    ),
                  ),
                  ListTile(
                    title: const Text("Nutriments", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: recipe.nutriments.entries
                          .map((entry) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text('- ${entry.key}: ${entry.value}'),
                              ))
                          .toList(),
                    ),
                  ),
                  // Add more sections here if needed, like instructions
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
