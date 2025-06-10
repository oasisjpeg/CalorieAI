import 'package:flutter/material.dart';
import 'package:calorieai/core/presentation/widgets/add_item_bottom_sheet.dart';
import 'package:calorieai/features/diary/diary_page.dart';
import 'package:calorieai/core/presentation/widgets/home_appbar.dart';
import 'package:calorieai/features/home/home_page.dart';
import 'package:calorieai/core/presentation/widgets/main_appbar.dart';
import 'package:calorieai/features/profile/profile_page.dart';
import 'package:calorieai/features/recipe_chatbot/presentation/recipe_feature_wrapper.dart';
import 'package:calorieai/l10n/app_localizations.dart';

typedef S = AppLocalizations;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedPageIndex = 0;

  late List<Widget> _bodyPages;
  late List<PreferredSizeWidget> _appbarPages;

  @override
  void didChangeDependencies() {
    _bodyPages = [
      const HomePage(),
      const DiaryPage(),
      const RecipeFeatureWrapper(),
      const ProfilePage(),
    ];
    _appbarPages = [
      const HomeAppbar(),
      MainAppbar(title: S.of(context).diaryLabel, iconData: Icons.book),
      MainAppbar(title: "Recipes", iconData: Icons.restaurant_menu),
      MainAppbar(title: S.of(context).profileLabel, iconData: Icons.account_circle),
    ];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarPages[_selectedPageIndex],
      body: _bodyPages[_selectedPageIndex],
      floatingActionButton: _selectedPageIndex == 0
          ? FloatingActionButton(
              onPressed: () => _onFabPressed(context),
              tooltip: S.of(context).addLabel,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedPageIndex,
        onDestinationSelected: _setPage,
        destinations: [
          NavigationDestination(
              icon: _selectedPageIndex == 0
                  ? const Icon(Icons.home)
                  : const Icon(Icons.home_outlined),
              label: S.of(context).homeLabel),
          NavigationDestination(
              icon: _selectedPageIndex == 1
                  ? const Icon(Icons.book)
                  : const Icon(Icons.book_outlined),
              label: S.of(context).diaryLabel),
          NavigationDestination(
              icon: _selectedPageIndex == 3
                  ? const Icon(Icons.restaurant_menu)
                  : const Icon(Icons.restaurant_menu_outlined),
              label: "Recipes"),
          NavigationDestination(
              icon: _selectedPageIndex == 4
                  ? const Icon(Icons.account_circle)
                  : const Icon(Icons.account_circle_outlined),
              label: S.of(context).profileLabel)
        ],
      ),
    );
  }

  void _setPage(int selectedIndex) {
    setState(() {
      _selectedPageIndex = selectedIndex;
    });
  }

  void _onFabPressed(BuildContext context) async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0))),
        builder: (BuildContext context) {
          return AddItemBottomSheet(day: DateTime.now());
        });
  }
}
