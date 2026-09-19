import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:calorieai/core/domain/entity/physical_activity_entity.dart';
import 'package:calorieai/core/domain/entity/user_entity.dart';
import 'package:calorieai/core/utils/locator.dart';
import 'package:calorieai/core/utils/navigation_options.dart';
import 'package:calorieai/features/activity_detail/presentation/bloc/activity_detail_bloc.dart';
import 'package:calorieai/features/activity_detail/presentation/widget/activity_detail_bottom_sheet.dart';
import 'package:calorieai/features/activity_detail/presentation/widget/activity_info_button.dart';
import 'package:calorieai/features/activity_detail/presentation/widget/activity_title_expanded.dart';
import 'package:calorieai/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:calorieai/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:calorieai/features/home/presentation/bloc/home_bloc.dart';
import 'package:calorieai/l10n/app_localizations.dart';
typedef S = AppLocalizations;
class ActivityDetailScreen extends StatefulWidget {
  const ActivityDetailScreen({super.key});

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  static const _containerSize = 250.0;

  final log = Logger('ItemDetailScreen');
  final _scrollController = ScrollController();

  late PhysicalActivityEntity activityEntity;
  late DateTime _day;
  late TextEditingController quantityTextController;
  late TextEditingController noteTextController;

  late ActivityDetailBloc _activityDetailBloc;

  late double totalQuantity;
  late double totalKcal;
  bool get isManualEntry => activityEntity.code == '99999';

  @override
  void initState() {
    _activityDetailBloc = locator<ActivityDetailBloc>();
    quantityTextController = TextEditingController();
    quantityTextController.text = "0";
    noteTextController = TextEditingController();
    totalQuantity = 0; // TODO change to 60
    totalKcal = 0;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final args = ModalRoute.of(context)?.settings.arguments
        as ActivityDetailScreenArguments;
    activityEntity = args.activityEntity;
    _day = args.day;
    quantityTextController.addListener(() {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ActivityDetailBloc, ActivityDetailState>(
        bloc: _activityDetailBloc,
        builder: (context, state) {
          if (state is ActivityDetailInitial) {
            _activityDetailBloc
                .add(LoadActivityDetailEvent(context, activityEntity));
            return getLoadingContent();
          } else if (state is ActivityDetailLoadingState) {
            return getLoadingContent();
          } else if (state is ActivityDetailLoadedState) {
            quantityTextController.addListener(() {
              _onQuantityChanged(quantityTextController.text, state.userEntity);
            });
            return getLoadedContent(state.totalKcalBurned, state.userEntity);
          } else {
            return const SizedBox();
          }
        },
      ),
      bottomSheet: ActivityDetailBottomSheet(
        onAddButtonPressed: onAddButtonPressed,
        quantityTextController: quantityTextController,
        activityEntity: activityEntity,
        activityDetailBloc: _activityDetailBloc,
        isManualEntry: isManualEntry,
      ),
    );
  }

  Widget getLoadingContent() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget getLoadedContent(double totalKcalBurned, UserEntity userEntity) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final top = constraints.biggest.height;
                final barsHeight =
                    MediaQuery.of(context).padding.top + kToolbarHeight;
                const offset = 10;
                return FlexibleSpaceBar(
                  expandedTitleScale: 1, // don't scale title
                  background: ActivityTitleExpanded(activity: activityEntity),
                  title: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child:
                        top > barsHeight - offset && top < barsHeight + offset
                            ? Text(activityEntity.getName(context),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface))
                            : const SizedBox(),
                  ),
                );
              },
            )),
        SliverList(
            delegate: SliverChildListDelegate([
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(80),
              child: Container(
                width: _containerSize,
                height: _containerSize,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer),
                child: Icon(
                  activityEntity.displayIcon,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    // set Focus
                    Text('~${totalKcal.toInt()} ${S.of(context).kcalLabel}',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Text(' / ${totalQuantity.toInt()} ${isManualEntry ? S.of(context).kcalLabel : 'min'}')
                  ],
                ),
                const SizedBox(height: 8.0),
                if (isManualEntry)
                  TextField(
                    controller: noteTextController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: S.of(context).manualEntryNameLabel,
                      hintText: S.of(context).manualEntryNameHint,
                    ),
                  ),
                const SizedBox(height: 8.0),
                const Divider(),
                const SizedBox(height: 48.0),
                if (!isManualEntry) const ActivityInfoButton(),
                const SizedBox(height: 200.0) // height added to scroll
              ],
            ),
          )
        ]))
      ],
    );
  }

  void _onQuantityChanged(String quantityString, UserEntity userEntity) async {
    try {
      final newQuantity = double.parse(quantityString);
      double newTotalKcal;
      
      if (isManualEntry) {
        // Manual entry mode: use input directly as kcal
        newTotalKcal = newQuantity;
      } else {
        // Duration mode: calculate kcal from duration
        newTotalKcal = _activityDetailBloc.getTotalKcalBurned(
            userEntity, activityEntity, newQuantity);
      }
      
      setState(() {
        totalQuantity = newQuantity;
        totalKcal = newTotalKcal;
        scrollToCalorieText();
      });
    } on FormatException catch (_) {
      log.warning("Error while parsing: \"$quantityString\"");
    }
  }

  void scrollToCalorieText() {
    _scrollController.animateTo(_containerSize,
        duration: const Duration(seconds: 1), curve: Curves.easeInOut);
  }

  Future<void> onAddButtonPressed(BuildContext context) async {
    final note = isManualEntry ? noteTextController.text : null;
    await _activityDetailBloc.persistActivity(
        context, quantityTextController.text, totalKcal, activityEntity, _day, note);

    // Refresh Home Page
    locator<HomeBloc>().add(const LoadItemsEvent());

    // Refresh Diary Page
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

    if (!context.mounted) return;

    // Show snackbar and return to dashboard
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).infoAddedActivityLabel)));
    Navigator.of(context)
        .popUntil(ModalRoute.withName(NavigationOptions.mainRoute));
  }
}

class ActivityDetailScreenArguments {
  final PhysicalActivityEntity activityEntity;
  final DateTime day;

  ActivityDetailScreenArguments(this.activityEntity, this.day);
}
