import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calorieai/core/utils/iap_constants.dart';
import 'package:calorieai/features/iap/presentation/bloc/iap_bloc.dart';
import 'package:calorieai/features/iap/presentation/bloc/iap_event.dart';
import 'package:calorieai/features/iap/presentation/bloc/iap_state.dart';
import 'package:calorieai/features/iap/presentation/pages/iap_screen.dart';
import 'package:calorieai/l10n/app_localizations.dart';

typedef S = AppLocalizations;

class UsageCounter extends StatelessWidget {
  const UsageCounter({super.key});

  Future<void> _resetCounter(BuildContext context) async {
    try {
      // Access the IAPBloc and dispatch a reset event
      final iapBloc = context.read<IAPBloc>();
      
      // Reset the counter by simulating a new day
      iapBloc.add(const ResetAnalysisCounter());
      
      if (context.mounted) {
        // Show a confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Counter reset successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Refresh the UI
        iapBloc.add(const LoadIAPStatus());
      }
    } catch (e, stackTrace) {
      debugPrint('Error resetting counter: $e\n$stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to reset counter. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IAPBloc, IAPState>(
      builder: (context, state) {
        if (state.hasPremiumAccess) {
          return const SizedBox.shrink();
        }
        
        // Add a gesture detector for debug functionality
        return GestureDetector(
          onLongPress: () {
             if (kDebugMode) {
              _resetCounter(context);
            }
          },
          child: _buildCounterContent(context, state),
        );
      },
    );
  }
  
  Widget _buildCounterContent(BuildContext context, IAPState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOutOfAnalyses = state.remainingDailyAnalyses <= 0;
    
    return GestureDetector(
      onTap: isOutOfAnalyses
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const IAPScreen()),
              );
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isOutOfAnalyses 
              ? colorScheme.errorContainer 
              : colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: isOutOfAnalyses
              ? Border.all(color: colorScheme.error, width: 1)
              : kDebugMode 
                  ? Border.all(color: colorScheme.outline.withOpacity(0.3), width: 1)
                  : null,
          boxShadow: isOutOfAnalyses
              ? [
                  BoxShadow(
                    color: colorScheme.error.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOutOfAnalyses 
                  ? Icons.lock_outline
                  : Icons.analytics_outlined,
              size: 16,
              color: isOutOfAnalyses
                  ? colorScheme.onErrorContainer
                  : colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 6),
            Text(
              isOutOfAnalyses
                  ? S.of(context).upgradeToPremium
                  : '${state.remainingDailyAnalyses}/${IAPConstants.dailyFreeAnalysisLimit}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isOutOfAnalyses
                    ? colorScheme.onErrorContainer
                    : colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (kDebugMode && !isOutOfAnalyses) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.bug_report,
                size: 12,
                color: colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
