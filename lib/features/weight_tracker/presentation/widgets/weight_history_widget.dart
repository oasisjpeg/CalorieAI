import 'package:flutter/material.dart';
import 'package:calorieai/core/data/repository/weight_repository.dart';
import 'package:calorieai/core/domain/entity/weight_entry_entity.dart';
import 'package:intl/intl.dart';

class WeightHistoryWidget extends StatefulWidget {
  final bool usesImperialUnits;
  final Function(DateTime) onDeleteEntry;

  const WeightHistoryWidget({
    super.key,
    required this.usesImperialUnits,
    required this.onDeleteEntry,
  });

  @override
  State<WeightHistoryWidget> createState() => _WeightHistoryWidgetState();
}

class _WeightHistoryWidgetState extends State<WeightHistoryWidget> {
  final WeightRepository _weightRepository = WeightRepository();
  List<WeightEntryEntity> _weightEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeightEntries();
  }

  Future<void> _loadWeightEntries() async {
    setState(() => _isLoading = true);
    final entries = await _weightRepository.getAllWeightEntries();
    setState(() {
      _weightEntries = entries.reversed.toList(); // Show newest first
      _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight History',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _weightEntries.isEmpty
                  ? const Center(
                      child: Text('No weight entries yet'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _weightEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _weightEntries[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primaryContainer,
                              child: Icon(
                                Icons.monitor_weight,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              '${_convertWeight(entry.weightKG).toStringAsFixed(1)} ${_getWeightUnit()}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              DateFormat('MMM d, yyyy - HH:mm').format(entry.date),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _showDeleteDialog(entry),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showDeleteDialog(WeightEntryEntity entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Weight Entry'),
        content: Text(
          'Are you sure you want to delete this weight entry from ${DateFormat('MMM d, yyyy - HH:mm').format(entry.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDeleteEntry(entry.date);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
