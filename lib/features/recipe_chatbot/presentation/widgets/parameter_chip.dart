import 'package:flutter/material.dart';

class ParameterChip extends StatelessWidget {
  final String emoji;
  final ValueChanged<String>? onChanged;

  const ParameterChip({
    super.key,
    required this.label,
    required this.emoji,
    this.onChanged,
  });
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text('$emoji $label'),
      onSelected: (isSelected) => onChanged?.call(label),
    );
  }
}