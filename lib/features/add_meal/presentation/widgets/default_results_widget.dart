import 'package:flutter/material.dart';
import 'package:calorieai/l10n/app_localizations.dart';
typedef S = AppLocalizations;

class DefaultsResultsWidget extends StatelessWidget {
  const DefaultsResultsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(S.of(context).searchDefaultLabel),
    );
  }
}
