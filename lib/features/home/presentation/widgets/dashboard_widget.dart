import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:opennutritracker/features/home/presentation/widgets/macro_nutriments_widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:opennutritracker/generated/l10n.dart';

class DashboardWidget extends StatefulWidget {
  final double totalKcalDaily;
  final double totalKcalLeft;
  final double totalKcalSupplied;
  final double totalKcalBurned;
  final double totalCarbsIntake;
  final double totalFatsIntake;
  final double totalProteinsIntake;
  final double totalCarbsGoal;
  final double totalFatsGoal;
  final double totalProteinsGoal;

  const DashboardWidget({
    super.key,
    required this.totalKcalSupplied,
    required this.totalKcalBurned,
    required this.totalKcalDaily,
    required this.totalKcalLeft,
    required this.totalCarbsIntake,
    required this.totalFatsIntake,
    required this.totalProteinsIntake,
    required this.totalCarbsGoal,
    required this.totalFatsGoal,
    required this.totalProteinsGoal,
  });

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  @override
  Widget build(BuildContext context) {
    // Calculate values for progress indicators
    double kcalLeftLabel = 0;
    double gaugeValue = 0;
    if (widget.totalKcalLeft > widget.totalKcalDaily) {
      kcalLeftLabel = widget.totalKcalDaily;
      gaugeValue = 0;
    } else if (widget.totalKcalLeft < 0) {
      kcalLeftLabel = 0;
      gaugeValue = 1;
    } else {
      kcalLeftLabel = widget.totalKcalLeft;
      gaugeValue = (widget.totalKcalDaily - widget.totalKcalLeft) /
          widget.totalKcalDaily;
    }

    // Check if dark mode is active
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Calculate macro nutrients values
    final proteinsLeft = (widget.totalProteinsIntake - widget.totalProteinsGoal).round();
    final carbsLeft = (widget.totalCarbsIntake - widget.totalCarbsGoal).round();
    final fatsLeft = (widget.totalFatsIntake - widget.totalFatsGoal).round();

    // Check if any nutrients are over limit
    final proteinsOverLimit = widget.totalProteinsIntake > widget.totalProteinsGoal;
    final carbsOverLimit = widget.totalCarbsIntake > widget.totalCarbsGoal;
    final fatsOverLimit = widget.totalFatsIntake > widget.totalFatsGoal;

    // Calculate progress percentages
    final proteinsPercent =
        (widget.totalProteinsIntake / widget.totalProteinsGoal).clamp(0.0, 1.0);
    final carbsPercent =
        (widget.totalCarbsIntake / widget.totalCarbsGoal).clamp(0.0, 1.0);
    final fatsPercent =
        (widget.totalFatsIntake / widget.totalFatsGoal).clamp(0.0, 1.0);

    final proteinColor = proteinsOverLimit ? Colors.red : Colors.redAccent;
    final proteinBg = proteinsOverLimit
        ? Colors.red.withOpacity(0.25)
        : (isDarkMode ? Colors.red.shade900.withOpacity(0.25) : Colors.red.shade50);
    final carbsColor = carbsOverLimit ? Colors.red : Colors.orangeAccent;
    final carbsBg = carbsOverLimit
        ? Colors.red.withOpacity(0.25)
        : (isDarkMode
            ? Colors.orange.shade900.withOpacity(0.25)
            : Colors.orange.shade50);
    final fatsColor = fatsOverLimit ? Colors.red : Colors.blueAccent;
    final fatsBg = fatsOverLimit
        ? Colors.red.withOpacity(0.25)
        : (isDarkMode
            ? Colors.blue.shade900.withOpacity(0.25)
            : Colors.blue.shade50);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Main calories card
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                if (!isDarkMode)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Calories left section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedFlipCounter(
                      duration: const Duration(milliseconds: 1000),
                      value: kcalLeftLabel.toInt(),
                      textStyle: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Show "/ max kcal" next to the number, smaller and lighter
                    Text(
                      '/ ${widget.totalKcalDaily.toInt()}',
                      style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.of(context).kcalLeftLabel,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),

                // Circular progress indicator with flame icon
                CircularPercentIndicator(
                  radius: 54,
                  lineWidth: 10,
                  animation: true,
                  percent: gaugeValue,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: isDarkMode
                      ? Theme.of(context).colorScheme.primary
                      : Colors.black87,
                  backgroundColor: isDarkMode
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : Colors.grey.shade200,
                  center: Text(
                    '🔥',
                    style: TextStyle(
                      fontSize: 36,
                      color: isDarkMode
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Macro nutrients row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroCard(
                context,
                value: proteinsLeft,
                label: S.of(context).proteinLabel,
                color: proteinColor,
                bgColor: proteinBg,
                emoji: '💪',
                percent: proteinsPercent,
                isDarkMode: isDarkMode,
                goalValue: widget.totalProteinsGoal,
              ),
              _buildMacroCard(
                context,
                value: carbsLeft,
                label: S.of(context).carbsLabel,
                color: carbsColor,
                bgColor: carbsBg,
                emoji: '🌾',
                percent: carbsPercent,
                isDarkMode: isDarkMode,
                goalValue: widget.totalCarbsGoal,
              ),
              _buildMacroCard(
                context,
                value: fatsLeft,
                label: S.of(context).fatLabel,
                color: fatsColor,
                bgColor: fatsBg,
                emoji: '🥑',
                percent: fatsPercent,
                isDarkMode: isDarkMode,
                goalValue: widget.totalFatsGoal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(
    BuildContext context, {
    required int value,
    required String label,
    required Color color,
    required Color bgColor,
    required String emoji,
    required double percent,
    required bool isDarkMode,
    required double goalValue,
  }) {
    final isOverLimit = value > 0;
    final hasWarning = isOverLimit;
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${value > 0 ? '+${value}g' : '${-value}g'}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                    if (hasWarning)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        emoji,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "/ ${goalValue.toInt()}g",
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.7),
                ),
              ),
            ],
          ),
        
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color ,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          CircularPercentIndicator(
            radius: 26,
            lineWidth: 6,
            percent: percent,
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: color.withOpacity(0.15),
            progressColor: color,
            center: Text(emoji, style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
