import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/division.dart';
import '../../models/tournament.dart';
import '../../models/ai_team.dart';
import '../../models/staff.dart';
import '../../services/data_service.dart';
import '../../services/match_sim_engine.dart';
import '../../services/bracket_engine.dart';
import '../screens/broadcast_match_screen.dart';
import '../widgets/match_prep_views.dart';
import 'match_result_dialog.dart';
import 'rival_showdown_dialog.dart';

class MatchPrepDialog extends StatefulWidget {
  final GameState state;
  final MatchNode match;
  final VoidCallback onMatchCompleted;

  const MatchPrepDialog({
    super.key,
    required this.state,
    required this.match,
    required this.onMatchCompleted,
  });

  @override
  State<MatchPrepDialog> createState() => _MatchPrepDialogState();
}

class _MatchPrepDialogState extends State<MatchPrepDialog> {
  String _selectedStrategy = 'Teamfight';
  late bool _isCoachMode;
  bool _showdownShown = false;

  @override
  void initState() {
    super.initState();
    final div = EsportsDivision.getById(_tournamentDef.division);
    _selectedStrategy = div.strategies.first;
    final opp = _opponent;
    final isImportant = widget.match.roundName.contains('Final') ||
        widget.match.roundName.contains('Semi') ||
        widget.match.bestOf >= 5 ||
        (opp.catchphrase != null && opp.catchphrase!.isNotEmpty);
    _isCoachMode = isImportant;
  }

  AiTeam get _opponent {
    final oppSlot = widget.match.slotA.teamId == 'user_team'
        ? widget.match.slotB
        : widget.match.slotA;

    return DataService().findTeam(oppSlot.teamId) ??
        AiTeam(
          id: oppSlot.teamId,
          name: oppSlot.teamName,
          tier: 1,
          region: 'NCR',
          colors: ['#4A5568', '#E5484D'],
          rating: 38,
          style: 'Rush',
          captain: 'Rival Captain',
          catchphrase: 'Hindi kayo mananalo sa amin!',
        );
  }

  TournamentDef get _tournamentDef {
    return DataService().findTournament(widget.match.tournamentId) ??
        TournamentDef(
          id: widget.match.tournamentId,
          name: 'Tournament Match',
          tier: 1,
          division: 'arena_clash',
          startWeek: 1,
          endWeek: 2,
          regOpenOffset: -4,
          regCloseOffset: -1,
          minFame: 0,
          maxFame: 999999,
          entryFee: 0,
          travelCost: 0,
          slots: 8,
          stages: [],
          championPrize: 10000,
          championFame: 50,
          championFans: 300,
          circuitPoints: 100,
          trophy: 'trophy_bronze_t1',
          banner: 'banner_t1',
        );
  }

  void _triggerShowdownModal() {
    final opp = _opponent;
    final captain = widget.state.starters.firstOrNull?.gamerTag ?? 'Captain Ace';
    showDialog(
      context: context,
      builder: (ctx) => RivalShowdownDialog(
        opponent: opp,
        userTeamName: widget.state.teamName,
        userCaptainName: captain,
        onProceed: () => _launchBroadcastScreen(),
      ),
    );
  }

  void _launchBroadcastScreen() {
    final opp = _opponent;
    final def = _tournamentDef;

    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => BroadcastMatchScreen(
          state: widget.state,
          opponent: opp,
          match: widget.match,
          tournament: def,
          initialStrategy: _selectedStrategy,
          isCoachMode: _isCoachMode,
          onMatchCompleted: widget.onMatchCompleted,
        ),
      ),
    );
  }

  void _runAutoSim() {
    final opponent = _opponent;
    final def = _tournamentDef;
    final patch = DataService().getPatchForWeek(widget.match.week);

    final result = MatchSimEngine.simulateUserSeries(
      state: widget.state,
      opponent: opponent,
      match: widget.match,
      tournament: def,
      userStrategy: _selectedStrategy,
      focusBonus: 1.0,
      patch: patch,
    );

    final inst = widget.state.tournamentInstances.firstWhere((t) => t.tournamentId == def.id);
    BracketEngine.recordMatchOutcome(
      instance: inst,
      tournament: def,
      match: widget.match,
      result: result,
    );

    if (result.isUserVictory && widget.match.roundName == 'Grand Final') {
      if (!widget.state.trophies.contains(def.trophy)) {
        widget.state.trophies.add(def.trophy);
        widget.state.addNotification('CHAMPION TROPHY UNLOCKED!', '#F5B700', 0.5, 0.3);
      }
    }

    Navigator.of(context).pop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MatchResultDialog(
        result: result,
        onClose: widget.onMatchCompleted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opp = _opponent;
    final def = _tournamentDef;
    final div = EsportsDivision.getById(def.division);
    final patch = DataService().getPatchForWeek(widget.match.week);
    final patchMod = patch.getStrategyModifier(_selectedStrategy);
    final analyst = widget.state.staff.where((s) => s.role == StaffRole.analyst).firstOrNull;
    final starters = widget.state.getStartersForDivision(def.division);

    return Dialog(
      backgroundColor: AppConstants.bgDark,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppConstants.moneyGold, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF1B2A49), borderRadius: BorderRadius.circular(4)),
                child: Column(
                  children: [
                    const Text('MATCH DAY - DAY 5', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 13, fontWeight: FontWeight.bold, color: AppConstants.moneyGold, letterSpacing: 1.5)),
                    Text('${def.name} | ${widget.match.roundName} (Bo${widget.match.bestOf})', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // VS Header
              MatchPrepVersusHeader(
                userTeamName: widget.state.teamName,
                startersCount: starters.length,
                squadSize: div.squadSize,
                opponent: opp,
              ),
              const SizedBox(height: 8),

              // Rival Showdown Banner (if flagship)
              if (opp.catchphrase != null && opp.catchphrase!.isNotEmpty)
                InkWell(
                  onTap: _triggerShowdownModal,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF2B1D3A), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppConstants.fansPink)),
                    child: Row(
                      children: [
                        const Icon(Icons.flash_on, color: AppConstants.fansPink, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'RIVAL: "${opp.catchphrase}" - ${opp.captain ?? 'Captain'}',
                            style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, fontStyle: FontStyle.italic, color: Colors.white),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white54, size: 14),
                      ],
                    ),
                  ),
                ),

              // Patch Meta Card
              Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(color: const Color(0xFF142436), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF253B58))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Patch ${patch.version}: ${patch.name}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white70)),
                    Text(
                      patchMod > 0 ? '+3 META BONUS' : (patchMod < 0 ? '-3 META PENALTY' : '0 META EFFECT'),
                      style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, fontWeight: FontWeight.bold, color: patchMod > 0 ? AppConstants.positiveGreen : (patchMod < 0 ? AppConstants.negativeRed : Colors.white60)),
                    ),
                  ],
                ),
              ),

              // Analyst Scouting Report
              MatchPrepAnalystReport(
                analyst: analyst,
                opponentStyle: opp.style,
              ),
              const SizedBox(height: 8),

              // Strategy Selector
              MatchPrepStrategySelector(
                selectedStrategy: _selectedStrategy,
                strategies: div.strategies,
                onStrategySelected: (strat) => setState(() => _selectedStrategy = strat),
              ),
              const SizedBox(height: 8),

              // Mode Toggle (Coach Mode vs Auto Mode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF142036), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('COACH MODE (FOCUS METER)', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(_isCoachMode ? 'Interactive key moments' : 'Auto resolves key moments', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 7, color: Colors.white60)),
                      ],
                    ),
                    Switch(
                      value: _isCoachMode,
                      activeThumbColor: AppConstants.moneyGold,
                      onChanged: (val) => setState(() => _isCoachMode = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action Buttons
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.positiveGreen,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.tv, color: Colors.white, size: 16),
                label: const Text('ENTER BROADCAST ARENA', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                onPressed: () {
                  if (opp.catchphrase != null && opp.catchphrase!.isNotEmpty && !_showdownShown) {
                    _showdownShown = true;
                    _triggerShowdownModal();
                  } else {
                    _launchBroadcastScreen();
                  }
                },
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                icon: const Icon(Icons.flash_on, size: 14),
                label: const Text('FAST AUTO-SIM (SKIP)', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9)),
                onPressed: _runAutoSim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
