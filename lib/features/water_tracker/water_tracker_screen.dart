import 'package:flutter/material.dart';
import 'package:calorieai/core/data/repository/water_repository.dart';
import 'package:calorieai/core/domain/entity/water_entry_entity.dart';
import 'package:calorieai/features/water_tracker/presentation/widgets/water_graph_widget.dart';
import 'package:calorieai/l10n/app_localizations.dart';

typedef S = AppLocalizations;

class WaterTrackerScreen extends StatefulWidget {
  final bool usesImperialUnits;

  const WaterTrackerScreen({
    super.key,
    required this.usesImperialUnits,
  });

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  final WaterRepository _waterRepository = WaterRepository();
  double _todayTotal = 0.0;
  int _graphKey = 0;

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
    _refreshGraph();
  }

  void _refreshGraph() {
    setState(() {
      _graphKey++;
    });
  }

  void _showWaterAmountBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
                    S.of(context).addWater,
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
            // Water amount buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ..._standardAmounts.map((amount) {
                    return ElevatedButton(
                      onPressed: () {
                        _addWater(amount);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(80, 60),
                      ),
                      child: Text(
                        _formatWaterAmountShort(amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  // Custom amount button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showCustomAmountDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(80, 60),
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).waterHistory),
      ),
      body: Column(
        children: [
          // Water total display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).waterToday,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      _formatWaterAmount(_todayTotal),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showWaterAmountBottomSheet,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(S.of(context).addWater),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Water graph
          Expanded(
            child: WaterGraphWidget(
              key: ValueKey(_graphKey),
              usesImperialUnits: widget.usesImperialUnits,
              onDeleteEntry: (date) async {
                await _waterRepository.deleteWaterEntry(date);
                _loadWaterData();
                _refreshGraph();
              },
            ),
          ),
        ],
      ),
    );
  }
}
