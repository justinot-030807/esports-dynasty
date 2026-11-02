import 'player.dart';
import 'placed_furniture.dart';
import 'staff.dart';
import 'weekly_plan.dart';
import 'finance_record.dart';
import 'tutorial_state.dart';
import 'tournament.dart';
import 'hall_of_fame.dart';
import 'sponsor.dart';
import 'transfer_deal.dart';
import 'game_state_defaults.dart';
import 'floating_notification.dart';

export 'floating_notification.dart';
export 'game_state_combos.dart';
export 'game_state_divisions.dart';

class GameState {
  String teamName;
  String ownerName;
  String primaryColorHex;
  String secondaryColorHex;
  String emblemSymbol;
  String emblemLetters;
  String difficulty; // 'easy', 'normal', 'hard'

  // Calendar time
  int year;
  int month;
  int week;
  int day;
  int totalWeeksPassed;

  // Currencies
  int money;
  int fame;
  int fans;
  int circuitPoints;

  // Infrastructure & People
  int houseTier;
  List<PlacedFurniture> furniture;
  List<Player> players;
  List<StaffMember> staff;
  WeeklyPlan currentPlan;
  TutorialState tutorial;
  List<Player> freeAgents;
  List<TournamentInstance> tournamentInstances;
  List<String> trophies;
  List<HallOfFameRecord> hallOfFame;

  // Sponsors & Depth
  List<ActiveSponsor> activeSponsors;
  List<String> unlockedAchievements;
  List<String> claimedAchievements;
  Map<String, dynamic> storyFlags;
  Map<String, int> eventCooldowns;
  List<TransferOffer> pendingTransferOffers;
  int lastAcademyWeek;

  // Legacy & NG+
  int legacyPoints;
  bool isEndlessMode;
  bool year10Evaluated;
  List<String> activeLegacyPerks;

  // Multi-Division Expansion (Phase 8)
  String activeDivisionId;
  List<String> unlockedDivisions;
  Map<String, int> divisionCircuitPoints;

  // Streak & Financial Safety (Phase 6 Polish)
  int consecutiveWins;
  int consecutiveNegativeWeeks;

  // Finances
  int monthIncome;
  int monthExpenses;
  int monthPlayerSalaries;
  int monthStaffSalaries;
  int monthRent;
  MonthlyFinanceReport? lastMonthlyReport;

  // Speed controls: 0 = paused, 1 = 1x, 2 = 2x, 4 = 4x
  int speedMultiplier;

  // Runtime notifications
  final List<FloatingNotification> activeNotifications = [];

  GameState({
    this.teamName = 'Agila Esports',
    this.ownerName = 'Boss Juan',
    this.primaryColorHex = '#1B2A49',
    this.secondaryColorHex = '#F5B700',
    this.emblemSymbol = 'lightning',
    this.emblemLetters = 'AE',
    this.difficulty = 'normal',
    this.year = 1,
    this.month = 1,
    this.week = 1,
    this.day = 1,
    this.totalWeeksPassed = 0,
    this.money = 50000,
    this.fame = 0,
    this.fans = 50,
    this.circuitPoints = 0,
    this.houseTier = 0,
    List<PlacedFurniture>? furniture,
    List<Player>? players,
    List<StaffMember>? staff,
    WeeklyPlan? currentPlan,
    TutorialState? tutorial,
    List<Player>? freeAgents,
    List<TournamentInstance>? tournamentInstances,
    List<String>? trophies,
    List<HallOfFameRecord>? hallOfFame,
    List<ActiveSponsor>? activeSponsors,
    List<String>? unlockedAchievements,
    List<String>? claimedAchievements,
    Map<String, dynamic>? storyFlags,
    Map<String, int>? eventCooldowns,
    List<TransferOffer>? pendingTransferOffers,
    this.lastAcademyWeek = 0,
    this.legacyPoints = 0,
    this.isEndlessMode = false,
    this.year10Evaluated = false,
    List<String>? activeLegacyPerks,
    this.activeDivisionId = 'arena_clash',
    List<String>? unlockedDivisions,
    Map<String, int>? divisionCircuitPoints,
    this.consecutiveWins = 0,
    this.consecutiveNegativeWeeks = 0,
    this.monthIncome = 0,
    this.monthExpenses = 0,
    this.monthPlayerSalaries = 0,
    this.monthStaffSalaries = 0,
    this.monthRent = 0,
    this.lastMonthlyReport,
    this.speedMultiplier = 1,
  })  : furniture = furniture ?? [],
        players = players ?? [],
        staff = staff ?? [],
        currentPlan = currentPlan ?? WeeklyPlan(),
        tutorial = tutorial ?? TutorialState(),
        freeAgents = freeAgents ?? [],
        tournamentInstances = tournamentInstances ?? [],
        trophies = trophies ?? [],
        hallOfFame = hallOfFame ?? [],
        activeSponsors = activeSponsors ?? [],
        unlockedAchievements = unlockedAchievements ?? [],
        claimedAchievements = claimedAchievements ?? [],
        storyFlags = storyFlags ?? {},
        eventCooldowns = eventCooldowns ?? {},
        pendingTransferOffers = pendingTransferOffers ?? [],
        activeLegacyPerks = activeLegacyPerks ?? [],
        unlockedDivisions = unlockedDivisions ?? ['arena_clash'],
        divisionCircuitPoints = divisionCircuitPoints ?? {'arena_clash': 0};

  factory GameState.initial({
    required String teamName,
    required String ownerName,
    required String primaryColorHex,
    required String secondaryColorHex,
    required String emblemSymbol,
    required String emblemLetters,
    String difficulty = 'normal',
    List<String> activeLegacyPerks = const [],
  }) {
    int startMoney = 50000;
    if (difficulty == 'easy') startMoney = 65000;
    if (difficulty == 'hard') startMoney = 35000;

    if (activeLegacyPerks.contains('extra_cash_1')) startMoney += 25000;
    if (activeLegacyPerks.contains('extra_cash_2')) startMoney += 50000;

    String finalEmblem = emblemSymbol;
    int initialFame = 0;
    if (activeLegacyPerks.contains('dynasty_emblem')) {
      finalEmblem = 'crown';
      initialFame = 100;
    }

    final initialFurniture = GameStateDefaults.createInitialFurniture();
    if (activeLegacyPerks.contains('comfy_bed')) {
      final bedIdx = initialFurniture.indexWhere((f) => f.station == 'bed');
      if (bedIdx != -1) {
        initialFurniture[bedIdx] = PlacedFurniture(
          id: initialFurniture[bedIdx].id,
          itemId: 'comfy_bed',
          name: 'Comfy Bed',
          station: 'bed',
          tileX: initialFurniture[bedIdx].tileX,
          tileY: initialFurniture[bedIdx].tileY,
          sizeX: 2,
          sizeY: 1,
        );
      }
    }
    if (activeLegacyPerks.contains('pro_desk')) {
      for (int i = 0; i < initialFurniture.length; i++) {
        if (initialFurniture[i].station == 'pc') {
          initialFurniture[i] = PlacedFurniture(
            id: initialFurniture[i].id,
            itemId: 'pro_desk',
            name: 'Pro Gaming Desk',
            station: 'pc',
            tileX: initialFurniture[i].tileX,
            tileY: initialFurniture[i].tileY,
            sizeX: 2,
            sizeY: 1,
          );
        }
      }
    }

    final initialStaff = <StaffMember>[];
    if (activeLegacyPerks.contains('legend_coach')) {
      initialStaff.add(StaffMember(
        id: 'coach',
        name: 'Coach Norman',
        role: StaffRole.coach,
        level: 3,
        salary: 1200,
      ));
    }

    return GameState(
      teamName: teamName,
      ownerName: ownerName,
      primaryColorHex: primaryColorHex,
      secondaryColorHex: secondaryColorHex,
      emblemSymbol: finalEmblem,
      emblemLetters: emblemLetters,
      difficulty: difficulty,
      money: startMoney,
      fame: initialFame,
      activeLegacyPerks: List.from(activeLegacyPerks),
      furniture: initialFurniture,
      staff: initialStaff,
      players: GameStateDefaults.createInitialPlayers(
        primaryColorHex: primaryColorHex,
        secondaryColorHex: secondaryColorHex,
      ),
      currentPlan: GameStateDefaults.createInitialPlan(),
    );
  }

  void advanceDay() {
    day++;
    if (day > 7) {
      day = 1;
      week++;
      totalWeeksPassed++;
      if (week > 4) {
        week = 1;
        month++;
        if (month > 12) {
          month = 1;
          year++;
        }
      }
    }
  }

  void addNotification(String text, String colorHex, double x, double y) {
    activeNotifications.add(
      FloatingNotification(text: text, colorHex: colorHex, posX: x, posY: y),
    );
  }

  Map<String, dynamic> toJson() => {
    'teamName': teamName,
    'ownerName': ownerName,
    'primaryColorHex': primaryColorHex,
    'secondaryColorHex': secondaryColorHex,
    'emblemSymbol': emblemSymbol,
    'emblemLetters': emblemLetters,
    'difficulty': difficulty,
    'year': year,
    'month': month,
    'week': week,
    'day': day,
    'totalWeeksPassed': totalWeeksPassed,
    'money': money,
    'fame': fame,
    'fans': fans,
    'circuitPoints': circuitPoints,
    'houseTier': houseTier,
    'furniture': furniture.map((f) => f.toJson()).toList(),
    'players': players.map((p) => p.toJson()).toList(),
    'staff': staff.map((s) => s.toJson()).toList(),
    'currentPlan': currentPlan.toJson(),
    'tutorial': tutorial.toJson(),
    'freeAgents': freeAgents.map((p) => p.toJson()).toList(),
    'tournamentInstances': tournamentInstances.map((t) => t.toJson()).toList(),
    'trophies': trophies,
    'hallOfFame': hallOfFame.map((h) => h.toJson()).toList(),
    'activeSponsors': activeSponsors.map((s) => s.toJson()).toList(),
    'unlockedAchievements': unlockedAchievements,
    'claimedAchievements': claimedAchievements,
    'storyFlags': storyFlags,
    'eventCooldowns': eventCooldowns,
    'pendingTransferOffers': pendingTransferOffers.map((o) => o.toJson()).toList(),
    'lastAcademyWeek': lastAcademyWeek,
    'legacyPoints': legacyPoints,
    'isEndlessMode': isEndlessMode,
    'year10Evaluated': year10Evaluated,
    'activeLegacyPerks': activeLegacyPerks,
    'activeDivisionId': activeDivisionId,
    'unlockedDivisions': unlockedDivisions,
    'divisionCircuitPoints': divisionCircuitPoints,
    'consecutiveWins': consecutiveWins,
    'consecutiveNegativeWeeks': consecutiveNegativeWeeks,
    'monthIncome': monthIncome,
    'monthExpenses': monthExpenses,
    'monthPlayerSalaries': monthPlayerSalaries,
    'monthStaffSalaries': monthStaffSalaries,
    'monthRent': monthRent,
    'lastMonthlyReport': lastMonthlyReport?.toJson(),
  };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      teamName: json['teamName'] as String? ?? 'Agila Esports',
      ownerName: json['ownerName'] as String? ?? 'Boss Juan',
      primaryColorHex: json['primaryColorHex'] as String? ?? '#1B2A49',
      secondaryColorHex: json['secondaryColorHex'] as String? ?? '#F5B700',
      emblemSymbol: json['emblemSymbol'] as String? ?? 'lightning',
      emblemLetters: json['emblemLetters'] as String? ?? 'AE',
      difficulty: json['difficulty'] as String? ?? 'normal',
      year: (json['year'] as num?)?.toInt() ?? 1,
      month: (json['month'] as num?)?.toInt() ?? 1,
      week: (json['week'] as num?)?.toInt() ?? 1,
      day: (json['day'] as num?)?.toInt() ?? 1,
      totalWeeksPassed: (json['totalWeeksPassed'] as num?)?.toInt() ?? 0,
      money: (json['money'] as num?)?.toInt() ?? 50000,
      fame: (json['fame'] as num?)?.toInt() ?? 0,
      fans: (json['fans'] as num?)?.toInt() ?? 50,
      circuitPoints: (json['circuitPoints'] as num?)?.toInt() ?? 0,
      houseTier: (json['houseTier'] as num?)?.toInt() ?? 0,
      furniture: (json['furniture'] as List<dynamic>? ?? [])
          .map((e) => PlacedFurniture.fromJson(e as Map<String, dynamic>)).toList(),
      players: (json['players'] as List<dynamic>? ?? [])
          .map((e) => Player.fromJson(e as Map<String, dynamic>)).toList(),
      staff: (json['staff'] as List<dynamic>? ?? [])
          .map((e) => StaffMember.fromJson(e as Map<String, dynamic>)).toList(),
      currentPlan: json['currentPlan'] != null
          ? WeeklyPlan.fromJson(json['currentPlan'] as Map<String, dynamic>)
          : WeeklyPlan(),
      tutorial: json['tutorial'] != null
          ? TutorialState.fromJson(json['tutorial'] as Map<String, dynamic>)
          : TutorialState(),
      freeAgents: (json['freeAgents'] as List<dynamic>? ?? [])
          .map((e) => Player.fromJson(e as Map<String, dynamic>)).toList(),
      tournamentInstances: (json['tournamentInstances'] as List<dynamic>? ?? [])
          .map((e) => TournamentInstance.fromJson(e as Map<String, dynamic>)).toList(),
      trophies: (json['trophies'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      hallOfFame: (json['hallOfFame'] as List<dynamic>? ?? [])
          .map((e) => HallOfFameRecord.fromJson(e as Map<String, dynamic>)).toList(),
      activeSponsors: (json['activeSponsors'] as List<dynamic>? ?? [])
          .map((e) => ActiveSponsor.fromJson(e as Map<String, dynamic>)).toList(),
      unlockedAchievements: (json['unlockedAchievements'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      claimedAchievements: (json['claimedAchievements'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      storyFlags: (json['storyFlags'] as Map<String, dynamic>?) ?? {},
      eventCooldowns: (json['eventCooldowns'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toInt())) ?? {},
      pendingTransferOffers: (json['pendingTransferOffers'] as List<dynamic>? ?? [])
          .map((e) => TransferOffer.fromJson(e as Map<String, dynamic>)).toList(),
      lastAcademyWeek: (json['lastAcademyWeek'] as num?)?.toInt() ?? 0,
      legacyPoints: (json['legacyPoints'] as num?)?.toInt() ?? 0,
      isEndlessMode: json['isEndlessMode'] as bool? ?? false,
      year10Evaluated: json['year10Evaluated'] as bool? ?? false,
      activeLegacyPerks: (json['activeLegacyPerks'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      activeDivisionId: json['activeDivisionId'] as String? ?? 'arena_clash',
      unlockedDivisions: (json['unlockedDivisions'] as List<dynamic>? ?? ['arena_clash']).map((e) => e.toString()).toList(),
      divisionCircuitPoints: (json['divisionCircuitPoints'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toInt())) ?? {'arena_clash': 0},
      consecutiveWins: (json['consecutiveWins'] as num?)?.toInt() ?? 0,
      consecutiveNegativeWeeks: (json['consecutiveNegativeWeeks'] as num?)?.toInt() ?? 0,
      monthIncome: (json['monthIncome'] as num?)?.toInt() ?? 0,
      monthExpenses: (json['monthExpenses'] as num?)?.toInt() ?? 0,
      monthPlayerSalaries: (json['monthPlayerSalaries'] as num?)?.toInt() ?? 0,
      monthStaffSalaries: (json['monthStaffSalaries'] as num?)?.toInt() ?? 0,
      monthRent: (json['monthRent'] as num?)?.toInt() ?? 0,
      lastMonthlyReport: json['lastMonthlyReport'] != null
          ? MonthlyFinanceReport.fromJson(json['lastMonthlyReport'] as Map<String, dynamic>)
          : null,
    );
  }
}
