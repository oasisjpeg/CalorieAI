import 'package:calorieai/features/onboarding/presentation/widgets/markdown_viewer_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calorieai/core/data/datasource/local/iap_local_data_source.dart';
import 'package:calorieai/core/domain/entity/app_theme_entity.dart';
import 'package:calorieai/core/presentation/widgets/app_banner_version.dart';
import 'package:calorieai/core/presentation/widgets/disclaimer_dialog.dart';
import 'package:calorieai/core/utils/app_const.dart';
import 'package:calorieai/core/utils/locator.dart';
import 'package:calorieai/core/utils/theme_mode_provider.dart';
import 'package:calorieai/shared/iap_service.dart';
import 'package:calorieai/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:calorieai/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:calorieai/features/home/presentation/bloc/home_bloc.dart';
import 'package:calorieai/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:calorieai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:calorieai/features/settings/presentation/widgets/export_import_dialog.dart';
import 'package:calorieai/features/settings/presentation/widgets/references_screen.dart';
import 'package:calorieai/features/debug/device_id_screen.dart';
import 'package:calorieai/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart'; // Mock Sentry for simulator compatibility
import 'package:url_launcher/url_launcher.dart';
import 'package:calorieai/features/settings/presentation/widgets/calculations_dialog.dart';

typedef S = AppLocalizations;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsBloc _settingsBloc;
  late ProfileBloc _profileBloc;
  late HomeBloc _homeBloc;
  late final DiaryBloc _diaryBloc;
  late final CalendarDayBloc _calendarDayBloc;

  @override
  void initState() {
    _settingsBloc = locator<SettingsBloc>();
    _profileBloc = locator<ProfileBloc>();
    _homeBloc = locator<HomeBloc>();
    _diaryBloc = locator<DiaryBloc>();
    _calendarDayBloc = locator<CalendarDayBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settingsLabel),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        bloc: _settingsBloc,
        builder: (context, state) {
          if (state is SettingsInitial) {
            _settingsBloc.add(LoadSettingsEvent());
          } else if (state is SettingsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsLoadedState) {
            return ListView(
              children: [
                const SizedBox(height: 16.0),
                ListTile(
                  leading: const Icon(Icons.ac_unit_outlined),
                  title: Text(S.of(context).settingsUnitsLabel),
                  onTap: () =>
                      _showUnitsDialog(context, state.usesImperialUnits),
                ),
                ListTile(
                  leading: const Icon(Icons.calculate_outlined),
                  title: Text(S.of(context).settingsCalculationsLabel),
                  onTap: () => _showCalculationsDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_medium_outlined),
                  title: Text(S.of(context).settingsThemeLabel),
                  onTap: () => _showThemeDialog(context, state.appTheme),
                ),
                ListTile(
                  leading: const Icon(Icons.import_export),
                  title: Text(S.of(context).exportImportLabel),
                  onTap: () => _showExportImportDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(S.of(context).settingsDisclaimerLabel),
                  onTap: () => _showDisclaimerDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(S.of(context).settingsReferencesLabel),
                  onTap: () => _navigateToReferencesScreen(context),
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: Text(S.of(context).settingsReportErrorLabel),
                  onTap: () => _showReportErrorDialog(context),
                ),
                // Subscription management
                if (state.isSubscribed)
                  ListTile(
                    leading: const Icon(Icons.subscriptions_outlined),
                    title: const Text('Manage Subscription'),
                    onTap: () async {
                      final iapService = IAPService();
                      final success = await iapService.openSubscriptionManagement();
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open subscription management. Please try again later.'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.policy_outlined),
                  title: Text(S.of(context).settingsPrivacySettings),
                  onTap: () =>
                      _showPrivacyDialog(context, state.sendAnonymousData),
                ),
                ListTile(
                  leading: const Icon(Icons.error_outline_outlined),
                  title: Text(S.of(context).settingAboutLabel),
                  onTap: () => _showAboutDialog(context),
                ),
                const SizedBox(height: 16.0),
                // Debug menu - only visible in debug mode
                if (kDebugMode) ..._buildDebugMenu(),
                AppBannerVersion()
              ],
            );
          }
          return const Center(child: Text('Error loading settings'));
        },
      ),
    );
  }

  List<Widget> _buildDebugMenu() {
    return [
      const Divider(),
      ListTile(
        title: const Text('Debug Menu', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const Icon(Icons.bug_report, color: Colors.red),
      ),
      ListTile(
        title: const Text('Activate Premium (Debug)'),
        subtitle: const Text('Enable premium features for testing'),
        leading: const Icon(Icons.star, color: Colors.amber),
        onTap: () async {
          try {
            final iapService = IAPService();
            await iapService.init();
            
            // Set premium status to true
            final localDataSource = IAPLocalDataSource();
            await localDataSource.savePurchaseStatus(true);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Premium features activated for testing')),
              );
              
              // Refresh the UI
              _settingsBloc.add(LoadSettingsEvent());
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error activating premium: $e')),
              );
            }
          }
        },
      ),
      ListTile(
        title: const Text('Get Device ID for Whitelist'),
        subtitle: const Text('Copy device ID to enable premium in production'),
        leading: const Icon(Icons.phone_android, color: Colors.blue),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DeviceIdScreen()),
          );
        },
      ),
      const Divider(),
      ListTile(
        title: const Text('Reset IAP Status'),
        subtitle: const Text('Clear the IAP purchase status for testing'),
        leading: const Icon(Icons.refresh),
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Reset IAP Status'),
              content: const Text('Are you sure you want to reset the IAP status? This is for testing purposes only.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('RESET', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            try {
              // Initialize the IAP service
              final iapService = IAPService();
              await iapService.init();
              
              // Clear the IAP status
              final localDataSource = IAPLocalDataSource();
              await localDataSource.clearIAPStatus();
              
              // Reset the daily analysis count
              await localDataSource.saveDailyAnalysisCount(0);
              await localDataSource.saveLastAnalysisDate(DateTime(1970));
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('IAP status and analysis count reset successfully')),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error resetting IAP status: $e')),
                );
              }
            }
          }
        },
      ),
    ];
  }

  void _showUnitsDialog(BuildContext context, bool usesImperialUnits) async {
    SystemDropDownType selectedUnit = usesImperialUnits
        ? SystemDropDownType.imperial
        : SystemDropDownType.metric;
    final shouldUpdate = await showDialog<bool?>(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(S.of(context).settingsUnitsLabel),
              content: Wrap(children: [
                Column(
                  children: [
                    DropdownButtonFormField(
                      value: selectedUnit,
                      decoration: InputDecoration(
                        enabled: true,
                        filled: false,
                        labelText: S.of(context).settingsSystemLabel,
                      ),
                      onChanged: (value) {
                        selectedUnit = value ?? SystemDropDownType.metric;
                      },
                      items: [
                        DropdownMenuItem(
                            value: SystemDropDownType.metric,
                            child: Text(S.of(context).settingsMetricLabel)),
                        DropdownMenuItem(
                            value: SystemDropDownType.imperial,
                            child: Text(S.of(context).settingsImperialLabel))
                      ],
                    )
                  ],
                ),
              ]),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text(S.of(context).dialogOKLabel))
              ]);
        });
    if (shouldUpdate == true) {
      _settingsBloc
          .setUsesImperialUnits(selectedUnit == SystemDropDownType.imperial);
      _settingsBloc.add(LoadSettingsEvent());

      // Update blocs
      _profileBloc.add(LoadProfileEvent());
      _homeBloc.add(LoadItemsEvent());
      _diaryBloc.add(const LoadDiaryYearEvent());
    }
  }

  void _showCalculationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CalculationsDialog(
        settingsBloc: _settingsBloc,
        profileBloc: _profileBloc,
        homeBloc: _homeBloc,
        diaryBloc: _diaryBloc,
        calendarDayBloc: _calendarDayBloc,
      ),
    );
  }

  void _showExportImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExportImportDialog(),
    );
  }

  void _showThemeDialog(BuildContext context, AppThemeEntity currentAppTheme) {
    AppThemeEntity selectedTheme = currentAppTheme;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            title: Text(S.of(context).settingsThemeLabel),
            content: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile(
                      title:
                          Text(S.of(context).settingsThemeSystemDefaultLabel),
                      value: AppThemeEntity.system,
                      groupValue: selectedTheme,
                      onChanged: (value) {
                        setState(() {
                          selectedTheme = value as AppThemeEntity;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text(S.of(context).settingsThemeLightLabel),
                      value: AppThemeEntity.light,
                      groupValue: selectedTheme,
                      onChanged: (value) {
                        setState(() {
                          selectedTheme = value as AppThemeEntity;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text(S.of(context).settingsThemeDarkLabel),
                      value: AppThemeEntity.dark,
                      groupValue: selectedTheme,
                      onChanged: (value) {
                        setState(() {
                          selectedTheme = value as AppThemeEntity;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogCancelLabel)),
              TextButton(
                  onPressed: () async {
                    _settingsBloc.setAppTheme(selectedTheme);
                    _settingsBloc.add(LoadSettingsEvent());
                    setState(() {
                      // Update Theme
                      Provider.of<ThemeModeProvider>(context, listen: false)
                          .updateTheme(selectedTheme);
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogOKLabel)),
            ],
          );
        });
  }

  void _showDisclaimerDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return const DisclaimerDialog();
        });
  }

  void _showReportErrorDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.of(context).settingsReportErrorLabel),
            content: Text(S.of(context).reportErrorDialogText),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogCancelLabel)),
              TextButton(
                  onPressed: () async {
                    _reportError(context);
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogOKLabel))
            ],
          );
        });
  }

  Future<void> _reportError(BuildContext context) async {
    final reportUri =
        Uri.parse("mailto:${AppConst.reportErrorEmail}?subject=Report_Error");

    if (await canLaunchUrl(reportUri)) {
      launchUrl(reportUri);
    } else {
      // Cannot open email app, show error snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).errorOpeningEmail)));
      }
    }
  }

  void _showPrivacyDialog(
      BuildContext context, bool hasAcceptedAnonymousData) async {
    bool switchActive = hasAcceptedAnonymousData;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.of(context).settingsPrivacySettings),
            content: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return SwitchListTile(
                  title: Text(S.of(context).sendAnonymousUserData),
                  value: switchActive,
                  onChanged: (bool value) {
                    setState(() {
                      switchActive = value;
                    });
                  },
                );
              },
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogCancelLabel)),
              TextButton(
                  onPressed: () async {
                    _settingsBloc.setHasAcceptedAnonymousData(switchActive);
                    if (!switchActive) Sentry.close();
                    _settingsBloc.add(LoadSettingsEvent());
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogOKLabel))
            ],
          );
        });
  }

  void _showAboutDialog(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (context.mounted) {
      showAboutDialog(
          context: context,
          applicationName: "CalorieAI",
          applicationIcon: SizedBox(
              width: 40, child: Image.asset('assets/icon/calorieai_logo.png')),
          applicationVersion: packageInfo.version,
          applicationLegalese: S.of(context).appLicenseLabel,
          children: [
            TextButton(
                onPressed: () {
                  _launchSourceCodeUrl(context);
                },
                child: Row(
                  children: [
                    const Icon(Icons.code_outlined),
                    const SizedBox(width: 8.0),
                    Text(S.of(context).settingsSourceCodeLabel),
                  ],
                )),
            TextButton(
                onPressed: () {
                  _launchPrivacyPolicyUrl(context);
                },
                child: Row(
                  children: [
                    const Icon(Icons.policy_outlined),
                    const SizedBox(width: 8.0),
                    Text(S.of(context).privacyPolicyLabel),
                  ],
                )),
            TextButton(
                onPressed: () {
                  _launchTermsOfUseUrl(context);
                },
                child: Row(
                  children: [
                    const Icon(Icons.policy_outlined),
                    const SizedBox(width: 8.0),
                    Text(S.of(context).termsOfUseLabel),
                  ],
                )),
          ]);
    }
  }

  void _launchSourceCodeUrl(BuildContext context) async {
    final sourceCodeUri = Uri.parse(AppConst.sourceCodeUrl);
    _launchUrl(context, sourceCodeUri);
  }

  void _navigateToReferencesScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ReferencesScreen(),
      ),
    );
  }

  void _launchPrivacyPolicyUrl(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MarkdownViewerScreen(
          assetPath: 'assets/datenschutzerklaerung.md',
          title: 'Privacy Policy',
        ),
      ),
    );
  }

  void _launchTermsOfUseUrl(BuildContext context) {
   final sourceCodeUri = Uri.parse(AppConst.termsOfUseUrl);
    _launchUrl(context, sourceCodeUri);
  }

  void _launchUrl(BuildContext context, Uri url) async {
    if (await canLaunchUrl(url)) {
      launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Cannot open browser app, show error snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).errorOpeningBrowser)));
      }
    }
  }
}
