import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calorieai/features/fasting_timer/presentation/widgets/circular_time_picker.dart';

class TimePickerDialog extends StatefulWidget {
  final String title;
  final int initialHour;
  final int initialMinute;

  const TimePickerDialog({
    super.key,
    required this.title,
    required this.initialHour,
    required this.initialMinute,
  });

  @override
  State<TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<TimePickerDialog> {
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialHour;
    _minute = widget.initialMinute;
  }

  void _onTimeChanged(int hour, int minute) {
    setState(() {
      _hour = hour;
      _minute = minute;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularTimePicker(
            initialHour: _hour,
            initialMinute: _minute,
            onTimeChanged: _onTimeChanged,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeDisplay(_hour, 'h'),
              const SizedBox(width: 8),
              Text(':', style: theme.textTheme.headlineMedium),
              const SizedBox(width: 8),
              _buildTimeDisplay(_minute, 'm'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop({'hour': _hour, 'minute': _minute}),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildTimeDisplay(int value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(unit, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
