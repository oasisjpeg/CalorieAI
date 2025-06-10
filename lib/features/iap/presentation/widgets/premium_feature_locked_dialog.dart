import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calorieai/features/iap/presentation/bloc/iap_bloc.dart';
import 'package:calorieai/features/iap/presentation/pages/iap_screen.dart';
import 'package:calorieai/l10n/app_localizations.dart';
typedef S = AppLocalizations;

class PremiumFeatureLockedDialog extends StatelessWidget {
  final String featureName;
  
  const PremiumFeatureLockedDialog({
    Key? key,
    required this.featureName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.lock_outline, color: Colors.orange),
          const SizedBox(width: 12),
          Text(s.unlockPremiumFeatures),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.unlockPremiumFeatures,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            s.upgradeToPremium,
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
          child: Text(s.upgradeToPremium),
        ),
      ],
    );
  }

  static Future<bool?> show(BuildContext context, String featureName) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => PremiumFeatureLockedDialog(
        featureName: featureName,
      ),
    );
  }
}
