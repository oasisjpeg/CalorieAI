import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget to show/edit food items with emoji, quantities, and live nutrition update.
class FoodItemsAdjustableList extends StatefulWidget {
  final List<dynamic> foodItems;
  final Map<String, dynamic> totals;
  final void Function(List<Map<String, dynamic>> adjustedItems)? onChanged;

  const FoodItemsAdjustableList(
      {required this.foodItems, required this.totals, this.onChanged, Key? key})
      : super(key: key);

  @override
  State<FoodItemsAdjustableList> createState() =>
      _FoodItemsAdjustableListState();
}

class _FoodItemsAdjustableListState extends State<FoodItemsAdjustableList> {
  late List<Map<String, dynamic>> _items;
  late List<double> _quantities;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _items = widget.foodItems.map((e) {
      final map = Map<String, dynamic>.from(e);
      // Preserve the original grams for scaling
      map['original_grams'] = map['estimated_grams'];
      return map;
    }).toList();
    _quantities = _items
        .map((e) => (e['estimated_grams'] as num?)?.toDouble() ?? 0)
        .toList();
    _controllers = List.generate(_items.length,
        (i) => TextEditingController(text: _quantities[i].toStringAsFixed(0)));
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _updateQuantity(int idx, double val) {
    setState(() {
      _quantities[idx] = val;
      // Optionally update estimated_grams if you want to pass it to the parent
      _items[idx]['estimated_grams'] = val;
      _controllers[idx].text = val.toStringAsFixed(0);
      widget.onChanged?.call(_items);
    });
  }

  Map<String, num> _calcTotals() {
    double totalKcal = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;
    double totalGrams = 0;

    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      final double grams = _quantities[i];

      // Always use the original grams for scaling
      final double originalGrams =
          (item['original_grams'] as num?)?.toDouble() ?? 100.0;
      final double ratio = originalGrams > 0 ? grams / originalGrams : 1.0;

      totalKcal += ((item['calories'] as num? ?? 0).toDouble()) * ratio;
      totalProtein += ((item['protein_g'] as num? ?? 0).toDouble()) * ratio;
      totalCarbs += ((item['carbs_g'] as num? ?? 0).toDouble()) * ratio;
      totalFat += ((item['fat_g'] as num? ?? 0).toDouble()) * ratio;
      totalGrams += grams;
    }

    return {
      'kcal': totalKcal,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
      'grams': totalGrams,
    };
  }

  String _emojiForType(String? type) {
    switch (type) {
      case 'protein':
        return '🥩';
      case 'carb':
        return '🍚';
      case 'fat':
        return '🥑';
      case 'vegetable':
        return '🥦';
      default:
        return '🍽️';
    }
  }

  // Calculate nutrition for a single item based on quantity
  Map<String, double> _calculateItemNutrition(
      Map<String, dynamic> item, double quantity) {
    final double originalGrams =
        (item['original_grams'] as num?)?.toDouble() ?? 100.0;
    final double ratio = originalGrams > 0 ? quantity / originalGrams : 1.0;

    return {
      'calories': ((item['calories'] as num?)?.toDouble() ?? 0) * ratio,
      'protein': ((item['protein_g'] as num?)?.toDouble() ?? 0) * ratio,
      'carbs': ((item['carbs_g'] as num?)?.toDouble() ?? 0) * ratio,
      'fat': ((item['fat_g'] as num?)?.toDouble() ?? 0) * ratio,
      'sugar': ((item['sugar_g'] as num?)?.toDouble() ?? 0) * ratio,
      'fiber': ((item['fiber_g'] as num?)?.toDouble() ?? 0) * ratio,
      'saturated_fat':
          ((item['saturated_fat_g'] as num?)?.toDouble() ?? 0) * ratio,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final totals = _calcTotals();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with total grams
        Text(
          'Ingredients (${totals['grams']?.toStringAsFixed(0)}g)',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),

        // Ingredients list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          itemBuilder: (context, idx) {
            final item = _items[idx];
            final quantity = _quantities[idx];
            final nutrition = _calculateItemNutrition(item, quantity);
            final emoji = _emojiForType(item['type'] as String?);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First row: Name and emoji
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item['name'] ?? '',
                            style: textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Quantity controls
                    Row(
                      children: [
                        const Text('Quantity: '),
                        IconButton(
                          icon:
                              const Icon(Icons.remove_circle_outline, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: quantity > 1
                              ? () => _updateQuantity(idx, quantity - 1)
                              : null,
                        ),
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: _controllers[idx],
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (val) {
                              final v = double.tryParse(val);
                              if (v != null && v > 0) {
                                _updateQuantity(idx, v);
                              }
                            },
                            decoration: const InputDecoration(
                              isDense: true,
                              border: UnderlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _updateQuantity(idx, quantity + 1),
                        ),
                        const SizedBox(width: 4),
                        const Text('g'),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _items.removeAt(idx);
                              _quantities.removeAt(idx);
                              _controllers.removeAt(idx);
                              widget.onChanged?.call(_items);
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Nutrition info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNutritionChip(
                            '${nutrition['calories']?.toStringAsFixed(0)}',
                            'kcal',
                            theme),
                        _buildNutritionChip(
                            '${nutrition['protein']?.toStringAsFixed(1)}',
                            'P',
                            theme),
                        _buildNutritionChip(
                            '${nutrition['carbs']?.toStringAsFixed(1)}',
                            'C',
                            theme),
                        _buildNutritionChip(
                            '${nutrition['fat']?.toStringAsFixed(1)}',
                            'F',
                            theme),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Totals section
        Card(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meal Totals',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTotalChip('🔥 ${totals['kcal']?.toStringAsFixed(0)}',
                        'kcal', theme),
                    _buildTotalChip(
                        '💪 ${totals['protein']?.toStringAsFixed(1)}g',
                        'Protein',
                        theme),
                    _buildTotalChip(
                        '🌾 ${totals['carbs']?.toStringAsFixed(1)}g',
                        'Carbs',
                        theme),
                    _buildTotalChip('🥑 ${totals['fat']?.toStringAsFixed(1)}g',
                        'Fat', theme),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionChip(String value, String label, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalChip(String value, String label, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
