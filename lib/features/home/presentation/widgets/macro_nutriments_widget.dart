import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:opennutritracker/l10n/app_localizations.dart';
typedef S = AppLocalizations;

class MacroNutrientsView extends StatefulWidget {
  final double totalCarbsIntake;
  final double totalFatsIntake;
  final double totalProteinsIntake;
  final double totalCarbsGoal;
  final double totalFatsGoal;
  final double totalProteinsGoal;

  const MacroNutrientsView(
      {super.key,
      required this.totalCarbsIntake,
      required this.totalFatsIntake,
      required this.totalProteinsIntake,
      required this.totalCarbsGoal,
      required this.totalFatsGoal,
      required this.totalProteinsGoal});

  @override
  State<MacroNutrientsView> createState() => _MacroNutrientsViewState();
}

class _MacroNutrientsViewState extends State<MacroNutrientsView> {
  bool isOverLimit(double intake, double goal) {
    return intake > goal;
  }

  Color getProgressColor(double intake, double goal, Color defaultColor) {
    return isOverLimit(intake, goal) ? Colors.red : defaultColor;
  }

  Widget buildNutrientIndicator({
    required double intake,
    required double goal,
    required String label,
    required IconData icon,
    required Color defaultColor,
  }) {
    final isOver = isOverLimit(intake, goal);
    final theme = Theme.of(context);
    
    return Row(
      children: [
        CircularPercentIndicator(
          radius: 15.0,
          lineWidth: 6.0,
          animation: true,
          percent: getGoalPercentage(goal, intake),
          progressColor: getProgressColor(intake, goal, defaultColor),
          backgroundColor: getProgressColor(intake, goal, defaultColor).withAlpha(50),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    '${intake.toInt()}/${goal.toInt()} g',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (isOver) ...[
                    const SizedBox(width: 4),
                    const Text(
                      '⚠️',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ]
                ],
              ),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildNutrientIndicator(
          intake: widget.totalCarbsIntake,
          goal: widget.totalCarbsGoal,
          label: S.of(context).carbsLabel,
          icon: Icons.bubble_chart,
          defaultColor: Colors.orange,
        ),
        buildNutrientIndicator(
          intake: widget.totalFatsIntake,
          goal: widget.totalFatsGoal,
          label: S.of(context).fatLabel,
          icon: Icons.local_pizza,
          defaultColor: Colors.blue,
        ),
        buildNutrientIndicator(
          intake: widget.totalProteinsIntake,
          goal: widget.totalProteinsGoal,
          label: S.of(context).proteinLabel,
          icon: Icons.fitness_center,
          defaultColor: Colors.green,
        ),
      ],
    );
  }

  double getGoalPercentage(double goal, double supplied) {
    if (supplied <= 0 || goal <= 0) {
      return 0;
    } else if (supplied > goal) {
      return 1;
    } else {
      return supplied / goal;
    }
  }
}
