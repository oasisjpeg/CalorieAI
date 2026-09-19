import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:calorieai/features/home/presentation/widgets/nutrition_facts_bottom_sheet.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:calorieai/l10n/app_localizations.dart';
import 'package:calorieai/features/settings/presentation/widgets/references_screen.dart';

typedef S = AppLocalizations;

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
  final double totalSugarsIntake;
  final double totalSaturatedFatIntake;
  final double totalFiberIntake;
  final bool showConsumedKcalAndMacros;

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
    required this.totalSugarsIntake,
    required this.totalSaturatedFatIntake,
    required this.totalFiberIntake,
    this.showConsumedKcalAndMacros = false,
  });

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  @override
  Widget build(BuildContext context) {
    // Check if dark mode is active
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Calculate values for progress indicators
    final isConsumedMode = widget.showConsumedKcalAndMacros;
    final consumedKcal = widget.totalKcalSupplied;

    double kcalPrimaryValue = 0;
    double gaugeValue = 0;
    bool isOverLimit = isConsumedMode
        ? consumedKcal > widget.totalKcalDaily
        : widget.totalKcalLeft < 0;
    double overagePercentage = 0.0;

    if (isOverLimit) {
      double overage = isConsumedMode
          ? (consumedKcal - widget.totalKcalDaily).abs()
          : widget.totalKcalLeft.abs();
      overagePercentage = (overage / widget.totalKcalDaily) * 100;
      kcalPrimaryValue = isConsumedMode ? consumedKcal : 0;
      gaugeValue = 1.0;
    } else {
      kcalPrimaryValue = isConsumedMode ? consumedKcal : widget.totalKcalLeft;
      gaugeValue = isConsumedMode
          ? (consumedKcal / widget.totalKcalDaily).clamp(0.0, 1.0)
          : (widget.totalKcalDaily - widget.totalKcalLeft) / widget.totalKcalDaily;
    }
    
    // Determine gauge color based on overage percentage
    final gaugeColor = isOverLimit
        ? (overagePercentage <= 20 ? Colors.amber : Colors.red)
        : (isDarkMode
            ? Theme.of(context).colorScheme.primary
            : Colors.black87);

    // Calculate macro nutrients values
    final proteinsLeft =
        (widget.totalProteinsIntake - widget.totalProteinsGoal).round();
    final carbsLeft = (widget.totalCarbsIntake - widget.totalCarbsGoal).round();
    final fatsLeft = (widget.totalFatsIntake - widget.totalFatsGoal).round();
    final proteinsIntake = widget.totalProteinsIntake.round();
    final carbsIntake = widget.totalCarbsIntake.round();
    final fatsIntake = widget.totalFatsIntake.round();

    // Check if any nutrients are over limit
    final proteinsOverLimit =
        widget.totalProteinsIntake > widget.totalProteinsGoal;
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
        ? Colors.red.withValues(alpha: 0.25)
        : (isDarkMode
            ? Colors.red.shade900.withValues(alpha: 0.25)
            : Colors.red.shade50);
    final carbsColor = carbsOverLimit ? Colors.red : Colors.orangeAccent;
    final carbsBg = carbsOverLimit
        ? Colors.red.withValues(alpha: 0.25)
        : (isDarkMode
            ? Colors.orange.shade900.withValues(alpha: 0.25)
            : Colors.orange.shade50);
    final fatsColor = fatsOverLimit ? Colors.red : Colors.blueAccent;
    final fatsBg = fatsOverLimit
        ? Colors.red.withValues(alpha: 0.25)
        : (isDarkMode
            ? Colors.blue.shade900.withValues(alpha: 0.25)
            : Colors.blue.shade50);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Stack(children: [
            // Main calories card
            GestureDetector(
              onTap: () => _showNutritionFactsBottomSheet(context),
              child: Container(
                decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  if (!isDarkMode)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Stack(
                children: [
                  // Main content
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Calories left section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Main counter with smooth transition between states
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, -0.1),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      )),
                                      child: child,
                                    ),
                                  );
                                },
                                child: isOverLimit
                                    ? AnimatedFlipCounter(
                                        key: ValueKey<double>(widget.totalKcalSupplied),
                                        duration: const Duration(milliseconds: 800),
                                        curve: Curves.easeOutCubic,
                                        value: widget.totalKcalSupplied.toInt(),
                                        textStyle: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: overagePercentage <= 20 
                                              ? Colors.amber[700]
                                              : Colors.red[700],
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(alpha: 0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      )
                                    : AnimatedFlipCounter(
                                        key: ValueKey<double>(kcalPrimaryValue),
                                        duration: const Duration(milliseconds: 800),
                                        curve: Curves.easeOutCubic,
                                        value: kcalPrimaryValue.toInt(),
                                        textStyle: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 2),
                              // Bottom row with overage or daily total
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                child: isOverLimit
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AnimatedFlipCounter(
                                            key: ValueKey<double>(isConsumedMode
                                                ? (consumedKcal - widget.totalKcalDaily).abs()
                                                : widget.totalKcalLeft.abs()),
                                            duration: const Duration(milliseconds: 600),
                                            curve: Curves.easeOutBack,
                                            value: (isConsumedMode
                                                    ? (consumedKcal - widget.totalKcalDaily).abs()
                                                    : widget.totalKcalLeft.abs())
                                                .toInt(),
                                            prefix: '+',
                                            textStyle: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: overagePercentage <= 20
                                                  ? Colors.amber[700]
                                                  : Colors.red[700],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AnimatedFlipCounter(
                                            key: ValueKey<double>(widget.totalKcalDaily),
                                            duration: const Duration(milliseconds: 600),
                                            curve: Curves.easeOutBack,
                                            value: widget.totalKcalDaily.toInt(),
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.7),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          isOverLimit
                                ? Text(
                                    S.of(context).kcalOverLabel,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: overagePercentage <= 20
                                          ? Colors.amber[700]
                                          : Colors.red[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : Text(
                                    isConsumedMode
                                        ? S.of(context).suppliedLabel
                                        : S.of(context).kcalLeftLabel,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
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
                        progressColor: gaugeColor,
                        backgroundColor: isDarkMode
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.2)
                            : Colors.grey.shade300,
                        center: Text(
                          isOverLimit ? '⚠️' : '🔥',
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
                ],
              ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.info_outline, size: 24),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ReferencesScreen(),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // Macro nutrients row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroCard(
                context,
                value: isConsumedMode ? proteinsIntake : proteinsLeft,
                overageValue: proteinsLeft,
                isOverLimit: proteinsOverLimit,
                label: S.of(context).proteinLabel,
                color: proteinColor,
                bgColor: proteinBg,
                emoji: '💪',
                percent: proteinsPercent,
                isDarkMode: isDarkMode,
                goalValue: widget.totalProteinsGoal,
                showConsumedMode: isConsumedMode,
              ),
              _buildMacroCard(
                context,
                value: isConsumedMode ? carbsIntake : carbsLeft,
                overageValue: carbsLeft,
                isOverLimit: carbsOverLimit,
                label: S.of(context).carbsLabel,
                color: carbsColor,
                bgColor: carbsBg,
                emoji: '🌾',
                percent: carbsPercent,
                isDarkMode: isDarkMode,
                goalValue: widget.totalCarbsGoal,
                showConsumedMode: isConsumedMode,
              ),
              _buildMacroCard(
                context,
                value: isConsumedMode ? fatsIntake : fatsLeft,
                overageValue: fatsLeft,
                isOverLimit: fatsOverLimit,
                label: S.of(context).fatLabel,
                color: fatsColor,
                bgColor: fatsBg,
                emoji: '🥑',
                percent: fatsPercent,
                isDarkMode: isDarkMode,
                goalValue: widget.totalFatsGoal,
                showConsumedMode: isConsumedMode,
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
    required int overageValue,
    required bool isOverLimit,
    required String label,
    required Color color,
    required Color bgColor,
    required String emoji,
    required double percent,
    required bool isDarkMode,
    required double goalValue,
    required bool showConsumedMode,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.black.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
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
                    showConsumedMode
                        ? (isOverLimit
                            ? '+${overageValue}g'
                            : '${value}g')
                        : (value > 0 ? '+${value}g' : '${-value}g'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "/ ${goalValue.toInt()}g",
                style: TextStyle(
                  fontSize: 12,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          CircularPercentIndicator(
            radius: 26,
            lineWidth: 6,
            percent: percent,
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: color.withValues(alpha: 0.15),
            progressColor: color,
            center: Text(emoji, style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showNutritionFactsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => NutritionFactsBottomSheet(
        totalKcalSupplied: widget.totalKcalSupplied,
        totalCarbsIntake: widget.totalCarbsIntake,
        totalFatsIntake: widget.totalFatsIntake,
        totalProteinsIntake: widget.totalProteinsIntake,
        totalSugarsIntake: widget.totalSugarsIntake,
        totalSaturatedFatIntake: widget.totalSaturatedFatIntake,
        totalFiberIntake: widget.totalFiberIntake,
        totalCarbsGoal: widget.totalCarbsGoal,
        totalFatsGoal: widget.totalFatsGoal,
        totalProteinsGoal: widget.totalProteinsGoal,
      ),
    );
  }
}
