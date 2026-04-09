import 'package:flutter/material.dart';
import 'package:calorieai/core/data/repository/water_repository.dart';
import 'package:calorieai/features/water_tracker/water_tracker_screen.dart';
import 'package:calorieai/l10n/app_localizations.dart';

typedef S = AppLocalizations;

class WaterSummaryWidget extends StatefulWidget {
  final bool usesImperialUnits;

  const WaterSummaryWidget({
    super.key,
    required this.usesImperialUnits,
  });

  @override
  State<WaterSummaryWidget> createState() => _WaterSummaryWidgetState();
}

class _WaterSummaryWidgetState extends State<WaterSummaryWidget> {
  final WaterRepository _waterRepository = WaterRepository();
  double _todayTotal = 0.0;

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
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return _buildWaterCard(true);
        },
      ),
    );
  }

  Widget _buildWaterCard(bool firstListElement) {
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
            onTap: _showWaterHistoryScreen,
            borderRadius: BorderRadius.circular(16.0),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.water_drop,
                    color: Colors.blue,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatWaterAmount(_todayTotal),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        S.of(context).waterToday,
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
}
