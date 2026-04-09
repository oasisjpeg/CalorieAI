import 'package:flutter/material.dart';
import 'package:calorieai/core/data/repository/weight_repository.dart';
import 'package:calorieai/core/domain/entity/weight_entry_entity.dart';
import 'package:calorieai/features/weight_tracker/weight_tracker_screen.dart';
import 'package:calorieai/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

typedef S = AppLocalizations;

class WeightTrackerWidget extends StatefulWidget {
  final bool usesImperialUnits;

  const WeightTrackerWidget({
    super.key,
    required this.usesImperialUnits,
  });

  @override
  State<WeightTrackerWidget> createState() => _WeightTrackerWidgetState();
}

class _WeightTrackerWidgetState extends State<WeightTrackerWidget> {
  final WeightRepository _weightRepository = WeightRepository();
  WeightEntryEntity? _latestWeight;

  @override
  void initState() {
    super.initState();
    _loadLatestWeight();
  }

  Future<void> _loadLatestWeight() async {
    final latest = await _weightRepository.getLatestWeightEntry();
    setState(() {
      _latestWeight = latest;
    });
  }

  double _convertWeight(double weightKG) {
    if (widget.usesImperialUnits) {
      return weightKG * 2.20462; // kg to lbs
    }
    return weightKG;
  }

  String _getWeightUnit() {
    return widget.usesImperialUnits ? 'lbs' : 'kg';
  }

  void _showWeightGraphDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeightTrackerScreen(
          usesImperialUnits: widget.usesImperialUnits,
        ),
      ),
    ).then((_) {
      _loadLatestWeight();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _latestWeight != null ? 1 : 0,
        itemBuilder: (BuildContext context, int index) {
          return _buildWeightCard(true);
        },
      ),
    );
  }

  Widget _buildWeightCard(bool firstListElement) {
    final weight = _latestWeight;
    if (weight == null) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: EdgeInsets.only(left: firstListElement ? 16 : 8, right: 16),
      child: SizedBox(
        width: 120,
        height: 120,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: InkWell(
            onTap: _showWeightGraphDialog,
            onLongPress: () => _showDeleteWeightDialog(weight),
            borderRadius: BorderRadius.circular(16.0),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.show_chart,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_convertWeight(weight.weightKG).toStringAsFixed(1)} ${_getWeightUnit()}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d').format(weight.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteWeightDialog(WeightEntryEntity entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Weight Entry'),
        content: Text(
          'Are you sure you want to delete this weight entry from ${DateFormat('MMM d, HH:mm').format(entry.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _weightRepository.deleteWeightEntry(entry.date);
              if (mounted) {
                Navigator.pop(context);
                _loadLatestWeight();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
