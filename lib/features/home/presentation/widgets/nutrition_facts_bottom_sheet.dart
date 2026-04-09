import 'package:flutter/material.dart';
import 'package:calorieai/l10n/app_localizations.dart';

typedef S = AppLocalizations;

class NutritionFactsBottomSheet extends StatelessWidget {
  final double totalKcalSupplied;
  final double totalCarbsIntake;
  final double totalFatsIntake;
  final double totalProteinsIntake;
  final double totalSugarsIntake;
  final double totalSaturatedFatIntake;
  final double totalFiberIntake;
  final double totalCarbsGoal;
  final double totalFatsGoal;
  final double totalProteinsGoal;

  const NutritionFactsBottomSheet({
    super.key,
    required this.totalKcalSupplied,
    required this.totalCarbsIntake,
    required this.totalFatsIntake,
    required this.totalProteinsIntake,
    required this.totalSugarsIntake,
    required this.totalSaturatedFatIntake,
    required this.totalFiberIntake,
    required this.totalCarbsGoal,
    required this.totalFatsGoal,
    required this.totalProteinsGoal,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? Theme.of(context).colorScheme.surface
            : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Text(
                  S.of(context).nutritionFactsLabel,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Nutrition facts
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildNutritionRow(
                  context,
                  label: S.of(context).caloriesLabel,
                  value: totalKcalSupplied,
                  unit: 'kcal',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildNutritionRow(
                  context,
                  label: S.of(context).carbsLabel,
                  value: totalCarbsIntake,
                  unit: 'g',
                  goal: totalCarbsGoal,
                  icon: Icons.grain,
                  color: Colors.orangeAccent,
                ),
                const SizedBox(height: 16),
                _buildNutritionRow(
                  context,
                  label: S.of(context).proteinLabel,
                  value: totalProteinsIntake,
                  unit: 'g',
                  goal: totalProteinsGoal,
                  icon: Icons.fitness_center,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                _buildNutritionRow(
                  context,
                  label: S.of(context).fatLabel,
                  value: totalFatsIntake,
                  unit: 'g',
                  goal: totalFatsGoal,
                  icon: Icons.water_drop,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildNutritionRow(
                  context,
                  label: S.of(context).sugarsLabel,
                  value: totalSugarsIntake,
                  unit: 'g',
                  icon: Icons.cake,
                  color: Colors.purpleAccent,
                ),
                const SizedBox(height: 16),
                _buildNutritionRow(
                  context,
                  label: S.of(context).saturatedFatLabel,
                  value: totalSaturatedFatIntake,
                  unit: 'g',
                  icon: Icons.block,
                  color: Colors.deepOrangeAccent,
                ),
                const SizedBox(height: 16),
                _buildNutritionRow(
                  context,
                  label: S.of(context).fiberLabel,
                  value: totalFiberIntake,
                  unit: 'g',
                  icon: Icons.eco,
                  color: Colors.greenAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(
    BuildContext context, {
    required String label,
    required double value,
    required String unit,
    double? goal,
    required IconData icon,
    required Color color,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode
                      ? Colors.grey.withValues(alpha: 0.7)
                      : Colors.grey.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${value.toStringAsFixed(1)}$unit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (goal != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '/ ${goal.toStringAsFixed(0)}$unit',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? Colors.grey.withValues(alpha: 0.7)
                            : Colors.grey.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
