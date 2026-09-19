import 'package:flutter/material.dart';
import 'package:calorieai/features/home/presentation/widgets/dashboard_widget.dart';

class OnboardingDisplayModePageBody extends StatelessWidget {
  final bool showConsumedKcalAndMacros;
  final ValueChanged<bool> onModeChanged;

  const OnboardingDisplayModePageBody({
    super.key,
    required this.showConsumedKcalAndMacros,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose your dashboard view',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Preview with mock data: switch between remaining to goal and consumed view.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show consumed calories and macros'),
            subtitle: const Text('Turn off to show remaining to goal'),
            value: showConsumedKcalAndMacros,
            onChanged: onModeChanged,
          ),
          const SizedBox(height: 8),
          IgnorePointer(
            child: DashboardWidget(
              totalKcalDaily: 2200,
              totalKcalLeft: 750,
              totalKcalSupplied: 1450,
              totalKcalBurned: 0,
              totalCarbsIntake: 170,
              totalFatsIntake: 95,
              totalProteinsIntake: 150,
              totalCarbsGoal: 275,
              totalFatsGoal: 73,
              totalProteinsGoal: 138,
              totalSugarsIntake: 42,
              totalSaturatedFatIntake: 21,
              totalFiberIntake: 14,
              showConsumedKcalAndMacros: showConsumedKcalAndMacros,
            ),
          ),
        ],
      ),
    );
  }
}
