import 'package:calorieai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

typedef S = AppLocalizations;

class GeminiScoreCard extends StatelessWidget {
  final double score;
  final String scoreText;

  const GeminiScoreCard({
    Key? key,
    required this.score,
    required this.scoreText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {    
    String emoji = score >= 8
        ? '🥦'
        : score >= 4
            ? '🍎'
            : '🍔';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 10),
                Text(
                  '${S.of(context).geminiAnalysis}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  '${score.toStringAsFixed(1)} / 10',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: score >= 8
                            ? Colors.green
                            : score >= 4
                                ? Colors.yellow[800]
                                : Colors.red,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Progress bar
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final oneThird = maxWidth / 3;
                final fill = (score / 10.0) * maxWidth;
                final double redWidth = fill.clamp(0, oneThird).toDouble();
                final double yellowWidth =
                    (fill - oneThird).clamp(0, oneThird).toDouble();
                final double greenWidth =
                    (fill - 2 * oneThird).clamp(0, oneThird).toDouble();
                ;

                // Length of each gradient overlay at the boundary (e.g., 8px)
                const double transition = 48.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        // Red section
                        if (redWidth > 0)
                          Positioned(
                            left: 0,
                            child: Container(
                              width: redWidth,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(6),
                                  right: Radius.circular(
                                      (redWidth < oneThird && yellowWidth == 0)
                                          ? 6
                                          : 0),
                                ),
                              ),
                            ),
                          ),
                        // Red-Yellow transition
                        if (redWidth > oneThird - transition && yellowWidth > 0)
                          Positioned(
                            left: oneThird - transition,
                            child: Container(
                              width: transition,
                              height: 12,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.red, Colors.yellow],
                                  stops: [0.0, 1.0],
                                ),
                              ),
                            ),
                          ),
                        // Yellow section
                        if (yellowWidth > 0)
                          Positioned(
                            left: oneThird,
                            child: Container(
                              width: yellowWidth,
                              height: 12,
                              color: Colors.yellow,
                            ),
                          ),
                        // Yellow-Green transition
                        if (yellowWidth > oneThird - transition &&
                            greenWidth > 0)
                          Positioned(
                            left: 2 * oneThird - transition,
                            child: Container(
                              width: transition,
                              height: 12,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.yellow, Colors.green],
                                  stops: [0.0, 1.0],
                                ),
                              ),
                            ),
                          ),
                        // Green section
                        if (greenWidth > 0)
                          Positioned(
                            left: 2 * oneThird,
                            child: Container(
                              width: greenWidth,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(
                                    greenWidth == oneThird ? 6 : 0,
                                  ),
                                  left: Radius.circular(
                                    greenWidth > 0 && yellowWidth == 0 ? 6 : 0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2.0, vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('0',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('10',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                scoreText,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
