import 'package:flutter/material.dart';
import 'package:calorieai/l10n/app_localizations.dart';
typedef S = AppLocalizations;
class CopyOrDeleteDialog extends StatelessWidget {
  const CopyOrDeleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).copyOrDeleteTimeDialogTitle),
      content: Text(S.of(context).copyOrDeleteTimeDialogContent),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(S.of(context).dialogCopyLabel)),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(S.of(context).dialogDeleteLabel))
      ],
    );
  }
}
