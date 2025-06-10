import 'package:flutter/material.dart';
import 'package:calorieai/l10n/app_localizations.dart';
typedef S = AppLocalizations;
class DisclaimerDialog extends StatelessWidget {
  const DisclaimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).settingsDisclaimerLabel),
      content: Text(S.of(context).disclaimerText),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(S.of(context).dialogOKLabel))
      ],
    );
  }
}
