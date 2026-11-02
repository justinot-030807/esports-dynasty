import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/tournament.dart';
import '../../models/game_event.dart';
import '../../services/save_service.dart';
import '../../services/data_service.dart';
import '../../services/training_engine.dart';
import '../../services/finance_service.dart';
import '../../services/tournament_service.dart';
import '../../services/event_service.dart';
import '../../services/transfer_service.dart';
import '../../services/academy_service.dart';
import '../../services/achievement_service.dart';
import '../../services/audio_manager.dart';
import '../../services/settings_service.dart';
import '../../services/legacy_service.dart';
import '../dialogs/final_evaluation_dialog.dart';
import '../widgets/top_bar.dart';
import '../widgets/news_ticker.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/tutorial_banner.dart';
import '../dialogs/debug_menu_dialog.dart';
import '../dialogs/monthly_report_dialog.dart';
import '../dialogs/match_prep_dialog.dart';
import '../dialogs/awards_night_dialog.dart';
import '../dialogs/more_menu_sheet.dart';
import '../dialogs/event_dialog.dart';
import '../dialogs/divisions_dialog.dart';
import '../dialogs/bankruptcy_dialog.dart';
import '../widgets/division_switcher_bar.dart';
import 'house_view.dart';
import 'hub_house_asset_loader.dart';
import 'tabs/team_tab.dart';
import 'tabs/plan_tab.dart';
import 'tabs/build_tab.dart';
import 'tabs/compete_tab.dart';

class HubScreen extends StatefulWidget {
  final GameState state;

  const HubScreen({
    super.key,
    required this.state,
  });

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  NavTab? _activeOverlayTab;
  Timer? _gameLoopTimer;
  double _dayAccumulator = 0.0;
  int _logoTapCounter = 0;
  HubHouseAssets? _assets;

  @override
  void initState() {
    super.initState();
    _loadAssets();
    _startGameLoop();
  }

  Future<void> _loadAssets() async {
    try {
      final loaded = await HubHouseAssets.load();
      if (mounted) setState(() => _assets = loaded);
    } catch (_) {}
  }

  void _startGameLoop() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _onGameTick(0.05);
    });
  }

  void _onGameTick(double dt) {
    if (widget.state.speedMultiplier == 0) return;

    final secondsPerWeek = 8.0 / widget.state.speedMultiplier;
    final secondsPerDay = secondsPerWeek / 7.0;

    _dayAccumulator += dt;
    if (_dayAccumulator >= secondsPerDay) {
      _dayAccumulator -= secondsPerDay;
      final oldWeek = widget.state.week;
      final oldMonth = widget.state.month;
      widget.state.advanceDay();

      // Day 2 Random Event Check
      if (widget.state.day == 2) {
        final evt = EventService().checkForWeeklyEvent(widget.state);
        if (evt != null) {
          if (SettingsService().current.pauseOnEvents) widget.state.speedMultiplier = 0;
          AudioManager().playSfx(AudioSfx.popup);
          _showEventDialog(evt);
        }
      }

      // Day 3 AI Transfer Poach check during window
      if (widget.state.day == 3 && widget.state.isTransferWindowOpen) {
        TransferService().checkForAiPoachOffer(widget.state);
      }

      // Day 5 Match Day Check
      if (widget.state.day == 5) {
        final match = TournamentService.getScheduledUserMatch(widget.state);
        if (match != null && !match.isPlayed) {
          if (SettingsService().current.pauseOnMatchDay) widget.state.speedMultiplier = 0;
          AudioManager().playSfx(AudioSfx.popup);
          _showMatchDayPrompt(match);
        }
      }

      // W48 Day 7 Awards Night Check
      if (widget.state.weekOfYear == 48 && widget.state.day == 7) {
        widget.state.speedMultiplier = 0;
        _showAwardsNight();
      }

      // Weekly rollover
      if (widget.state.week != oldWeek) {
        _onWeekEnd();
      }

      // Monthly rollover
      if (widget.state.month != oldMonth) {
        _onMonthEnd();
      }

      if (mounted) setState(() {});
    }
  }

  void _onWeekEnd() {
    AudioManager().playSfx(AudioSfx.weekTick);
    TrainingEngine.processWeek(widget.state);
    FinanceService.processWeeklyFinances(widget.state);
    TournamentService.processWeeklyTournaments(widget.state);

    TransferService().tickWeeklyContracts(widget.state);
    EventService().tickWeeklyCooldowns(widget.state);
    AchievementService().checkMilestones(widget.state);
    AcademyService().checkAcademyProspect(widget.state);

    if (widget.state.consecutiveNegativeWeeks == 4 || widget.state.consecutiveNegativeWeeks >= 6) {
      widget.state.speedMultiplier = 0;
      AudioManager().playSfx(AudioSfx.popup);
      _showBankruptcyDialog();
    }

    SaveService.saveGame(widget.state);
  }

  void _onMonthEnd() {
    final report = FinanceService.generateMonthlyReport(widget.state);
    SaveService.saveGame(widget.state);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MonthlyReportDialog(report: report),
    );
  }

  void _showEventDialog(NarrativeEvent evt) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EventDialog(
        state: widget.state,
        event: evt,
        onDismissed: () {
          if (mounted) setState(() {});
          SaveService.saveGame(widget.state);
        },
      ),
    );
  }

  void _showMatchDayPrompt(MatchNode match) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MatchPrepDialog(
        state: widget.state,
        match: match,
        onMatchCompleted: () {
          setState(() {});
          SaveService.saveGame(widget.state);
        },
      ),
    );
  }

  void _showBankruptcyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BankruptcyDialog(
        state: widget.state,
        onStateUpdated: () => setState(() {}),
        onOpenBuildMode: () => setState(() => _activeOverlayTab = NavTab.build),
        onOpenTransfers: () => setState(() => _activeOverlayTab = NavTab.team),
        onReloadSave: () async {
          final loaded = await SaveService.loadGame();
          setState(() {
            widget.state.money = loaded?.money ?? 25000;
            widget.state.consecutiveNegativeWeeks = 0;
          });
        },
      ),
    );
  }

  void _showAwardsNight() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AwardsNightDialog(state: widget.state),
    ).then((_) {
      if (widget.state.year >= 10 && !widget.state.year10Evaluated) {
        _showYear10Evaluation();
      } else if (mounted) {
        setState(() {});
      }
    });
  }

  void _showYear10Evaluation() {
    widget.state.year10Evaluated = true;
    final eval = LegacyService().evaluateYear10(widget.state);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => FinalEvaluationDialog(
        state: widget.state,
        evaluation: eval,
        onContinueEndless: () {
          widget.state.isEndlessMode = true;
          SaveService.saveGame(widget.state);
          if (mounted) setState(() {});
        },
      ),
    );
  }

  void _onSpeedChanged(int speed) => setState(() => widget.state.speedMultiplier = speed);

  void _onLogoTapped() {
    if (++_logoTapCounter >= 7) {
      _logoTapCounter = 0;
      _openDebugMenu();
    }
  }

  void _openDebugMenu() {
    showDialog(
      context: context,
      builder: (_) => DebugMenuDialog(
        state: widget.state,
        onStateUpdated: () {
          setState(() {});
          SaveService.saveGame(widget.state);
        },
      ),
    );
  }

  void _onTabSelected(NavTab tab) {
    if (tab == _activeOverlayTab) {
      setState(() => _activeOverlayTab = null);
      return;
    }

    if (tab == NavTab.more) {
      _showMoreMenu();
      return;
    }

    setState(() {
      _activeOverlayTab = tab;
    });
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.darkNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        side: BorderSide(color: AppConstants.moneyGold, width: 2),
      ),
      builder: (context) => MoreMenuSheet(
        state: widget.state,
        onStateUpdated: () => setState(() {}),
      ),
    );
  }

  void _openDivisionsDialog() {
    showDialog(
      context: context,
      builder: (_) => DivisionsDialog(
        state: widget.state,
        onStateUpdated: () => setState(() {}),
      ),
    );
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final news = DataService().newsTicker;

    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              state: widget.state,
              onSpeedChanged: _onSpeedChanged,
              onLogoTapped: _onLogoTapped,
            ),
            NewsTicker(newsItems: news),
            DivisionSwitcherBar(
              state: widget.state,
              onDivisionChanged: () => setState(() {}),
              onOpenManageDivisions: _openDivisionsDialog,
            ),
            TutorialBanner(
              tutorial: widget.state.tutorial,
              onDismiss: () => setState(() => widget.state.tutorial.step++),
              onSkip: () => setState(() => widget.state.tutorial.isSkipped = true),
            ),
            Expanded(
              child: Stack(
                children: [
                  _assets != null
                      ? HouseView(
                          state: widget.state,
                          charIdle: _assets!.charIdle, charStep1: _assets!.charStep1, charStep2: _assets!.charStep2,
                          deskImage: _assets!.deskImage, bedImage: _assets!.bedImage,
                          kitchenImage: _assets!.kitchenImage, shelfImage: _assets!.shelfImage, roomBg: _assets!.roomBg,
                        )
                      : const Center(
                          child: CircularProgressIndicator(color: AppConstants.moneyGold),
                        ),
                  if (_activeOverlayTab != null)
                    Positioned.fill(
                      child: Container(
                        color: AppConstants.bgDark,
                        child: Column(
                          children: [
                            Container(
                              height: 36,
                              color: AppConstants.darkNavy,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _activeOverlayTab!.name.toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: AppConstants.pixelFont,
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.moneyGold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => _activeOverlayTab = null),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppConstants.negativeRed,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'RETURN TO HOUSE',
                                        style: TextStyle(
                                          fontFamily: AppConstants.pixelFont,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(child: _buildActiveTab()),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            BottomNav(
              currentTab: _activeOverlayTab ?? NavTab.build,
              onTabSelected: _onTabSelected,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTab() {
    switch (_activeOverlayTab) {
      case NavTab.team:
        return TeamTab(state: widget.state, onStateUpdated: () => setState(() {}));
      case NavTab.plan:
        return PlanTab(state: widget.state, onPlanUpdated: () => setState(() {}));
      case NavTab.build:
        return BuildTab(state: widget.state, onStateUpdated: () => setState(() {}));
      case NavTab.compete:
        return CompeteTab(state: widget.state, onStateUpdated: () => setState(() {}));
      default:
        return const SizedBox.shrink();
    }
  }
}
