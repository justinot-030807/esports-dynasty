import 'player.dart';

class EsportsDivision {
  final String id;
  final String name;
  final String shortCode;
  final String genre;
  final String tagline;
  final int squadSize;
  final int minFame;
  final int unlockCost;
  final List<PlayerRole> roles;
  final List<String> strategies;
  final Map<String, String> strategyCounters; // winner -> loser (+4 advantage)

  const EsportsDivision({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.genre,
    required this.tagline,
    required this.squadSize,
    required this.minFame,
    required this.unlockCost,
    required this.roles,
    required this.strategies,
    required this.strategyCounters,
  });

  /// Strategy matchup advantage (+4 for A, -4 for B, 0 for neutral)
  int getStrategyModifier(String strategyA, String strategyB) {
    if (strategyA == strategyB) return 0;
    if (strategyCounters[strategyA] == strategyB) return 4;
    if (strategyCounters[strategyB] == strategyA) return -4;
    return 0;
  }

  // --- DIVISION DEFINITIONS ---

  static const arenaClash = EsportsDivision(
    id: 'arena_clash',
    name: 'Arena Clash',
    shortCode: 'AC',
    genre: '5v5 MOBA',
    tagline: 'Lanes, towers, and teamfights decide the champions.',
    squadSize: 5,
    minFame: 0,
    unlockCost: 0,
    roles: [
      PlayerRole.carry,
      PlayerRole.mid,
      PlayerRole.roamer,
      PlayerRole.tank,
      PlayerRole.support,
    ],
    strategies: ['Rush', 'Teamfight', 'Scale', 'Split'],
    strategyCounters: {
      'Rush': 'Scale',
      'Scale': 'Split',
      'Split': 'Teamfight',
      'Teamfight': 'Rush',
    },
  );

  static const strikeZone = EsportsDivision(
    id: 'strike_zone',
    name: 'Strike Zone',
    shortCode: 'SZ',
    genre: 'Tactical FPS',
    tagline: 'Precision aim, bomb-site takes, and economy management.',
    squadSize: 5,
    minFame: 200,
    unlockCost: 20000,
    roles: [
      PlayerRole.entry,
      PlayerRole.sniper,
      PlayerRole.igl,
      PlayerRole.lurker,
      PlayerRole.anchor,
    ],
    strategies: ['Fast Site Take', 'Retake Setup', 'Default Pick', 'Eco Rush'],
    strategyCounters: {
      'Fast Site Take': 'Default Pick',
      'Default Pick': 'Retake Setup',
      'Retake Setup': 'Eco Rush',
      'Eco Rush': 'Fast Site Take',
    },
  );

  static const lastIsland = EsportsDivision(
    id: 'last_island',
    name: 'Last Island',
    shortCode: 'LI',
    genre: 'Battle Royale',
    tagline: '60-player survival drop: zone rotations and chicken dinners.',
    squadSize: 4,
    minFame: 500,
    unlockCost: 40000,
    roles: [
      PlayerRole.scout,
      PlayerRole.assault,
      PlayerRole.caller,
      PlayerRole.medic,
    ],
    strategies: ['Hot Drop', 'Center Circle Hold', 'Edge Loot & Rotate', 'Ambush & Gatekeep'],
    strategyCounters: {
      'Hot Drop': 'Edge Loot & Rotate',
      'Edge Loot & Rotate': 'Center Circle Hold',
      'Center Circle Hold': 'Ambush & Gatekeep',
      'Ambush & Gatekeep': 'Hot Drop',
    },
  );

  static const List<EsportsDivision> all = [
    arenaClash,
    strikeZone,
    lastIsland,
  ];

  static EsportsDivision getById(String id) {
    return all.firstWhere((d) => d.id == id, orElse: () => arenaClash);
  }
}
