import 'package:flutter/material.dart';
import 'package:calorieai/core/utils/navigation_options.dart';
import 'package:calorieai/features/iap/presentation/widgets/usage_counter.dart';
import 'package:calorieai/l10n/app_localizations.dart';
typedef S = AppLocalizations;
class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          // const SizedBox(width: 40, child: DynamicOntLogo()),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "CalorieAI",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface),
                // children: <TextSpan>[
                //   TextSpan(
                //       text: ' ${S.of(context).betaVersionName}',
                //       style: TextStyle(
                //           fontWeight: FontWeight.w500,
                //           color: Theme.of(context).colorScheme.onSurface)),
                // ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: UsageCounter(),
        ),
        IconButton(
          icon: Icon(Icons.settings_outlined,
              color: Theme.of(context).colorScheme.onSurface),
          tooltip: S.of(context).settingsLabel,
          onPressed: () {
            Navigator.of(context).pushNamed(NavigationOptions.settingsRoute);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
