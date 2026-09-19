import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calorieai/features/iap/presentation/bloc/iap_bloc.dart';
import 'package:calorieai/features/iap/presentation/bloc/iap_state.dart';
import 'package:calorieai/features/iap/presentation/pages/iap_screen.dart';
import 'package:calorieai/features/recipe_chatbot/presentation/recipe_chatbot_screen.dart';
import 'package:calorieai/features/recipes/presentation/widgets/recipe_list_widget.dart';
import 'package:calorieai/l10n/app_localizations.dart';

typedef S = AppLocalizations;

/// Recipes bottom-nav tab: "My Recipes" (free for everyone) and
/// "AI Ideas" (premium-gated recipe generator).
class RecipeFeatureWrapper extends StatelessWidget {
  const RecipeFeatureWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: S.of(context).myRecipesLabel),
              Tab(text: S.of(context).aiIdeasLabel),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: RecipeListWidget(day: DateTime.now()),
                ),
                BlocBuilder<IAPBloc, IAPState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (!state.hasPremiumAccess) {
                      return const IAPScreen();
                    }
                    return const RecipeChatbotScreen();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
