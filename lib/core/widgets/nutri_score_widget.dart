import 'package:flutter/material.dart';

class NutriScoreWidget extends StatelessWidget {
  final String? score;
  final double size;

  const NutriScoreWidget({
    Key? key,
    required this.score,
    this.size = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (score == null || score!.isEmpty) return const SizedBox.shrink();

    // Convert to uppercase and get the first character
    final scoreChar = score!.toUpperCase().substring(0, 1);
    
    // Define colors for each score
    final Map<String, Color> scoreColors = {
      'A': const Color(0xFF3D9970), // Green
      'B': const Color(0xFF2ECC40), // Light Green
      'C': const Color(0xFFFFDC00), // Yellow
      'D': const Color(0xFFFF851B), // Orange
      'E': const Color(0xFFFF4136), // Red
    };

    final color = scoreColors[scoreChar] ?? Colors.grey;

    return Container(
      width: size * 0.7,  // Make it narrower
      height: size * 1.2,  // Make it taller
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black26, width: 1.0),
      ),
      child: Center(
        child: Text(
          scoreChar,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.5,  // Slightly smaller text to fit the new shape
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
