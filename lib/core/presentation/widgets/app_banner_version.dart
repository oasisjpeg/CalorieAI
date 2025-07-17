import 'package:flutter/material.dart';
import 'package:calorieai/l10n/app_localizations.dart';
typedef S = AppLocalizations;
class AppBannerVersion extends StatelessWidget {

  const AppBannerVersion({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // const SizedBox(height: 70, child: DynamicOntLogo()),
        Text("CalorieAI",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600)),
         SizedBox(
              width: 40, child: Image.asset('assets/icon/calorieai_logo.png')),
      ],
    );
  }
}
