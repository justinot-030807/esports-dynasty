import 'game_state.dart';
import 'player.dart';
import 'staff.dart';

extension GameStateCombos on GameState {
  String get dateString => 'Y$year M$month W$week';
  int get weekOfYear => ((month - 1) * 4 + week).clamp(1, 48);

  double get incomeDifficultyMultiplier {
    if (difficulty == 'easy') return 1.25;
    if (difficulty == 'hard') return 0.80;
    return 1.0;
  }

  int get maxRosterCap => [6, 8, 10, 12, 15][houseTier.clamp(0, 4)];
  int get maxStaffSlots => [1, 2, 3, 5, 6][houseTier.clamp(0, 4)];
  int get monthlyRent => [2000, 8000, 30000, 150000, 800000][houseTier.clamp(0, 4)];
  int get maxSponsorSlots => (1 + (fame / 800).floor()).clamp(1, 6);

  List<Player> get starters => getStartersForDivision(activeDivisionId);
  List<Player> get allStarters => players.where((p) => p.isStarter).toList();
  List<Player> get subs => players.where((p) => p.divisionId == activeDivisionId && !p.isStarter).toList();
  List<Player> get allSubs => players.where((p) => !p.isStarter).toList();

  int get pcDeskCapacity => furniture.where((f) => f.station == 'pc').length;
  int get bedCapacity => furniture.where((f) => f.station == 'bed').length * 2;
  int get kitchenCount => furniture.where((f) => f.station == 'kitchen').length;

  // Active Combos & Facilities
  bool get hasScrimRoomCombo => pcDeskCapacity >= 5;
  bool get hasKainanCombo => furniture.any((f) => f.itemId == 'dining_table') && kitchenCount > 0;
  bool get hasChillLoungeCombo => furniture.any((f) => f.itemId == 'lounge_sofa');
  bool get hasHighTechCombo => hasGenerator && hasRouter;

  bool get hasGenerator => furniture.any((f) => f.itemId == 'generator');
  bool get hasRouter => furniture.any((f) => f.itemId == 'fiber_router');
  bool get hasAircon => furniture.any((f) => f.itemId == 'aircon');

  // Staff query helpers
  StaffMember? get coach => staff.cast<StaffMember?>().firstWhere((s) => s?.role == StaffRole.coach, orElse: () => null);
  StaffMember? get analyst => staff.cast<StaffMember?>().firstWhere((s) => s?.role == StaffRole.analyst, orElse: () => null);
  StaffMember? get manager => staff.cast<StaffMember?>().firstWhere((s) => s?.role == StaffRole.manager, orElse: () => null);
  StaffMember? get psychologist => staff.cast<StaffMember?>().firstWhere((s) => s?.role == StaffRole.psychologist, orElse: () => null);
  StaffMember? get cook => staff.cast<StaffMember?>().firstWhere((s) => s?.role == StaffRole.cook, orElse: () => null);
  StaffMember? get streamProducer => staff.cast<StaffMember?>().firstWhere((s) => s?.role == StaffRole.streamProducer, orElse: () => null);

  bool get hasHeadCoach => coach != null;
  bool get hasAnalyst => analyst != null;
  bool get hasManager => manager != null;
  bool get hasPsychologist => psychologist != null;
  bool get hasCook => cook != null;
  bool get hasStreamProducer => streamProducer != null;

  bool get isTransferWindowOpen => (weekOfYear >= 1 && weekOfYear <= 2) || (weekOfYear >= 25 && weekOfYear <= 26);
  bool get isAcademyUnlocked => houseTier >= 3;

  int get comfortRating {
    int score = 1;
    if (bedCapacity >= players.length) score++;
    if (kitchenCount > 0) score++;
    if (hasChillLoungeCombo || hasAircon) score++;
    if (hasScrimRoomCombo || hasKainanCombo) score++;
    return score.clamp(1, 5);
  }

  int get chemistry {
    final curStarters = starters;
    if (curStarters.isEmpty) return 50;
    final avgTeamwork = curStarters.map((p) => p.teamwork).reduce((a, b) => a + b) / curStarters.length;
    int chem = (avgTeamwork * 0.8).round();
    if (hasChillLoungeCombo) chem += 5;
    if (hasKainanCombo) chem += 5;
    if (hasScrimRoomCombo) chem += 5;
    if (storyFlags['team_chemistry_boost'] == true) chem += 10;
    return chem.clamp(10, 100);
  }

  void progressSponsors(String goalType, int amount) {
    for (final sp in activeSponsors) {
      if (sp.goalType == goalType) {
        sp.addProgress(amount);
      }
    }
  }
}
