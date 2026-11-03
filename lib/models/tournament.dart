class TournamentStageDef {
  final String type; // 'single_elim', 'round_robin', 'double_elim', 'gsl_group', 'swiss', 'groups'
  final int teams;
  final int bo;
  final int grandFinalBo;
  final String gfAdvantage; // 'none', 'upper'
  final int groupsCount;
  final int advanceCount;

  TournamentStageDef({
    required this.type,
    required this.teams,
    this.bo = 1,
    this.grandFinalBo = 3,
    this.gfAdvantage = 'none',
    this.groupsCount = 1,
    this.advanceCount = 2,
  });

  factory TournamentStageDef.fromJson(Map<String, dynamic> json) {
    return TournamentStageDef(
      type: json['type'] as String? ?? 'single_elim',
      teams: (json['teams'] as num?)?.toInt() ?? 8,
      bo: (json['bo'] as num?)?.toInt() ?? 1,
      grandFinalBo: (json['grand_final_bo'] as num?)?.toInt() ?? 3,
      gfAdvantage: json['gf_advantage'] as String? ?? 'none',
      groupsCount: (json['groups_count'] as num?)?.toInt() ?? 1,
      advanceCount: (json['advance_count'] as num?)?.toInt() ?? 2,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'teams': teams,
    'bo': bo,
    'grand_final_bo': grandFinalBo,
    'gf_advantage': gfAdvantage,
    'groups_count': groupsCount,
    'advance_count': advanceCount,
  };
}

class TournamentDef {
  final String id;
  final String name;
  final int tier;
  final String division;
  final int startWeek;
  final int endWeek;
  final int regOpenOffset;
  final int regCloseOffset;
  final int minFame;
  final int maxFame;
  final int entryFee;
  final int travelCost;
  final int slots;
  final List<TournamentStageDef> stages;
  final int championPrize;
  final int championFame;
  final int championFans;
  final int circuitPoints;
  final String trophy;
  final String banner;
  final String reschedule;
  final List<Map<String, dynamic>> qualifyRules;

  TournamentDef({
    required this.id,
    required this.name,
    required this.tier,
    required this.division,
    required this.startWeek,
    required this.endWeek,
    required this.regOpenOffset,
    required this.regCloseOffset,
    required this.minFame,
    required this.maxFame,
    required this.entryFee,
    required this.travelCost,
    required this.slots,
    required this.stages,
    required this.championPrize,
    required this.championFame,
    required this.championFans,
    required this.circuitPoints,
    required this.trophy,
    required this.banner,
    this.reschedule = 'typhoon_ok',
    List<Map<String, dynamic>>? qualifyRules,
  }) : qualifyRules = qualifyRules ?? [];

  factory TournamentDef.fromJson(Map<String, dynamic> json) {
    final weeks = (json['weeks'] as List<dynamic>? ?? [1, 2])
        .map((e) => (e as num).toInt())
        .toList();
    final reg = json['registration'] as Map<String, dynamic>? ?? {};
    final fame = json['fame'] as Map<String, dynamic>? ?? {};
    final rewards = json['rewards'] as Map<String, dynamic>? ?? {};
    final stagesList = (json['stages'] as List<dynamic>? ?? [])
        .map((e) => TournamentStageDef.fromJson(e as Map<String, dynamic>))
        .toList();
    final qRules = (json['qualify'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    return TournamentDef(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      tier: (json['tier'] as num?)?.toInt() ?? 1,
      division: json['division'] as String? ?? 'arena_clash',
      startWeek: weeks.isNotEmpty ? weeks[0] : 1,
      endWeek: weeks.length > 1 ? weeks[1] : (weeks.isNotEmpty ? weeks[0] : 2),
      regOpenOffset: (reg['opens'] as num?)?.toInt() ?? -4,
      regCloseOffset: (reg['closes'] as num?)?.toInt() ?? -1,
      minFame: (fame['min'] as num?)?.toInt() ?? 0,
      maxFame: (fame['max'] as num?)?.toInt() ?? 999999,
      entryFee: (json['entry_fee'] as num?)?.toInt() ?? 0,
      travelCost: (json['travel_cost'] as num?)?.toInt() ?? 0,
      slots: (json['slots'] as num?)?.toInt() ?? 8,
      stages: stagesList,
      championPrize: (rewards['champion_prize'] as num?)?.toInt() ?? 10000,
      championFame: (rewards['fame'] as num?)?.toInt() ?? 50,
      championFans: (rewards['fans'] as num?)?.toInt() ?? 300,
      circuitPoints: (rewards['circuit_points'] as num?)?.toInt() ?? 100,
      trophy: rewards['trophy'] as String? ?? 'trophy_bronze_t1',
      banner: json['banner'] as String? ?? 'banner_t1',
      reschedule: json['reschedule'] as String? ?? 'typhoon_ok',
      qualifyRules: qRules,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tier': tier,
    'division': division,
    'weeks': [startWeek, endWeek],
    'registration': {'opens': regOpenOffset, 'closes': regCloseOffset},
    'fame': {'min': minFame, 'max': maxFame},
    'entry_fee': entryFee,
    'travel_cost': travelCost,
    'slots': slots,
    'stages': stages.map((s) => s.toJson()).toList(),
    'rewards': {
      'champion_prize': championPrize,
      'fame': championFame,
      'fans': championFans,
      'circuit_points': circuitPoints,
      'trophy': trophy,
    },
    'banner': banner,
    'reschedule': reschedule,
    'qualify': qualifyRules,
  };
}

class MatchSlot {
  String teamId;
  String teamName;
  int score;
  int seed;
  bool isWinner;

  MatchSlot({
    this.teamId = '',
    this.teamName = 'TBD',
    this.score = 0,
    this.seed = 0,
    this.isWinner = false,
  });

  factory MatchSlot.fromJson(Map<String, dynamic> json) {
    return MatchSlot(
      teamId: json['teamId'] as String? ?? '',
      teamName: json['teamName'] as String? ?? 'TBD',
      score: (json['score'] as num?)?.toInt() ?? 0,
      seed: (json['seed'] as num?)?.toInt() ?? 0,
      isWinner: json['isWinner'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'teamId': teamId,
    'teamName': teamName,
    'score': score,
    'seed': seed,
    'isWinner': isWinner,
  };
}

class MatchNode {
  final String id;
  final String tournamentId;
  final int stageIndex;
  final int round; // 1 = QF/R16, 2 = SF, 3 = Final, etc.
  final String roundName;
  int week;
  final int day; // default 5 (Day 5 = Match Day)
  MatchSlot slotA;
  MatchSlot slotB;
  final int bestOf;
  bool isPlayed;
  bool isBye;
  String winnerId;

  String get teamAId => slotA.teamId;
  String get teamBId => slotB.teamId;
  int get winnerScore => slotA.isWinner ? slotA.score : slotB.score;
  int get loserScore => slotA.isWinner ? slotB.score : slotA.score;

  MatchNode({
    required this.id,
    required this.tournamentId,
    this.stageIndex = 0,
    required this.round,
    required this.roundName,
    required this.week,
    this.day = 5,
    required this.slotA,
    required this.slotB,
    this.bestOf = 1,
    this.isPlayed = false,
    this.isBye = false,
    this.winnerId = '',
  });

  bool get hasUser => slotA.teamId == 'user_team' || slotB.teamId == 'user_team';
  bool get isReady => slotA.teamId.isNotEmpty && slotB.teamId.isNotEmpty;

  factory MatchNode.fromJson(Map<String, dynamic> json) {
    return MatchNode(
      id: json['id'] as String? ?? '',
      tournamentId: json['tournamentId'] as String? ?? '',
      stageIndex: (json['stageIndex'] as num?)?.toInt() ?? 0,
      round: (json['round'] as num?)?.toInt() ?? 1,
      roundName: json['roundName'] as String? ?? 'Round',
      week: (json['week'] as num?)?.toInt() ?? 1,
      day: (json['day'] as num?)?.toInt() ?? 5,
      slotA: MatchSlot.fromJson(json['slotA'] as Map<String, dynamic>? ?? {}),
      slotB: MatchSlot.fromJson(json['slotB'] as Map<String, dynamic>? ?? {}),
      bestOf: (json['bestOf'] as num?)?.toInt() ?? 1,
      isPlayed: json['isPlayed'] as bool? ?? false,
      isBye: json['isBye'] as bool? ?? false,
      winnerId: json['winnerId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tournamentId': tournamentId,
    'stageIndex': stageIndex,
    'round': round,
    'roundName': roundName,
    'week': week,
    'day': day,
    'slotA': slotA.toJson(),
    'slotB': slotB.toJson(),
    'bestOf': bestOf,
    'isPlayed': isPlayed,
    'isBye': isBye,
    'winnerId': winnerId,
  };
}

class RoundRobinTeamStat {
  final String teamId;
  final String teamName;
  int played;
  int wins;
  int losses;
  int gamesWon;
  int gamesLost;
  int points; // 3 for win, etc.
  List<String> form; // ['W', 'L', 'W']

  RoundRobinTeamStat({
    required this.teamId,
    required this.teamName,
    this.played = 0,
    this.wins = 0,
    this.losses = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.points = 0,
    List<String>? form,
  }) : form = form ?? [];

  int get gameDiff => gamesWon - gamesLost;

  factory RoundRobinTeamStat.fromJson(Map<String, dynamic> json) {
    return RoundRobinTeamStat(
      teamId: json['teamId'] as String? ?? '',
      teamName: json['teamName'] as String? ?? '',
      played: (json['played'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      gamesWon: (json['gamesWon'] as num?)?.toInt() ?? 0,
      gamesLost: (json['gamesLost'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      form: (json['form'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'teamId': teamId,
    'teamName': teamName,
    'played': played,
    'wins': wins,
    'losses': losses,
    'gamesWon': gamesWon,
    'gamesLost': gamesLost,
    'points': points,
    'form': form,
  };
}

class TournamentInstance {
  final String tournamentId;
  final String name;
  final int tier;
  final String banner;
  final String division;
  String status; // 'upcoming', 'registration_open', 'in_progress', 'completed'
  List<String> registeredTeamIds;
  int currentStageIndex;
  List<MatchNode> matches;
  List<RoundRobinTeamStat> standings;
  String championId;
  String championName;
  String userPlacement; // '1st (Champion)', '2nd', '3rd-4th', 'Participant'

  TournamentInstance({
    required this.tournamentId,
    required this.name,
    required this.tier,
    required this.banner,
    this.division = 'arena_clash',
    this.status = 'upcoming',
    List<String>? registeredTeamIds,
    this.currentStageIndex = 0,
    List<MatchNode>? matches,
    List<RoundRobinTeamStat>? standings,
    this.championId = '',
    this.championName = '',
    this.userPlacement = '',
  })  : registeredTeamIds = registeredTeamIds ?? [],
        matches = matches ?? [],
        standings = standings ?? [];

  bool get isUserRegistered => registeredTeamIds.contains('user_team');

  factory TournamentInstance.fromJson(Map<String, dynamic> json) {
    return TournamentInstance(
      tournamentId: json['tournamentId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      tier: (json['tier'] as num?)?.toInt() ?? 1,
      banner: json['banner'] as String? ?? 'banner_t1',
      division: json['division'] as String? ?? 'arena_clash',
      status: json['status'] as String? ?? 'upcoming',
      registeredTeamIds: (json['registeredTeamIds'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      currentStageIndex: (json['currentStageIndex'] as num?)?.toInt() ?? 0,
      matches: (json['matches'] as List<dynamic>? ?? []).map((e) => MatchNode.fromJson(e as Map<String, dynamic>)).toList(),
      standings: (json['standings'] as List<dynamic>? ?? []).map((e) => RoundRobinTeamStat.fromJson(e as Map<String, dynamic>)).toList(),
      championId: json['championId'] as String? ?? '',
      championName: json['championName'] as String? ?? '',
      userPlacement: json['userPlacement'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'tournamentId': tournamentId,
    'name': name,
    'tier': tier,
    'banner': banner,
    'division': division,
    'status': status,
    'registeredTeamIds': registeredTeamIds,
    'currentStageIndex': currentStageIndex,
    'matches': matches.map((m) => m.toJson()).toList(),
    'standings': standings.map((s) => s.toJson()).toList(),
    'championId': championId,
    'championName': championName,
    'userPlacement': userPlacement,
  };
}
