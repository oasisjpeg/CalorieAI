import 'dart:async';
import 'package:flutter/material.dart' hide TimePickerDialog;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calorieai/core/utils/locator.dart';
import 'package:calorieai/features/fasting_timer/presentation/bloc/fasting_timer_bloc.dart';
import 'package:calorieai/features/fasting_timer/presentation/widgets/time_picker_dialog.dart';
import 'package:calorieai/l10n/app_localizations.dart';

class FastingTimerScreen extends StatefulWidget {
  const FastingTimerScreen({super.key});

  @override
  State<FastingTimerScreen> createState() => _FastingTimerScreenState();
}

class _FastingTimerScreenState extends State<FastingTimerScreen> {
  late FastingTimerBloc _bloc;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _bloc = locator<FastingTimerBloc>();
    _bloc.add(const LoadFastingScheduleEvent());
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _bloc.add(const UpdateTimerEvent());
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
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.fastingTimerTitle),
        ),
        body: BlocBuilder<FastingTimerBloc, FastingTimerState>(
          builder: (context, state) {
            if (state is FastingTimerLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FastingTimerActive) {
              return _buildActiveTimer(context, state, l10n);
            } else if (state is FastingTimerInactive) {
              return _buildInactiveTimer(context, state, l10n);
            } else if (state is FastingTimerEmpty) {
              return _buildEmptyState(context, l10n);
            } else if (state is FastingTimerError) {
              return Center(child: Text('Error: ${(state as FastingTimerError).message}'));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildActiveTimer(BuildContext context, FastingTimerActive state, AppLocalizations l10n) {
    final isFasting = state.isInFastingWindow;
    final remaining = state.remainingTime;
    final schedule = state.schedule;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCountdownCircle(context, remaining, isFasting, l10n),
          const SizedBox(height: 32),
          _buildScheduleInfo(context, schedule, l10n),
          const SizedBox(height: 32),
          _buildActionButtons(context, true, schedule, l10n),
        ],
      ),
    );
  }

  Widget _buildInactiveTimer(BuildContext context, FastingTimerInactive state, AppLocalizations l10n) {
    final schedule = state.schedule;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildInactiveCircle(context, l10n),
          const SizedBox(height: 32),
          _buildScheduleInfo(context, schedule, l10n),
          const SizedBox(height: 32),
          _buildActionButtons(context, false, schedule, l10n),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.fastingTimerEmptyTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.fastingTimerEmptySubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _showCreateScheduleDialog(context, l10n),
            icon: const Icon(Icons.add),
            label: Text(l10n.fastingTimerCreateButton),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownCircle(BuildContext context, Duration remaining, bool isFasting, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isFasting
            ? LinearGradient(
                colors: [colorScheme.primary, colorScheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [colorScheme.tertiary, colorScheme.tertiaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: (isFasting ? colorScheme.primary : colorScheme.tertiary).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isFasting ? l10n.fastingTimerFastingPhase : l10n.fastingTimerEatingPhase,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: theme.textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 48,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFasting ? l10n.fastingTimerUntilEating : l10n.fastingTimerUntilFasting,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveCircle(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pause_circle_outline,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.fastingTimerPaused,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleInfo(BuildContext context, dynamic schedule, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeBlock(
                  context,
                  l10n.fastingTimerFastingStart,
                  '${schedule.fastingStartHour.toString().padLeft(2, '0')}:${schedule.fastingStartMinute.toString().padLeft(2, '0')}',
                  theme.colorScheme.primary,
                ),
                Icon(Icons.arrow_forward, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                _buildTimeBlock(
                  context,
                  l10n.fastingTimerFastingEnd,
                  '${schedule.fastingEndHour.toString().padLeft(2, '0')}:${schedule.fastingEndMinute.toString().padLeft(2, '0')}',
                  theme.colorScheme.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.fastingTimerDurationLabel(schedule.fastingDuration.inHours),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBlock(BuildContext context, String label, String time, Color color) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            time,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isActive, dynamic schedule, AppLocalizations l10n) {
    return Column(
      children: [
        FilledButton.icon(
          onPressed: () => _bloc.add(ToggleFastingTimerEvent(
            localizations: _getLocalizations(context, l10n),
          )),
          icon: Icon(isActive ? Icons.pause : Icons.play_arrow),
          label: Text(isActive ? l10n.fastingTimerPauseButton : l10n.fastingTimerStartButton),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showEditScheduleDialog(context, schedule, l10n),
          icon: const Icon(Icons.edit),
          label: Text(l10n.fastingTimerEditButton),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => _showDeleteConfirmDialog(context, l10n),
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          label: Text(l10n.fastingTimerDeleteButton, style: const TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  FastingLocalizations _getLocalizations(BuildContext context, AppLocalizations l10n) {
    return FastingLocalizations(
      fastingStartedTitle: l10n.fastingTimerNotificationFastingStartedTitle,
      fastingStartedBody: l10n.fastingTimerNotificationFastingStartedBody,
      eatingStartedTitle: l10n.fastingTimerNotificationEatingStartedTitle,
      eatingStartedBody: l10n.fastingTimerNotificationEatingStartedBody,
    );
  }

  Future<void> _showCreateScheduleDialog(BuildContext context, AppLocalizations l10n) async {
    int startHour = 20;
    int startMinute = 0;
    int endHour = 12;
    int endMinute = 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.fastingTimerCreateTitle),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.fastingTimerFastingStart),
                trailing: TextButton(
                  onPressed: () async {
                    final result = await showDialog<Map<String, int>>(
                      context: context,
                      builder: (context) => TimePickerDialog(
                        title: l10n.fastingTimerSelectStartTime,
                        initialHour: startHour,
                        initialMinute: startMinute,
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        startHour = result['hour']!;
                        startMinute = result['minute']!;
                      });
                    }
                  },
                  child: Text('${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}'),
                ),
              ),
              ListTile(
                title: Text(l10n.fastingTimerFastingEnd),
                trailing: TextButton(
                  onPressed: () async {
                    final result = await showDialog<Map<String, int>>(
                      context: context,
                      builder: (context) => TimePickerDialog(
                        title: l10n.fastingTimerSelectEndTime,
                        initialHour: endHour,
                        initialMinute: endMinute,
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        endHour = result['hour']!;
                        endMinute = result['minute']!;
                      });
                    }
                  },
                  child: Text('${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.dialogCancelLabel),
          ),
          FilledButton(
            onPressed: () {
              _bloc.add(SaveFastingScheduleEvent(
                fastingStartHour: startHour,
                fastingStartMinute: startMinute,
                fastingEndHour: endHour,
                fastingEndMinute: endMinute,
                isActive: true,
                localizations: _getLocalizations(context, l10n),
              ));
              Navigator.pop(context);
            },
            child: Text(l10n.buttonSaveLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditScheduleDialog(BuildContext context, dynamic schedule, AppLocalizations l10n) async {
    int startHour = schedule.fastingStartHour;
    int startMinute = schedule.fastingStartMinute;
    int endHour = schedule.fastingEndHour;
    int endMinute = schedule.fastingEndMinute;
    bool isActive = schedule.isActive;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.fastingTimerEditTitle),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.fastingTimerFastingStart),
                trailing: TextButton(
                  onPressed: () async {
                    final result = await showDialog<Map<String, int>>(
                      context: context,
                      builder: (context) => TimePickerDialog(
                        title: l10n.fastingTimerSelectStartTime,
                        initialHour: startHour,
                        initialMinute: startMinute,
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        startHour = result['hour']!;
                        startMinute = result['minute']!;
                      });
                    }
                  },
                  child: Text('${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}'),
                ),
              ),
              ListTile(
                title: Text(l10n.fastingTimerFastingEnd),
                trailing: TextButton(
                  onPressed: () async {
                    final result = await showDialog<Map<String, int>>(
                      context: context,
                      builder: (context) => TimePickerDialog(
                        title: l10n.fastingTimerSelectEndTime,
                        initialHour: endHour,
                        initialMinute: endMinute,
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        endHour = result['hour']!;
                        endMinute = result['minute']!;
                      });
                    }
                  },
                  child: Text('${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.dialogCancelLabel),
          ),
          FilledButton(
            onPressed: () {
              _bloc.add(SaveFastingScheduleEvent(
                fastingStartHour: startHour,
                fastingStartMinute: startMinute,
                fastingEndHour: endHour,
                fastingEndMinute: endMinute,
                isActive: isActive,
                localizations: _getLocalizations(context, l10n),
              ));
              Navigator.pop(context);
            },
            child: Text(l10n.buttonSaveLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.fastingTimerDeleteTitle),
        content: Text(l10n.fastingTimerDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.dialogCancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.buttonYesLabel),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _bloc.add(const DeleteFastingScheduleEvent());
    }
  }
}
