import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CircularTimePicker extends StatefulWidget {
  final int initialHour;
  final int initialMinute;
  final Function(int hour, int minute) onTimeChanged;

  const CircularTimePicker({
    super.key,
    required this.initialHour,
    required this.initialMinute,
    required this.onTimeChanged,
  });

  @override
  State<CircularTimePicker> createState() => _CircularTimePickerState();
}

class _CircularTimePickerState extends State<CircularTimePicker> {
  late int _hour;
  late int _minute;
  bool _isHourMode = true;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialHour;
    _minute = widget.initialMinute;
  }

  void _updateTime(double angle) {
    final normalizedAngle = (angle + pi / 2) % (2 * pi);
    final value = ((normalizedAngle / (2 * pi)) * (_isHourMode ? 24 : 60)).round();
    
    setState(() {
      if (_isHourMode) {
        _hour = value % 24;
      } else {
        _minute = value % 60;
      }
    });
    widget.onTimeChanged(_hour, _minute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = 220.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: const Text('Hour'),
              selected: _isHourMode,
              onSelected: (selected) {
                if (selected) setState(() => _isHourMode = true);
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Minute'),
              selected: !_isHourMode,
              onSelected: (selected) {
                if (selected) setState(() => _isHourMode = false);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onPanUpdate: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final center = box.size.center(Offset.zero);
            final position = details.localPosition - center;
            final angle = atan2(position.dy, position.dx);
            _updateTime(angle);
          },
          onTapUp: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final center = box.size.center(Offset.zero);
            final position = details.localPosition - center;
            final angle = atan2(position.dy, position.dx);
            _updateTime(angle);
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 2,
              ),
            ),
            child: CustomPaint(
              size: Size(size, size),
              painter: _ClockPainter(
                hour: _hour,
                minute: _minute,
                isHourMode: _isHourMode,
                primaryColor: colorScheme.primary,
                onSurfaceColor: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ClockPainter extends CustomPainter {
  final int hour;
  final int minute;
  final bool isHourMode;
  final Color primaryColor;
  final Color onSurfaceColor;

  _ClockPainter({
    required this.hour,
    required this.minute,
    required this.isHourMode,
    required this.primaryColor,
    required this.onSurfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 20;
    
    final tickPaint = Paint()
      ..color = onSurfaceColor.withOpacity(0.5)
      ..strokeWidth = 1;
    
    final majorTickPaint = Paint()
      ..color = onSurfaceColor
      ..strokeWidth = 2;

    final divisions = isHourMode ? 24 : 60;
    final majorStep = isHourMode ? 6 : 15;

    for (int i = 0; i < divisions; i++) {
      final angle = (i / divisions) * 2 * pi - pi / 2;
      final isMajor = i % majorStep == 0;
      final innerRadius = isMajor ? radius - 10 : radius - 5;
      final outerRadius = radius;
      
      final inner = center + Offset(cos(angle) * innerRadius, sin(angle) * innerRadius);
      final outer = center + Offset(cos(angle) * outerRadius, sin(angle) * outerRadius);
      
      canvas.drawLine(inner, outer, isMajor ? majorTickPaint : tickPaint);
      
      if (isMajor) {
        final textRadius = radius - 25;
        final textPos = center + Offset(cos(angle) * textRadius, sin(angle) * textRadius);
        
        final textPainter = TextPainter(
          text: TextSpan(
            text: i.toString(),
            style: TextStyle(
              color: onSurfaceColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          textPos - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }

    final value = isHourMode ? hour : minute;
    final valueAngle = (value / divisions) * 2 * pi - pi / 2;
    final valuePos = center + Offset(cos(valueAngle) * (radius - 30), sin(valueAngle) * (radius - 30));

    final selectorPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(valuePos, 12, selectorPaint);
    
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3;
    
    canvas.drawLine(center, valuePos, linePaint);
    canvas.drawCircle(center, 6, selectorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
