import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/core/presentation/widgets/add_item_bottom_sheet.dart';
import 'package:opennutritracker/features/recipe_chatbot/presentation/recipe_chatbot_screen.dart';
import 'package:opennutritracker/features/diary/diary_page.dart';
import 'package:opennutritracker/core/presentation/widgets/home_appbar.dart';
import 'package:opennutritracker/features/home/home_page.dart';
import 'package:opennutritracker/core/presentation/widgets/main_appbar.dart';
import 'package:opennutritracker/features/profile/profile_page.dart';
import 'package:opennutritracker/features/recipe_chatbot/presentation/recipe_chatbot_screen.dart';
import 'package:opennutritracker/features/recipe_chatbot/presentation/bloc/recipe_chatbot_bloc.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  MainScreenNavigation _selectedPageIndex = MainScreenNavigation.home;

  late List<Widget> _bodyPages;
  late List<PreferredSizeWidget> _appbarPages;

  @override
  void didChangeDependencies() {
    final s = S.of(context);
    _bodyPages = [
      const HomePage(),
      const DiaryPage(),
      BlocProvider(
        create: (context) => locator<RecipeChatbotBloc>(),
        child: const RecipeChatbotScreen(),
      ),
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
    final s = S.of(context);
    return Scaffold(
      appBar: _appbarPages[_selectedPageIndex.index],
      body: _bodyPages[_selectedPageIndex.index],
      floatingActionButton: _selectedPageIndex == MainScreenNavigation.home
          ? FloatingActionButton(
              onPressed: () => _onFabPressed(context),
              tooltip: s.addLabel,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedPageIndex.index,
        onDestinationSelected: _setPage,
        destinations: [
          NavigationDestination(
              icon: _selectedPageIndex == MainScreenNavigation.home
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
              label: s.profileLabel)
        ],
      ),
    );
  }    

  void _setPage(int selectedIndex) {    
    setState(() {
      _selectedPageIndex = MainScreenNavigation.values[selectedIndex];
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
