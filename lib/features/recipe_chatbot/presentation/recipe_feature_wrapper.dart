import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/features/iap/presentation/bloc/iap_bloc.dart';
import 'package:opennutritracker/features/iap/presentation/bloc/iap_state.dart';
import 'package:opennutritracker/features/iap/presentation/pages/iap_screen.dart';
import 'package:opennutritracker/features/recipe_chatbot/presentation/recipe_chatbot_screen.dart';
import 'package:opennutritracker/features/recipe_chatbot/presentation/bloc/recipe_chatbot_bloc.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class RecipeFeatureWrapper extends StatelessWidget {
  const RecipeFeatureWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IAPBloc, IAPState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!state.hasPremiumAccess) {
          // Show IAP screen if user doesn't have premium access
          return const IAPScreen();
        }

        // Show the recipe screen if user has premium access
        return BlocProvider(
          create: (context) => locator<RecipeChatbotBloc>(),
          child: const RecipeChatbotScreen(),
        );
      },
    );
  }
}
