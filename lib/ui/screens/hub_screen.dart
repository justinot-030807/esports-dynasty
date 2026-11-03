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
import '../dialogs/monthly_report_dialog.dart';
import '../dialogs/match_prep_dialog.dart';
import '../dialogs/awards_night_dialog.dart';
import '../dialogs/more_menu_sheet.dart';
import '../dialogs/event_dialog.dart';
import '../dialogs/divisions_dialog.dart';
import '../dialogs/bankruptcy_dialog.dart';
import '../dialogs/prologue_dialog.dart';
import '../widgets/division_switcher_bar.dart';
import 'house_view.dart';
import 'hub_house_asset_loader.dart';
import 'tabs/team_tab.dart';
import 'tabs/plan_tab.dart';
import 'tabs/build_tab.dart';
import 'tabs/compete_tab.dart';

class HubScreen extends StatefulWidget {
  final GameState state;
  const HubScreen({super.key, required this.state});

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  NavTab? _activeOverlayTab;
  Timer? _gameLoopTimer;
  double _dayAccumulator = 0.0;
  int _activeSpeed = 1;
  HubHouseAssets? _assets;

  @override
  void initState() {
    super.initState();
    if (widget.state.speedMultiplier == 0) widget.state.speedMultiplier = 1;
    _activeSpeed = widget.state.speedMultiplier;
    _loadAssets();
    _startGameLoop();

    if (widget.state.storyFlags['prologue_seen'] != true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pauseForModal();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => PrologueDialog(
            state: widget.state,
            onComplete: () {
              Navigator.of(context).pop();
              _resumeAfterModal();
            },
          ),
        );
      });
    }
  }

  Future<void> _loadAssets() async {
    try {
      final loaded = await HubHouseAssets.load();
      if (mounted) setState(() => _assets = loaded);
    } catch (_) {}
  }

  void _startGameLoop() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 50), (_) => _onGameTick(0.05));
  }

  void _pauseForModal() {
    if (widget.state.speedMultiplier > 0) _activeSpeed = widget.state.speedMultiplier;
    widget.state.speedMultiplier = 0;
  }

  void _resumeAfterModal() {
    if (mounted) {
      setState(() => widget.state.speedMultiplier = _activeSpeed > 0 ? _activeSpeed : 1);
      SaveService.saveGame(widget.state);
    }
  }

  void _onGameTick(double dt) {
    if (widget.state.speedMultiplier == 0) return;
    // Calibrated pacing: ~3.5s per day at 1x (24.5s/wk), 1.75s at 2x, 0.87s at 4x
    final secondsPerDay = (24.5 / widget.state.speedMultiplier) / 7.0;

    _dayAccumulator += dt;
    if (_dayAccumulator >= secondsPerDay) {
      _dayAccumulator -= secondsPerDay;
      final oldWeek = widget.state.week;
      final oldMonth = widget.state.month;
      widget.state.advanceDay();

      // Day 2 Random Event
      if (widget.state.day == 2) {
        final evt = EventService().checkForWeeklyEvent(widget.state);
        if (evt != null) {
          if (SettingsService().current.pauseOnEvents) _pauseForModal();
          AudioManager().playSfx(AudioSfx.popup);
          _showEventDialog(evt);
        }
      }

      // Day 3 AI Transfer Poach
      if (widget.state.day == 3 && widget.state.isTransferWindowOpen) {
        TransferService().checkForAiPoachOffer(widget.state);
      }

      // Day 5 Match Day
      if (widget.state.day == 5) {
        final match = TournamentService.getScheduledUserMatch(widget.state);
        if (match != null && !match.isPlayed) {
          if (SettingsService().current.pauseOnMatchDay) _pauseForModal();
          AudioManager().playSfx(AudioSfx.popup);
          _showMatchDayPrompt(match);
        }
      }

      // W48 Day 7 Awards Night
      if (widget.state.weekOfYear == 48 && widget.state.day == 7) {
        _pauseForModal();
        _showAwardsNight();
      }

      if (widget.state.week != oldWeek) _onWeekEnd();
      if (widget.state.month != oldMonth) _onMonthEnd();
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
      _pauseForModal();
      AudioManager().playSfx(AudioSfx.popup);
      _showBankruptcyDialog();
    }
    SaveService.saveGame(widget.state);
  }

  void _onMonthEnd() {
    _pauseForModal();
    final report = FinanceService.generateMonthlyReport(widget.state);
    SaveService.saveGame(widget.state);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MonthlyReportDialog(report: report),
    ).then((_) => _resumeAfterModal());
  }

  void _showEventDialog(NarrativeEvent evt) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EventDialog(state: widget.state, event: evt, onDismissed: _resumeAfterModal),
    );
  }

  void _showMatchDayPrompt(MatchNode match) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MatchPrepDialog(state: widget.state, match: match, onMatchCompleted: _resumeAfterModal),
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
    ).then((_) => _resumeAfterModal());
  }

  void _showAwardsNight() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AwardsNightDialog(state: widget.state),
    ).then((_) {
      if (widget.state.year >= 10 && !widget.state.year10Evaluated) {
        _showYear10Evaluation();
      } else {
        _resumeAfterModal();
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
          _resumeAfterModal();
        },
      ),
    );
  }

  void _onSpeedChanged(int speed) {
    setState(() {
      _activeSpeed = speed;
      widget.state.speedMultiplier = speed;
    });
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
    setState(() => _activeOverlayTab = tab);
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.panelLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        side: BorderSide(color: AppConstants.moneyGold, width: 2),
      ),
      builder: (context) => MoreMenuSheet(state: widget.state, onStateUpdated: () => setState(() {})),
    );
  }

  void _openDivisionsDialog() {
    showDialog(
      context: context,
      builder: (_) => DivisionsDialog(state: widget.state, onStateUpdated: () => setState(() {})),
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
            TopBar(state: widget.state, onSpeedChanged: _onSpeedChanged, onLogoTapped: () {}),
            NewsTicker(newsItems: news),
            DivisionSwitcherBar(state: widget.state, onDivisionChanged: () => setState(() {}), onOpenManageDivisions: _openDivisionsDialog),
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
                          foodImage: _assets!.foodImage,
                          stationImages: _assets!.stationImages,
                        )
                      : const Center(child: CircularProgressIndicator(color: AppConstants.moneyGold)),
                  if (_activeOverlayTab != null)
                    Positioned.fill(
                      child: Container(
                        color: AppConstants.bgDark,
                        child: Column(
                          children: [
                            Container(
                              height: 42,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1.5)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _activeOverlayTab!.name.toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: AppConstants.pixelFont,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                      fontSize: 16,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => _activeOverlayTab = null),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(color: AppConstants.negativeRed, borderRadius: BorderRadius.circular(5)),
                                      child: const Text(
                                        'RETURN TO HOUSE',
                                        style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
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
            BottomNav(currentTab: _activeOverlayTab, onTabSelected: _onTabSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTab() {
    switch (_activeOverlayTab) {
      case NavTab.team: return TeamTab(state: widget.state, onStateUpdated: () => setState(() {}));
      case NavTab.plan: return PlanTab(state: widget.state, onPlanUpdated: () => setState(() {}));
      case NavTab.build: return BuildTab(state: widget.state, onStateUpdated: () => setState(() {}));
      case NavTab.compete: return CompeteTab(state: widget.state, onStateUpdated: () => setState(() {}));
      default: return const SizedBox.shrink();
    }
  }
}
