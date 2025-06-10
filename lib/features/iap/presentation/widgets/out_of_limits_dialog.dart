import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calorieai/core/utils/iap_constants.dart';
import 'package:calorieai/features/iap/presentation/bloc/iap_bloc.dart';
import 'package:calorieai/features/iap/presentation/pages/iap_screen.dart';
import 'package:calorieai/l10n/app_localizations.dart';
typedef S = AppLocalizations;

class OutOfLimitsDialog extends StatelessWidget {
  final int remainingAnalyses;
  
  const OutOfLimitsDialog({
    Key? key,
    required this.remainingAnalyses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          Text(s.dailyLimitReachedTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.dailyLimitMessage(remainingAnalyses),
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            s.upgradeForUnlimitedAccess,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(s.maybeLater),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
            // Navigate to IAP screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<IAPBloc>(),
                  child: const IAPScreen(),
                ),
              ),
            );
          },
          child: Text(S.of(context).upgradeToPremium),
        ),
      ],
    );
  }

  static Future<bool?> show(BuildContext context, int remainingAnalyses) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => OutOfLimitsDialog(
        remainingAnalyses: remainingAnalyses,
      ),
    );
  }
}
