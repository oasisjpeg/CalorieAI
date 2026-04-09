import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:calorieai/core/data/repository/water_repository.dart';
import 'package:calorieai/core/domain/entity/water_entry_entity.dart';
import 'package:calorieai/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

typedef S = AppLocalizations;

enum WaterTimeRange {
  last7Days,
  lastMonth,
  last3Months,
  lastYear,
}

class WaterGraphWidget extends StatefulWidget {
  final bool usesImperialUnits;
  final WaterTimeRange? initialTimeRange;
  final Function(DateTime)? onDeleteEntry;

  const WaterGraphWidget({
    super.key,
    required this.usesImperialUnits,
    this.initialTimeRange = WaterTimeRange.last7Days,
    this.onDeleteEntry,
  });

  @override
  State<WaterGraphWidget> createState() => _WaterGraphWidgetState();
}

class _WaterGraphWidgetState extends State<WaterGraphWidget> {
  final WaterRepository _waterRepository = WaterRepository();
  WaterTimeRange _selectedTimeRange = WaterTimeRange.last7Days;
  List<WaterEntryEntity> _waterEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedTimeRange = widget.initialTimeRange ?? WaterTimeRange.last7Days;
    loadWaterEntries();
  }

  Future<void> loadWaterEntries() async {
    setState(() => _isLoading = true);
    
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedTimeRange) {
      case WaterTimeRange.last7Days:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case WaterTimeRange.lastMonth:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case WaterTimeRange.last3Months:
        startDate = now.subtract(const Duration(days: 90));
        break;
      case WaterTimeRange.lastYear:
        startDate = now.subtract(const Duration(days: 365));
        break;
    }
    
    final entries = await _waterRepository.getWaterEntriesInRange(startDate, now);
    
    setState(() {
      _waterEntries = entries;
      _isLoading = false;
    });
  }

  String _formatWaterAmount(double amountML) {
    if (widget.usesImperialUnits) {
      final oz = amountML / 29.5735; // ml to fl oz
      return '${oz.toStringAsFixed(1)} fl oz';
    }
    return '${(amountML / 1000).toStringAsFixed(1)} L';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            S.of(context).waterHistory,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<WaterTimeRange>(
                        value: _selectedTimeRange,
                        onChanged: (range) {
                          if (range != null) {
                            setState(() {
                              _selectedTimeRange = range;
                            });
                            loadWaterEntries();
                          }
                        },
                        style: Theme.of(context).textTheme.bodySmall,
                        icon: const Icon(Icons.arrow_drop_down, size: 20),
                        items: WaterTimeRange.values.map((range) {
                          String label;
                          switch (range) {
                            case WaterTimeRange.last7Days:
                              label = '7d';
                              break;
                            case WaterTimeRange.lastMonth:
                              label = '1m';
                              break;
                            case WaterTimeRange.last3Months:
                              label = '3m';
                              break;
                            case WaterTimeRange.lastYear:
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
            ],
          ),
        ),
        // Graph
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _waterEntries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.water_drop_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              S.of(context).waterNoData,
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
                          SizedBox(
                            height: 250,
                            child: BarChart(
                              BarChartData(
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
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index >= 0 && index < _waterEntries.length) {
                                          final date = _waterEntries[index].date;
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
                                            _formatWaterAmount(value).split(' ')[0],
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                        );
                                      },
                                      reservedSize: 50,
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                minY: 0,
                                maxY: _calculateMaxY(),
                                barGroups: _waterEntries.asMap().entries.map((entry) {
                                  return BarChartGroupData(
                                    x: entry.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: widget.usesImperialUnits 
                                            ? entry.value.amountML / 29.5735 
                                            : entry.value.amountML / 1000,
                                        color: Colors.blue,
                                        width: 12,
                                        borderRadius: BorderRadius.circular(6),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue,
                                            Colors.blue.withValues(alpha: 0.6),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    S.of(context).waterHistory,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    itemCount: _waterEntries.length,
                                    itemBuilder: (context, index) {
                                      final entry = _waterEntries[_waterEntries.length - 1 - index];
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

  Widget _buildHistoryItem(WaterEntryEntity entry, int index) {
    final isLatest = index == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isLatest
            ? Colors.blue.withValues(alpha: 0.1)
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
                ? Colors.blue
                : Colors.blue.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.water_drop,
            color: isLatest
                ? Colors.white
                : Colors.blue,
            size: 20,
          ),
        ),
        title: Text(
          _formatWaterAmount(entry.amountML),
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

  void _showDeleteDialog(WaterEntryEntity entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).waterDeleteEntry),
        content: Text(
          S.of(context).waterDeleteConfirm(
            DateFormat('MMM d, yyyy - HH:mm').format(entry.date),
          ),
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
              loadWaterEntries();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  double _calculateMaxY() {
    if (_waterEntries.isEmpty) return widget.usesImperialUnits ? 100 : 2000;
    final amounts = _waterEntries.map((e) => 
      widget.usesImperialUnits ? e.amountML / 29.5735 : e.amountML / 1000
    ).toList();
    final max = amounts.reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble();
  }

  double _calculateYInterval() {
    final max = _calculateMaxY();
    if (widget.usesImperialUnits) {
      if (max <= 32) return 8;
      if (max <= 64) return 16;
      return 32;
    } else {
      if (max <= 1000) return 250;
      if (max <= 2000) return 500;
      return 1000;
    }
  }

  double _calculateXInterval() {
    if (_waterEntries.length <= 7) return 1;
    if (_waterEntries.length <= 30) return 5;
    if (_waterEntries.length <= 90) return 10;
    return 20;
  }
}
