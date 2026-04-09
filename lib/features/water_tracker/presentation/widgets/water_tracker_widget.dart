import 'package:flutter/material.dart';
import 'package:calorieai/core/data/repository/water_repository.dart';
import 'package:calorieai/core/domain/entity/water_entry_entity.dart';
import 'package:calorieai/features/water_tracker/water_tracker_screen.dart';
import 'package:calorieai/l10n/app_localizations.dart';

typedef S = AppLocalizations;

class WaterTrackerWidget extends StatefulWidget {
  final bool usesImperialUnits;

  const WaterTrackerWidget({
    super.key,
    required this.usesImperialUnits,
  });

  @override
  State<WaterTrackerWidget> createState() => _WaterTrackerWidgetState();
}

class _WaterTrackerWidgetState extends State<WaterTrackerWidget> {
  final WaterRepository _waterRepository = WaterRepository();
  double _todayTotal = 0.0;

  // Standard water amounts in ml
  final List<double> _standardAmounts = [150, 250, 500, 750, 1000];

  @override
  void initState() {
    super.initState();
    _loadWaterData();
  }

  Future<void> _loadWaterData() async {
    final todayTotal = await _waterRepository.getTodayWaterTotal();
    setState(() {
      _todayTotal = todayTotal;
    });
  }

  String _formatWaterAmount(double amountML) {
    if (widget.usesImperialUnits) {
      final oz = amountML / 29.5735; // ml to fl oz
      return '${oz.toStringAsFixed(1)} fl oz';
    }
    return '${(amountML / 1000).toStringAsFixed(1)} L';
  }

  String _formatWaterAmountShort(double amountML) {
    if (widget.usesImperialUnits) {
      final oz = amountML / 29.5735; // ml to fl oz
      return '${oz.toStringAsFixed(0)}';
    }
    return '${(amountML / 1000).toStringAsFixed(1)}';
  }

  Future<void> _addWater(double amountML) async {
    final entry = WaterEntryEntity(
      date: DateTime.now(),
      amountML: amountML,
    );
    await _waterRepository.addWaterEntry(entry);
    _loadWaterData();
  }

  void _showCustomAmountDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).waterCustomAmount),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: widget.usesImperialUnits ? 'fl oz' : 'ml',
            suffixText: widget.usesImperialUnits ? 'fl oz' : 'ml',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).dialogCancelLabel),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                final amountML = widget.usesImperialUnits
                    ? value * 29.5735 // fl oz to ml
                    : value;
                _addWater(amountML);
                Navigator.pop(context);
              }
            },
            child: Text(S.of(context).addLabel),
          ),
        ],
      ),
    );
  }

  void _showWaterHistoryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaterTrackerScreen(
          usesImperialUnits: widget.usesImperialUnits,
        ),
      ),
    ).then((_) {
      _loadWaterData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with total and history button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).waterLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatWaterAmount(_todayTotal),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: _showWaterHistoryScreen,
                tooltip: S.of(context).waterHistory,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Standard amount buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._standardAmounts.map((amount) {
                return ElevatedButton(
                  onPressed: () => _addWater(amount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _formatWaterAmountShort(amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              // Custom amount button (hidden option)
              IconButton(
                onPressed: _showCustomAmountDialog,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: S.of(context).waterCustomAmount,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  foregroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
