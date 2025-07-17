import 'package:flutter/material.dart';
import 'package:calorieai/features/home/presentation/widgets/dashboard_widget.dart';

class DashboardTestWidget extends StatefulWidget {
  const DashboardTestWidget({super.key});

  @override
  State<DashboardTestWidget> createState() => _DashboardTestWidgetState();
}

class _DashboardTestWidgetState extends State<DashboardTestWidget> {
  // Default values - set these to test different scenarios
  double totalKcalDaily = 2000; // Your daily goal
  double totalKcalSupplied = 2000; // Calories consumed
  double totalKcalBurned = 200; // Calories burned through activity
  
  // These are calculated based on the values above
  double get totalKcalLeft => totalKcalDaily - totalKcalSupplied + totalKcalBurned;

  // Macro nutrients (simplified for testing)
  final double totalCarbsIntake = 200;
  final double totalFatsIntake = 70;
  final double totalProteinsIntake = 150;
  final double totalCarbsGoal = 225;
  final double totalFatsGoal = 67;
  final double totalProteinsGoal = 150;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Slider for daily goal
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daily Goal: ${totalKcalDaily.toInt()} kcal'),
              Slider(
                value: totalKcalDaily,
                min: 1000,
                max: 4000,
                divisions: 30,
                label: totalKcalDaily.toInt().toString(),
                onChanged: (value) {
                  setState(() {
                    totalKcalDaily = value;
                  });
                },
              ),
            ],
          ),
        ),
        
        // Slider for calories consumed
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Calories Consumed: ${totalKcalSupplied.toInt()} kcal'),
              Slider(
                value: totalKcalSupplied,
                min: 0,
                max: 5000,
                divisions: 50,
                label: totalKcalSupplied.toInt().toString(),
                onChanged: (value) {
                  setState(() {
                    totalKcalSupplied = value;
                  });
                },
              ),
            ],
          ),
        ),
        
        // Slider for calories burned
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Calories Burned: ${totalKcalBurned.toInt()} kcal'),
              Slider(
                value: totalKcalBurned,
                min: 0,
                max: 1000,
                divisions: 20,
                label: totalKcalBurned.toInt().toString(),
                onChanged: (value) {
                  setState(() {
                    totalKcalBurned = value;
                  });
                },
              ),
            ],
          ),
        ),
        
        // Display the current status
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Status: ${totalKcalLeft < 0 ? 'OVER by ${totalKcalLeft.abs().toInt()} kcal (${(totalKcalLeft.abs() / totalKcalDaily * 100).toStringAsFixed(1)}% over)' : '${totalKcalLeft.toInt()} kcal remaining'}\n'
            'Gauge will be: ${totalKcalLeft < 0 ? (totalKcalLeft.abs() / totalKcalDaily * 100 <= 5 ? 'YELLOW (0-5% over)' : 'RED (>5% over)') : 'NORMAL'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        
        // The actual dashboard widget
        DashboardWidget(
          totalKcalDaily: totalKcalDaily,
          totalKcalLeft: totalKcalLeft,
          totalKcalSupplied: totalKcalSupplied,
          totalKcalBurned: totalKcalBurned,
          totalCarbsIntake: totalCarbsIntake,
          totalFatsIntake: totalFatsIntake,
          totalProteinsIntake: totalProteinsIntake,
          totalCarbsGoal: totalCarbsGoal,
          totalFatsGoal: totalFatsGoal,
          totalProteinsGoal: totalProteinsGoal,
        ),
      ],
    );
  }
}
