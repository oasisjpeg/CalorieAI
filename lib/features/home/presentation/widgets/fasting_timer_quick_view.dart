import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calorieai/features/fasting_timer/presentation/bloc/fasting_timer_bloc.dart';
import 'package:calorieai/l10n/app_localizations.dart';

typedef S = AppLocalizations;

class FastingTimerQuickView extends StatefulWidget {
  const FastingTimerQuickView({super.key});

  @override
  State<FastingTimerQuickView> createState() => _FastingTimerQuickViewState();
}

class _FastingTimerQuickViewState extends State<FastingTimerQuickView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<FastingTimerBloc, FastingTimerState>(
      builder: (context, state) {
        // No schedule or empty state - show small icon
        if (state is FastingTimerEmpty ||
            state is FastingTimerInitial ||
            state is FastingTimerError) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/fasting_timer'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pushNamed('/fasting_timer'),
                      icon: Icon(
                        Icons.timer_outlined,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 24,
                      ),
                      tooltip: S.of(context).fastingTimerMenuLabel,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Text(
                      S.of(context).fastingTimerMenuLabel,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Has active or inactive schedule - show quick view card
        final schedule = state is FastingTimerActive
            ? state.schedule
            : state is FastingTimerInactive
                ? state.schedule
                : null;

        if (schedule == null) {
          return const SizedBox.shrink();
        }

        final now = DateTime.now();
        final isFasting = schedule.isCurrentlyInFastingWindow(now);
        final nextTransition = isFasting
            ? schedule.getNextEatingStart(now)
            : schedule.getNextFastingStart(now);
        final remainingDuration = nextTransition.difference(now);

        final hours = remainingDuration.inHours;
        final minutes = remainingDuration.inMinutes.remainder(60);

        // Determine colors based on phase
        final phaseColor = isFasting
            ? colorScheme.primary
            : Colors.green;
        final phaseBgColor = isFasting
            ? (isDarkMode
                ? colorScheme.primary.withValues(alpha: 0.15)
                : colorScheme.primary.withValues(alpha: 0.1))
            : (isDarkMode
                ? Colors.green.withValues(alpha: 0.15)
                : Colors.green.withValues(alpha: 0.1));

        final isActive = state is FastingTimerActive && state.schedule.isActive;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/fasting_timer'),
            child: Container(
              decoration: BoxDecoration(
                color: phaseBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: phaseColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Icon with progress indicator
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: phaseColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isFasting ? Icons.local_cafe_outlined : Icons.restaurant_outlined,
                        color: phaseColor,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Status and countdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isFasting
                              ? S.of(context).fastingTimerFastingPhase
                              : S.of(context).fastingTimerEatingPhase,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: phaseColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (isActive) ...[
                          Text(
                            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} ${isFasting ? S.of(context).fastingTimerUntilEating : S.of(context).fastingTimerUntilFasting}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ] else ...[
                          Text(
                            S.of(context).fastingTimerPaused,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Arrow indicator
                  Icon(
                    Icons.arrow_forward_ios,
                    color: phaseColor.withValues(alpha: 0.5),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
