// import 'package:flutter/foundation.dart'; // Removed unused import
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/data_source/user_data_source.dart';
import 'package:opennutritracker/core/data/repository/config_repository.dart';
import 'package:opennutritracker/core/domain/entity/app_theme_entity.dart';
import 'package:opennutritracker/core/presentation/main_screen.dart';
import 'package:opennutritracker/core/presentation/widgets/image_full_screen.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';
import 'package:opennutritracker/core/styles/fonts.dart';
// import 'package:opennutritracker/core/utils/env.dart'; // Removed unused import
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/logger_config.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/core/utils/theme_mode_provider.dart';
import 'package:opennutritracker/features/activity_detail/activity_detail_screen.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_screen.dart';
import 'package:opennutritracker/features/add_activity/presentation/add_activity_screen.dart';
import 'package:opennutritracker/features/edit_meal/presentation/edit_meal_screen.dart';
import 'package:opennutritracker/features/onboarding/onboarding_screen.dart';
import 'package:opennutritracker/features/scanner/scanner_screen.dart';
import 'package:opennutritracker/features/meal_detail/meal_detail_screen.dart';
import 'package:opennutritracker/features/meal_view/presentation/meal_view_screen.dart';
import 'package:opennutritracker/features/settings/settings_screen.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:provider/provider.dart';
// import 'package:sentry_flutter/sentry_flutter.dart'; // Disabled for simulator compatibility

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LoggerConfig.intiLogger();
  await initLocator();
  final isUserInitialized = await locator<UserDataSource>().hasUserData();
  final configRepo = locator<ConfigRepository>();
  // Removed unused variable: hasAcceptedAnonymousData
  // await configRepo.getConfigHasAcceptedAnonymousData();
  final savedAppTheme = await configRepo.getConfigAppTheme();
  final log = Logger('main');

  // Sentry disabled for simulator compatibility
  log.info('Starting App without Sentry...');
  runAppWithChangeNotifiers(isUserInitialized, savedAppTheme);
}

// Sentry reporting disabled for simulator compatibility
// void _runAppWithSentryReporting(
//     bool isUserInitialized, AppThemeEntity savedAppTheme) async {
//   await SentryFlutter.init((options) {
//     options.dsn = Env.sentryDns;
//     options.tracesSampleRate = 1.0;
//   },
//       appRunner: () =>
//           runAppWithChangeNotifiers(isUserInitialized, savedAppTheme));
// }

void runAppWithChangeNotifiers(
        bool userInitialized, AppThemeEntity savedAppTheme) =>
    runApp(ChangeNotifierProvider(
        create: (_) => ThemeModeProvider(appTheme: savedAppTheme),
        child: OpenNutriTrackerApp(userInitialized: userInitialized)));

class OpenNutriTrackerApp extends StatelessWidget {
  final bool userInitialized;

  const OpenNutriTrackerApp({super.key, required this.userInitialized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => S.of(context).appTitle,
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
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
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
