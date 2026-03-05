import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class FoodAnalysisLoadingDialog extends StatefulWidget {
  final Future<String> analysisFuture;
  final VoidCallback onTimeout;

  const FoodAnalysisLoadingDialog({
    super.key,
    required this.analysisFuture,
    required this.onTimeout,
  });

  @override
  State<FoodAnalysisLoadingDialog> createState() =>
      _FoodAnalysisLoadingDialogState();
}

class _FoodAnalysisLoadingDialogState extends State<FoodAnalysisLoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  Timer? _quoteTimer;
  Timer? _timeoutTimer;
  int _currentQuoteIndex = 0;
  bool _isComplete = false;
  bool _hasTimedOut = false;

  static const List<String> _quotes = [
    'Counting calories... one donut at a time',
    'Asking the food what it had for breakfast',
    'Convincing broccoli it\'s actually tasty',
    'Calculating how guilty you should feel...',
    'Measuring the love in your grandma\'s recipe',
    'Dividing by zero (just kidding, it\'s carbs)',
    'Consulting with nutritionists... and foodies',
    'Analyzing the existential crisis of your salad',
    'Checking if that\'s really kale or just lettuce',
    'Computing the mathematical perfection of pizza',
    'Interrogating the pixels for carb intel',
    'Teaching AI to understand your midnight snacks',
    'Scanning for hidden sugars like a health detective',
    'Calculating macros while dreaming of cheat days',
    'Determining if this counts as a vegetable serving',
    'Judging your portion sizes (lovingly)',
    'Crunching numbers... and hoping they\'re low',
    'Teaching robots the art of mindful eating',
    'Contemplating the meaning of a balanced diet',
    'Checking if this meal sparks joy (Marie Kondo style)',
    'Running advanced algorithms... on dessert',
    'Pondering if calories from friends don\'t count',
    'Analyzing the structural integrity of your sandwich',
    'Computing the joy-to-calorie ratio',
    'Investigating the mystery of the missing fries',
    'Determining if this is a salad or a"salad"',
    'Consulting ancient nutrition scrolls',
    'Measuring the crunch factor of your meal',
    'Calculating guilt and subtracting willpower',
  ];

  @override
  void initState() {
    super.initState();

    // Random starting quote
    _currentQuoteIndex = Random().nextInt(_quotes.length);

    // Animation controller for smooth progress
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    // Progress goes from 0 to 1 over 20 seconds
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start progress animation
    _animationController.forward();

    // Change quote every 3 seconds
    _quoteTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && !_isComplete && !_hasTimedOut) {
        setState(() {
          _currentQuoteIndex = Random().nextInt(_quotes.length);
        });
      }
    });

    // 20 second timeout
    _timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (mounted && !_isComplete) {
        setState(() {
          _hasTimedOut = true;
        });
        widget.onTimeout();
      }
    });

    // Run the analysis
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    try {
      final result = await widget.analysisFuture;
      if (mounted && !_hasTimedOut) {
        setState(() {
          _isComplete = true;
        });
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted && !_hasTimedOut) {
        Navigator.of(context).pop(e);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _quoteTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated food icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _animationController.value * 2 * 3.14159,
                        child: Icon(
                          Icons.restaurant,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Analyzing Your Meal',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Funny quote with animation
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _quotes[_currentQuoteIndex],
                  key: ValueKey<int>(_currentQuoteIndex),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
              const SizedBox(height: 24),

              // Progress bar
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progressAnimation.value,
                          minHeight: 8,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_progressAnimation.value * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Timeout message
              if (_hasTimedOut)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Taking longer than expected...',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension to easily show the dialog
extension FoodAnalysisLoadingDialogExtension on BuildContext {
  Future<dynamic> showFoodAnalysisLoading({
    required Future<String> analysisFuture,
    required VoidCallback onTimeout,
  }) {
    return showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => FoodAnalysisLoadingDialog(
        analysisFuture: analysisFuture,
        onTimeout: onTimeout,
      ),
    );
  }
}
