import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:calorieai/core/data/repository/weight_repository.dart';
import 'package:calorieai/core/domain/entity/weight_entry_entity.dart';
import 'package:intl/intl.dart';

enum WeightTimeRange {
  last7Days,
  lastMonth,
  last3Months,
  lastYear,
}

class WeightGraphWidget extends StatefulWidget {
  final bool usesImperialUnits;
  final WeightTimeRange? initialTimeRange;
  final Function(DateTime)? onDeleteEntry;

  const WeightGraphWidget({
    super.key,
    required this.usesImperialUnits,
    this.initialTimeRange = WeightTimeRange.last7Days,
    this.onDeleteEntry,
  });

  @override
  State<WeightGraphWidget> createState() => _WeightGraphWidgetState();
}

class _WeightGraphWidgetState extends State<WeightGraphWidget> {
  final WeightRepository _weightRepository = WeightRepository();
  WeightTimeRange _selectedTimeRange = WeightTimeRange.last7Days;
  List<WeightEntryEntity> _weightEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedTimeRange = widget.initialTimeRange ?? WeightTimeRange.last7Days;
    loadWeightEntries();
  }

  Future<void> loadWeightEntries() async {
    setState(() => _isLoading = true);
    
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedTimeRange) {
      case WeightTimeRange.last7Days:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case WeightTimeRange.lastMonth:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case WeightTimeRange.last3Months:
        startDate = now.subtract(const Duration(days: 90));
        break;
      case WeightTimeRange.lastYear:
        startDate = now.subtract(const Duration(days: 365));
        break;
    }
    
    final entries = await _weightRepository.getWeightEntriesInRange(startDate, now);
    
    setState(() {
      _weightEntries = entries;
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
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.show_chart,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Weight History',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<WeightTimeRange>(
                        value: _selectedTimeRange,
                        onChanged: (range) {
                          if (range != null) {
                            setState(() {
                              _selectedTimeRange = range;
                            });
                            loadWeightEntries();
                          }
                        },
                        style: Theme.of(context).textTheme.bodySmall,
                        icon: const Icon(Icons.arrow_drop_down, size: 18),
                        items: WeightTimeRange.values.map((range) {
                          String label;
                          switch (range) {
                            case WeightTimeRange.last7Days:
                              label = '7d';
                              break;
                            case WeightTimeRange.lastMonth:
                              label = '1m';
                              break;
                            case WeightTimeRange.last3Months:
                              label = '3m';
                              break;
                            case WeightTimeRange.lastYear:
                              label = '1y';
                              break;
                          }
                          return DropdownMenuItem(
                            value: range,
                            child: Text(label),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
        ),
        // Graph
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _weightEntries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.monitor_weight_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No weight data yet',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 24.0, bottom: 16.0),
                            child: SizedBox(
                              height: 180,
                              child: LineChart(
                                LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: _calculateYInterval(),
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: _calculateXInterval(),
                                      reservedSize: 35,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index >= 0 && index < _weightEntries.length) {
                                          final date = _weightEntries[index].date;
                                          final formatter = DateFormat('MMM d');
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              formatter.format(date),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurface
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: _calculateYInterval(),
                                      getTitlesWidget: (value, meta) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Text(
                                            value.toStringAsFixed(0),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                        );
                                      },
                                      reservedSize: 40,
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                minX: 0,
                                maxX: (_weightEntries.length - 1).toDouble(),
                                minY: _calculateMinY(),
                                maxY: _calculateMaxY(),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _weightEntries.asMap().entries.map((entry) {
                                      return FlSpot(
                                        entry.key.toDouble(),
                                        _convertWeight(entry.value.weightKG),
                                      );
                                    }).toList(),
                                    isCurved: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.primary,
                                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                                      ],
                                    ),
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 5,
                                          color: Theme.of(context).colorScheme.primary,
                                          strokeWidth: 2,
                                          strokeColor: Theme.of(context).colorScheme.surface,
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.0),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    'History',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    itemCount: _weightEntries.length,
                                    itemBuilder: (context, index) {
                                      final entry = _weightEntries[_weightEntries.length - 1 - index];
                                      return _buildHistoryItem(entry, index);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(WeightEntryEntity entry, int index) {
    final isLatest = index == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isLatest
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isLatest
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.monitor_weight,
            color: isLatest
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          '${_convertWeight(entry.weightKG).toStringAsFixed(1)} ${_getWeightUnit()}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          DateFormat('MMM d, yyyy - HH:mm').format(entry.date),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: widget.onDeleteEntry != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => _showDeleteDialog(entry),
                color: Theme.of(context).colorScheme.error,
              )
            : null,
      ),
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
              widget.onDeleteEntry?.call(entry.date);
              Navigator.pop(context);
              loadWeightEntries();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  double _calculateMinY() {
    if (_weightEntries.isEmpty) return 0;
    final weights = _weightEntries.map((e) => _convertWeight(e.weightKG)).toList();
    final min = weights.reduce((a, b) => a < b ? a : b);
    return (min - 1).floorToDouble();
  }

  double _calculateMaxY() {
    if (_weightEntries.isEmpty) return 100;
    final weights = _weightEntries.map((e) => _convertWeight(e.weightKG)).toList();
    final max = weights.reduce((a, b) => a > b ? a : b);
    return (max + 1).ceilToDouble();
  }

  double _calculateYInterval() {
    final range = _calculateMaxY() - _calculateMinY();
    if (range <= 5) return 1;
    if (range <= 10) return 2;
    if (range <= 20) return 5;
    return 10;
  }

  double _calculateXInterval() {
    if (_weightEntries.length <= 7) return 1;
    if (_weightEntries.length <= 30) return 5;
    if (_weightEntries.length <= 90) return 10;
    return 20;
  }
}
