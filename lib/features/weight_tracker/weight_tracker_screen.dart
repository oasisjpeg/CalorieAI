import 'package:flutter/material.dart';
import 'package:calorieai/features/weight_tracker/presentation/widgets/weight_graph_widget.dart';
import 'package:calorieai/core/data/repository/weight_repository.dart';
import 'package:calorieai/core/domain/entity/weight_entry_entity.dart';
import 'package:calorieai/l10n/app_localizations.dart';

typedef S = AppLocalizations;

class WeightTrackerScreen extends StatefulWidget {
  final bool usesImperialUnits;

  const WeightTrackerScreen({
    super.key,
    required this.usesImperialUnits,
  });

  @override
  State<WeightTrackerScreen> createState() => _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen> {
  final WeightRepository _weightRepository = WeightRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Smaller header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 20),
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Weight History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            // Graph takes remaining space
            Expanded(
              child: WeightGraphWidget(
                usesImperialUnits: widget.usesImperialUnits,
                onDeleteEntry: (date) async {
                  await _weightRepository.deleteWeightEntry(date);
                },
              ),
            ),
            // Reduced padding for button
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showAddWeightDialog,
                  icon: const Icon(Icons.add),
                  label: Text(S.of(context).weightLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWeightDialog() {
    final weightController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).weightLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: widget.usesImperialUnits ? 'lbs' : 'kg',
                hintText: 'Enter your weight',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final weightText = weightController.text.replaceAll(',', '.');
              final weight = double.tryParse(weightText);
              if (weight != null && weight > 0) {
                final entry = WeightEntryEntity(
                  date: DateTime.now(),
                  weightKG: widget.usesImperialUnits ? weight / 2.20462 : weight,
                );
                await _weightRepository.addWeightEntry(entry);
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
