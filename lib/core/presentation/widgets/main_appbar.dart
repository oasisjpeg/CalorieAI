
import 'package:flutter/material.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';

class MainAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData iconData;
  final VoidCallback? onPressedAdd;

  const MainAppbar(
      {super.key,
      required this.title,
      required this.iconData,
      this.onPressedAdd});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Icon(iconData),
      title: Text(title),
      actions: [
        if (onPressedAdd != null)
          IconButton(
              onPressed: () {
                onPressedAdd?.call();
              },
              icon: const Icon(Icons.add)),
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(NavigationOptions.settingsRoute);
          },
          icon: const Icon(Icons.settings_outlined),
        )
      ],
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
