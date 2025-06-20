// import 'package:flutter/foundation.dart'; // Removed unused import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:calorieai/core/data/data_source/user_data_source.dart';
import 'package:calorieai/core/data/datasource/local/iap_local_data_source.dart';
import 'package:calorieai/core/data/repository/config_repository.dart';
import 'package:calorieai/core/domain/entity/app_theme_entity.dart';
import 'package:calorieai/core/presentation/main_screen.dart';
import 'package:calorieai/core/presentation/widgets/image_full_screen.dart';
import 'package:calorieai/core/styles/color_schemes.dart';
import 'package:calorieai/core/styles/fonts.dart';
import 'package:calorieai/features/iap/domain/service/daily_limit_service.dart';
import 'package:calorieai/features/iap/presentation/bloc/iap_bloc.dart';
import 'package:calorieai/features/iap/presentation/bloc/iap_event.dart';
import 'package:calorieai/shared/iap_service.dart';
import 'package:calorieai/core/utils/locator.dart';
import 'package:calorieai/core/utils/logger_config.dart';
import 'package:calorieai/core/utils/navigation_options.dart';
import 'package:calorieai/core/utils/theme_mode_provider.dart';
import 'package:calorieai/features/activity_detail/activity_detail_screen.dart';
import 'package:calorieai/features/add_meal/presentation/add_meal_screen.dart';
import 'package:calorieai/features/add_activity/presentation/add_activity_screen.dart';
import 'package:calorieai/features/edit_meal/presentation/edit_meal_screen.dart';
import 'package:calorieai/features/onboarding/onboarding_screen.dart';
import 'package:calorieai/features/scanner/scanner_screen.dart';
import 'package:calorieai/features/meal_detail/meal_detail_screen.dart';
import 'package:calorieai/features/meal_view/presentation/meal_view_screen.dart';
import 'package:calorieai/features/settings/settings_screen.dart';
import 'package:calorieai/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:calorieai/core/utils/env.dart';
import 'package:sentry_flutter/sentry_flutter.dart'; // Disabled for simulator compatibility

typedef S = AppLocalizations;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LoggerConfig.intiLogger();
  await initLocator();
  final isUserInitialized = await locator<UserDataSource>().hasUserData();
  final configRepo = locator<ConfigRepository>();
  final hasAcceptedAnonymousData =
      await configRepo.getConfigHasAcceptedAnonymousData();
  final savedAppTheme = await configRepo.getConfigAppTheme();
  final log = Logger('main');
  
  if (kReleaseMode && hasAcceptedAnonymousData) {
    log.info('Starting App with Sentry enabled ...');
    _runAppWithSentryReporting(isUserInitialized, savedAppTheme);
  } else {
    log.info('Starting App ...');
    runAppWithChangeNotifiers(isUserInitialized, savedAppTheme);
  }
}

void _runAppWithSentryReporting(
    bool isUserInitialized, AppThemeEntity savedAppTheme) async {
  await SentryFlutter.init((options) {
    options.dsn = Env.sentryDns;
    options.tracesSampleRate = 1.0;
  },
      appRunner: () =>
          runAppWithChangeNotifiers(isUserInitialized, savedAppTheme));
}

void runAppWithChangeNotifiers(
        bool userInitialized, AppThemeEntity savedAppTheme) =>
    runApp(ChangeNotifierProvider(
        create: (_) => ThemeModeProvider(appTheme: savedAppTheme),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<IAPBloc>(
              create: (context) => IAPBloc(
                dailyLimitService: DailyLimitService(
                  localDataSource: IAPLocalDataSource(),
                ),
              )..add(const LoadIAPStatus()),
            ),
          ],
          child: OpenNutriTrackerApp(userInitialized: userInitialized),
        )));

class OpenNutriTrackerApp extends StatelessWidget {
  final bool userInitialized;

  const OpenNutriTrackerApp({super.key, required this.userInitialized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => S.of(context)?.appTitle ?? 'CalorieAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
          textTheme: appTextTheme),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          textTheme: appTextTheme),
      themeMode: Provider.of<ThemeModeProvider>(context).themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: userInitialized
          ? NavigationOptions.mainRoute
          : NavigationOptions.onboardingRoute,
      routes: {
        NavigationOptions.mainRoute: (context) => const MainScreen(),
        NavigationOptions.onboardingRoute: (context) =>
            const OnboardingScreen(),
        NavigationOptions.settingsRoute: (context) => const SettingsScreen(),
        NavigationOptions.addMealRoute: (context) => const AddMealScreen(),
        NavigationOptions.scannerRoute: (context) => const ScannerScreen(),
        NavigationOptions.mealDetailRoute: (context) =>
            const MealDetailScreen(),
        NavigationOptions.mealViewRoute: (context) => const MealViewScreen(),
        NavigationOptions.editMealRoute: (context) => const EditMealScreen(),
        NavigationOptions.addActivityRoute: (context) =>
            const AddActivityScreen(),
        NavigationOptions.activityDetailRoute: (context) =>
            const ActivityDetailScreen(),
        NavigationOptions.imageFullScreenRoute: (context) =>
            const ImageFullScreen(),
      },
    );
  }
}
