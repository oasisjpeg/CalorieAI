import 'package:flutter/material.dart';
import 'package:calorieai/l10n/app_localizations.dart';
typedef S = AppLocalizations;
class AppBannerVersion extends StatelessWidget {
  final String versionNumber;

  const AppBannerVersion({super.key, required this.versionNumber});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // const SizedBox(height: 70, child: DynamicOntLogo()),
        Text("CalorieAI",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600)),
        Text(
          S.of(context).appVersionName(versionNumber),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        )
      ],
    );
  }
}
