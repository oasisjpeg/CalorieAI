import 'package:flutter/material.dart';
import 'package:opennutritracker/core/utils/url_const.dart';
import 'package:opennutritracker/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
typedef S = AppLocalizations;

class ActivityInfoButton extends StatelessWidget {
  const ActivityInfoButton({super.key});

  final url = URLConst.paCompendium2011URL;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _launchUrl,
      child: Text(
        S.of(context).additionalInfoLabelCompendium2011,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(decoration: TextDecoration.underline),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {}
  }
}
