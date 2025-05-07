import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/core/presentation/widgets/main_appbar.dart';
import 'package:opennutritracker/features/recipe_chatbot/presentation/bloc/recipe_chatbot_bloc.dart';
import 'package:opennutritracker/features/recipe_chatbot/presentation/bloc/recipe_chatbot_event.dart';
import 'package:opennutritracker/features/recipe_chatbot/presentation/bloc/recipe_chatbot_state.dart';
import 'package:opennutritracker/features/recipe_chatbot/presentation/widgets/parameter_chip.dart';
import 'package:opennutritracker/features/recipe_chatbot/presentation/widgets/recipe_card.dart';

import '../../../core/utils/locator.dart';

class RecipeChatbotScreen extends StatelessWidget {
  const RecipeChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<RecipeChatbotBloc>(),
      child: Scaffold(
        appBar: MainAppbar(
          title: 'Recipe Chatbot',
          iconData: Icons.restaurant_menu,
        ),
        body: BlocBuilder<RecipeChatbotBloc, RecipeChatbotState>(
          builder: (context, state) {
            if (state is RecipeChatbotInitial) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    ParameterChip(label: 'LANGUAGE', emoji: '🌎', onChanged: (value) => context.read<RecipeChatbotBloc>().add(RecipeChatbotUpdateParameter(key: 'LANGUAGE', value: value))),
                    ParameterChip(label: 'RECIPE_TYPE', emoji: '🍽️', onChanged: (value) => context.read<RecipeChatbotBloc>().add(RecipeChatbotUpdateParameter(key: 'RECIPE_TYPE', value: value))),
                    ParameterChip(label: 'COOKING_METHOD', emoji: '🍳', onChanged: (value) => context.read<RecipeChatbotBloc>().add(RecipeChatbotUpdateParameter(key: 'COOKING_METHOD', value: value))),
                    ParameterChip(label: 'MAX_COOKING_TIME', emoji: '⏱️', onChanged: (value) => context.read<RecipeChatbotBloc>().add(RecipeChatbotUpdateParameter(key: 'MAX_COOKING_TIME', value: value))),
                    ParameterChip(label: 'PRICING', emoji: '💰', onChanged: (value) => context.read<RecipeChatbotBloc>().add(RecipeChatbotUpdateParameter(key: 'PRICING', value: value))),
                    ParameterChip(label: 'PREFERRED_MEATS', emoji: '🥩', onChanged: (value) => context.read<RecipeChatbotBloc>().add(RecipeChatbotUpdateParameter(key: 'PREFERRED_MEATS', value: value))),
                    ParameterChip(label: 'PREFERRED_VEGETABLES', emoji: '🥦', onChanged: (value) => context.read<RecipeChatbotBloc>().add(RecipeChatbotUpdateParameter(key: 'PREFERRED_VEGETABLES', value: value))),
                    ParameterChip(label: 'DIETARY_RESTRICTIONS', emoji: '🚫', onChanged: (value) => context.read<RecipeChatbotBloc>().add(RecipeChatbotUpdateParameter(key: 'DIETARY_RESTRICTIONS', value: value))),
                    ParameterChip(label: 'DISLIKED_INGREDIENTS', emoji: '🤢', onChanged: (value) => context.read<RecipeChatbotBloc>().add(RecipeChatbotUpdateParameter(key: 'DISLIKED_INGREDIENTS', value: value))),
                    ParameterChip(label: 'PREFERRED_FLAVORS', emoji: '🌶️', onChanged: (value) => context.read<RecipeChatbotBloc>().add(RecipeChatbotUpdateParameter(key: 'PREFERRED_FLAVORS', value: value))),
                    ParameterChip(label: 'TARGET_CALORIES', emoji: '📊', onChanged: (value) => context.read<RecipeChatbotBloc>().add(RecipeChatbotUpdateParameter(key: 'TARGET_CALORIES', value: value))),
                    ParameterChip(label: 'MINIMUM_PROTEIN', emoji: '💪', onChanged: (value) => context.read<RecipeChatbotBloc>().add(RecipeChatbotUpdateParameter(key: 'MINIMUM_PROTEIN', value: value))),
                    ParameterChip(label: 'MAXIMUM_CARBS', emoji: '🍞', onChanged: (value) => context.read<RecipeChatbotBloc>().add(RecipeChatbotUpdateParameter(key: 'MAXIMUM_CARBS', value: value))),
                    ParameterChip(label: 'MAXIMUM_FAT', emoji: '🧈', onChanged: (value) => context.read<RecipeChatbotBloc>().add(RecipeChatbotUpdateParameter(key: 'MAXIMUM_FAT', value: value))),
                    ParameterChip(label: 'NUMBER', emoji: '🔢', onChanged: (value) => context.read<RecipeChatbotBloc>().add(RecipeChatbotUpdateParameter(key: 'NUMBER', value: value))),
                  ],
                ),
              );
            }
            if (state is RecipeChatbotLoaded) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    ...state.recipes.map((recipe) => RecipeCard(recipe: recipe)).toList(),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<RecipeChatbotBloc>().add(RecipeChatbotClear());
                        },
                        child: const Text('Clear'),
                      ),
                    )
                  ],
                ),
              );
            }
            if (state is RecipeChatbotLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if(state is RecipeChatbotError){
              return const Center(
                child: Text('Error'),
              );
            }
            return const Center(
              child: Text('Unknown state'),
            );
          },
        ),
        floatingActionButton: BlocBuilder<RecipeChatbotBloc, RecipeChatbotState>(
          builder: (context, state) {
            if (state is RecipeChatbotInitial) {
              return FloatingActionButton(
                onPressed: () {
                  context.read<RecipeChatbotBloc>().add(RecipeChatbotLoad());
                },
                child: const Icon(Icons.check),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
