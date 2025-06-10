import 'package:flutter/material.dart';
import 'package:calorieai/l10n/app_localizations.dart';
typedef S = AppLocalizations;
class DeleteDialog extends StatelessWidget {
  const DeleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).deleteTimeDialogTitle),
      content: Text(S.of(context).deleteTimeDialogContent),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(S.of(context).dialogOKLabel)),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).dialogCancelLabel))
      ],
    );
  }
}
