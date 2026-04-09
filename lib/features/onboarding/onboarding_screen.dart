import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:calorieai/core/utils/calc/modern_tdee_calc.dart';
import 'package:calorieai/core/utils/locator.dart';
import 'package:calorieai/core/utils/navigation_options.dart';
import 'package:calorieai/features/onboarding/domain/entity/user_activity_selection_entity.dart';
import 'package:calorieai/features/onboarding/domain/entity/user_gender_selection_entity.dart';
import 'package:calorieai/features/onboarding/domain/entity/user_goal_selection_entity.dart';
import 'package:calorieai/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:calorieai/features/onboarding/presentation/onboarding_intro_page_body.dart';
import 'package:calorieai/features/onboarding/presentation/widgets/onboarding_fourth_page_body.dart';
import 'package:calorieai/features/onboarding/presentation/widgets/onboarding_overview_page_body.dart';
import 'package:calorieai/features/onboarding/presentation/widgets/onboarding_third_page_body.dart';
import 'package:calorieai/features/onboarding/presentation/widgets/highlight_button.dart';
import 'package:calorieai/features/onboarding/presentation/widgets/onboarding_first_page_body.dart';
import 'package:calorieai/features/onboarding/presentation/widgets/onboarding_second_page_body.dart';
import 'package:calorieai/l10n/app_localizations.dart';
typedef S = AppLocalizations;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late OnboardingBloc _onboardingBloc;
  final _introKey = GlobalKey<IntroductionScreenState>();

  final _pageDecoration = const PageDecoration(
      safeArea: 0, bodyAlignment: Alignment.topCenter, bodyFlex: 6);

  final _defaultImageWidget = null;

  bool _introPageButtonActive = false;
  bool _firstPageButtonActive = false;
  bool _secondPageButtonActive = false;
  bool _thirdPageButtonActive = false;
  bool _fourthPageButtonActive = false;
  bool _overviewPageButtonActive = false;

  @override
  void initState() {
    _onboardingBloc = locator<OnboardingBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          bloc: _onboardingBloc,
          builder: (context, state) {
            if (state is OnboardingInitialState) {
              _onboardingBloc.add(LoadOnboardingEvent());
              return _getLoadingContent();
            } else if (state is OnboardingLoadingState) {
              return _getLoadingContent();
            } else if (state is OnboardingLoadedState) {
              return _getLoadedContent(context);
            }
            return _getLoadingContent();
          },
        ),
      ),
    );
  }

  Widget _getLoadingContent() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _getLoadedContent(BuildContext context) {
    return IntroductionScreen(
        key: _introKey,
        scrollPhysics: const NeverScrollableScrollPhysics(),
        back: const Icon(Icons.arrow_back_outlined),
        showBackButton: true,
        showNextButton: false,
        showDoneButton: false,
        isProgressTap: false,
        dotsFlex: 0,
        dotsDecorator: DotsDecorator(
          size: const Size(10.0, 10.0),
          activeColor: Theme.of(context).colorScheme.primary,
          activeSize: const Size(22.0, 10.0),
          activeShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
        onChange: onPageChanged,
        pages: _getPageViewModels());
  }

  List<PageViewModel> _getPageViewModels() => <PageViewModel>[
        PageViewModel(
            title: S.of(context).onboardingWelcomeLabel,
            decoration: _pageDecoration,
            image: _defaultImageWidget,
            bodyWidget: OnboardingIntroPageBody(
              setPageContent: _setIntroPageData,
            ),
            footer: HighlightButton(
              buttonLabel: S.of(context).buttonStartLabel,
              onButtonPressed: () => _scrollToPage(1),
              buttonActive: _introPageButtonActive,
            )),
        PageViewModel(
            titleWidget: const SizedBox(),
            // empty
            decoration: _pageDecoration,
            image: _defaultImageWidget,
            bodyWidget: OnboardingFirstPageBody(
              setPageContent: _setFirstPageData,
            ),
            footer: HighlightButton(
              buttonLabel: S.of(context).buttonNextLabel,
              onButtonPressed: () => _scrollToPage(2),
              buttonActive: _firstPageButtonActive,
            )),
        PageViewModel(
            titleWidget: const SizedBox(),
            // empty
            decoration: _pageDecoration,
            image: _defaultImageWidget,
            bodyWidget: OnboardingSecondPageBody(
              setButtonContent: _setSecondPageData,
            ),
            footer: HighlightButton(
              buttonLabel: S.of(context).buttonNextLabel,
              onButtonPressed: () => _scrollToPage(3),
              buttonActive: _secondPageButtonActive,
            )),
        PageViewModel(
            titleWidget: const SizedBox(),
            // empty
            decoration: _pageDecoration,
            image: _defaultImageWidget,
            bodyWidget: OnboardingThirdPageBody(
              setButtonContent: _setThirdPageButton,
            ),
            footer: HighlightButton(
              buttonLabel: S.of(context).buttonNextLabel,
              onButtonPressed: () => _scrollToPage(4),
              buttonActive: _thirdPageButtonActive,
            )),
        PageViewModel(
            titleWidget: const SizedBox(),
            // empty
            decoration: _pageDecoration,
            image: _defaultImageWidget,
            bodyWidget: OnboardingFourthPageBody(
              setButtonContent: _setFourthPageButton,
            ),
            footer: HighlightButton(
              buttonLabel: S.of(context).buttonNextLabel,
              onButtonPressed: () => _scrollToPage(5),
              buttonActive: _fourthPageButtonActive,
            )),
        PageViewModel(
            titleWidget: const SizedBox(),
            // empty
            decoration: _pageDecoration,
            image: _defaultImageWidget,
            bodyWidget: OnboardingOverviewPageBody(
              calorieGoalDayString: _onboardingBloc
                      .getOverviewCalorieGoal()
                      ?.toInt()
                      .toString() ??
                  "?",
              carbsGoalString:
                  _onboardingBloc.getOverviewCarbsGoal()?.toInt().toString() ??
                      "?",
              fatGoalString:
                  _onboardingBloc.getOverviewFatGoal()?.toInt().toString() ??
                      "?",
              proteinGoalString: _onboardingBloc
                      .getOverviewProteinGoal()
                      ?.toInt()
                      .toString() ??
                  "?",
              setButtonActive: _setOverviewPageContent,
              onEditCalories: () => _showCaloriesEditDialog(context),
              tdeeValue: _onboardingBloc.userSelection.toUserEntity() != null
                  ? ModernTDEECalc.calculateTDEE(_onboardingBloc.userSelection.toUserEntity()!)
                  : null,
            ),
            footer: HighlightButton(
              buttonLabel: S.of(context).buttonStartLabel,
              onButtonPressed: () {
                _onOverviewStartButtonPressed(context);
              },
              buttonActive: _overviewPageButtonActive,
            )),
      ];

  void _scrollToPage(int page) {
    FocusScope.of(context).requestFocus(FocusNode()); // Dismiss Keyboard
    _introKey.currentState?.animateScroll(page);
  }

  void _setIntroPageData(bool active, bool acceptedDataCollection) {
    setState(() {
      _onboardingBloc.userSelection.acceptDataCollection =
          acceptedDataCollection;

      _introPageButtonActive = active;
    });
  }

  void _setFirstPageData(bool active, UserGenderSelectionEntity? selectedGender,
      DateTime? selectedBirthday) {
    setState(() {
      _onboardingBloc.userSelection.gender = selectedGender;
      _onboardingBloc.userSelection.birthday = selectedBirthday;

      _firstPageButtonActive = active;
    });
  }

  void _setSecondPageData(bool active, double? selectedHeight,
      double? selectedWeight, bool usesImperial) {
    setState(() {
      _onboardingBloc.userSelection.height = selectedHeight;
      _onboardingBloc.userSelection.weight = selectedWeight;
      _onboardingBloc.userSelection.usesImperialUnits = usesImperial;

      _secondPageButtonActive = active;
    });
  }

  void _setThirdPageButton(
      bool active, UserActivitySelectionEntity? selectedActivity) {
    setState(() {
      _onboardingBloc.userSelection.activity = selectedActivity;

      _thirdPageButtonActive = active;
    });
  }

  void _setFourthPageButton(
      bool active, UserGoalSelectionEntity? selectedGoal) {
    setState(() {
      _onboardingBloc.userSelection.goal = selectedGoal;

      _fourthPageButtonActive = active;
    });
  }

  void onPageChanged(int page) {
    checkUserDataProvided();
  }

  void checkUserDataProvided() {
    _onboardingBloc.userSelection.checkDataProvided()
        ? _setOverviewPageContent(true)
        : _setOverviewPageContent(false);
  }

  void _setOverviewPageContent(bool active) {
    setState(() {
      _overviewPageButtonActive = active;
    });
  }

  void _showCaloriesEditDialog(BuildContext context) {
    final userEntity = _onboardingBloc.userSelection.toUserEntity();
    if (userEntity == null) return;

    final tdee = ModernTDEECalc.calculateTDEE(userEntity);
    final currentGoal = _onboardingBloc.getOverviewCalorieGoal() ?? tdee;
    final adjustment = currentGoal - tdee;

    // Use current user selection values if they exist, otherwise use defaults
    double kcalAdjustment = _onboardingBloc.userSelection.kcalAdjustment != 0 
        ? _onboardingBloc.userSelection.kcalAdjustment 
        : adjustment;
    double carbsPct = _onboardingBloc.userSelection.carbGoalPct != 0.5 
        ? _onboardingBloc.userSelection.carbGoalPct * 100 
        : 50.0;
    double proteinPct = _onboardingBloc.userSelection.proteinGoalPct != 0.25 
        ? _onboardingBloc.userSelection.proteinGoalPct * 100 
        : 25.0;
    double fatPct = _onboardingBloc.userSelection.fatGoalPct != 0.25 
        ? _onboardingBloc.userSelection.fatGoalPct * 100 
        : 25.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('Adjust Calories & Macros'),
              ),
              TextButton(
                child: const Text('Reset'),
                onPressed: () {
                  setDialogState(() {
                    kcalAdjustment = 0;
                    carbsPct = 50.0;
                    proteinPct = 25.0;
                    fatPct = 25.0;
                  });
                },
              ),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('TDEE: ${tdee.round()} kcal (Mifflin-St.Jeor)',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                Text('Calorie Adjustment: ${kcalAdjustment.round()} kcal'),
                Slider(
                  min: -1000,
                  max: 1000,
                  divisions: 200,
                  value: kcalAdjustment,
                  label: '${kcalAdjustment.round()} kcal',
                  onChanged: (value) {
                    setDialogState(() {
                      kcalAdjustment = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                const Text('Macro Distribution'),
                const SizedBox(height: 16),
                _buildMacroSlider('Carbs', carbsPct, Colors.orange, (value) {
                  setDialogState(() {
                    double delta = value - carbsPct;
                    carbsPct = value;
                    // Adjust protein and fat proportionally
                    if (proteinPct + fatPct > 0) {
                      double proteinRatio = proteinPct / (proteinPct + fatPct);
                      double fatRatio = fatPct / (proteinPct + fatPct);
                      proteinPct = (proteinPct - delta * proteinRatio).clamp(5.0, 90.0);
                      fatPct = (fatPct - delta * fatRatio).clamp(5.0, 90.0);
                    }
                  });
                }),
                _buildMacroSlider('Protein', proteinPct, Colors.blue, (value) {
                  setDialogState(() {
                    double delta = value - proteinPct;
                    proteinPct = value;
                    // Adjust carbs and fat proportionally
                    if (carbsPct + fatPct > 0) {
                      double carbsRatio = carbsPct / (carbsPct + fatPct);
                      double fatRatio = fatPct / (carbsPct + fatPct);
                      carbsPct = (carbsPct - delta * carbsRatio).clamp(5.0, 90.0);
                      fatPct = (fatPct - delta * fatRatio).clamp(5.0, 90.0);
                    }
                  });
                }),
                _buildMacroSlider('Fat', fatPct, Colors.green, (value) {
                  setDialogState(() {
                    double delta = value - fatPct;
                    fatPct = value;
                    // Adjust carbs and protein proportionally
                    if (carbsPct + proteinPct > 0) {
                      double carbsRatio = carbsPct / (carbsPct + proteinPct);
                      double proteinRatio = proteinPct / (carbsPct + proteinPct);
                      carbsPct = (carbsPct - delta * carbsRatio).clamp(5.0, 90.0);
                      proteinPct = (proteinPct - delta * proteinRatio).clamp(5.0, 90.0);
                    }
                  });
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save the adjustments to the bloc's user selection
                _onboardingBloc.userSelection.kcalAdjustment = kcalAdjustment;
                _onboardingBloc.userSelection.carbGoalPct = carbsPct / 100;
                _onboardingBloc.userSelection.proteinGoalPct = proteinPct / 100;
                _onboardingBloc.userSelection.fatGoalPct = fatPct / 100;
                Navigator.pop(context);
                // Refresh the overview
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroSlider(String label, double value, Color color, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${value.round()}%'),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.2),
          ),
          child: Slider(
            min: 5,
            max: 90,
            value: value,
            divisions: 85,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _onOverviewStartButtonPressed(BuildContext context) {
    final userEntity = _onboardingBloc.userSelection.toUserEntity();
    final hasAcceptedDataCollection =
        _onboardingBloc.userSelection.acceptDataCollection;
    final usesImperialUnits = _onboardingBloc.userSelection.usesImperialUnits;
    if (userEntity != null) {
      _onboardingBloc.saveOnboardingData(
          context, userEntity, hasAcceptedDataCollection, usesImperialUnits);
      Navigator.pushReplacementNamed(context, NavigationOptions.mainRoute);
    } else {
      // Error with user input
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).onboardingSaveUserError)));
      _scrollToPage(1);
    }
  }
}
