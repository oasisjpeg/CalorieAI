class RecipeEntity {
  final String title;
  final String description;
  final List<String> ingredients;
  final Map<String, String> nutriments;

  RecipeEntity({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.nutriments,
  });  

  factory RecipeEntity.fromJson(Map<String, dynamic> json) {
    return RecipeEntity(
      title: json['title'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients']),
      nutriments: Map<String, String>.from(json['nutriments']),
    );
  }

    Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'nutriments': nutriments,
    };
  }
}