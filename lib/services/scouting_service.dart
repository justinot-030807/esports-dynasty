import 'dart:math';
import '../models/player.dart';
import '../models/game_state.dart';
import '../models/staff.dart';
import '../models/division.dart';

class ScoutingService {
  static final Random _rng = Random();

  static const List<String> _firstNames = [
    'Christian', 'Jerome', 'Aldrin', 'Joshua', 'Francis', 'Gerald',
    'Arjay', 'Kenneth', 'Tristan', 'Rafael', 'Danilo', 'Stephen'
  ];

  static const List<String> _lastNames = [
    'Reyes', 'Santos', 'Bautista', 'Torres', 'Mendoza', 'Aquino',
    'Castillo', 'Villanueva', 'Navarro', 'Salazar', 'Soriano', 'Perez'
  ];

  static const List<String> _gamerTags = [
    'Kupido', 'Bagsik', 'Kulog', 'Lodi', 'Petmalu', 'PusongBato',
    'Alon', 'Suntok', 'Asero', 'Hagis', 'Talas', 'Bayani', 'Asintado', 'Kuta'
  ];

  static const List<String> _traits = [
    'Clutch', 'Team Player', 'Workaholic', 'Lazy Genius',
    'Stream Natural', 'Fan Favorite', 'Veteran Leader', 'Prodigy'
  ];

  Player generateCandidate({
    int minOvr = 35,
    int maxOvr = 50,
    String primaryColorHex = '#1B2A49',
    String divisionId = 'arena_clash',
  }) {
    final div = EsportsDivision.getById(divisionId);
    final role = div.roles[_rng.nextInt(div.roles.length)];
    final baseStat = minOvr + _rng.nextInt(max(1, maxOvr - minOvr + 1));
    final isFemale = _rng.nextBool();
    final numId = isFemale ? (1 + _rng.nextInt(9)) : (1 + _rng.nextInt(10));
    final avatarId = isFemale
        ? 'gamer_f${numId.toString().padLeft(2, '0')}'
        : 'gamer_m${numId.toString().padLeft(2, '0')}';

    return Player(
      id: 'fa_${DateTime.now().microsecondsSinceEpoch}_${_rng.nextInt(9999)}',
      realName: '${_firstNames[_rng.nextInt(_firstNames.length)]} ${_lastNames[_rng.nextInt(_lastNames.length)]}',
      gamerTag: _gamerTags[_rng.nextInt(_gamerTags.length)],
      role: role,
      divisionId: divisionId,
      avatarId: avatarId,
      age: 16 + _rng.nextInt(6),
      aim: (baseStat + _rng.nextInt(7) - 3).clamp(20, 95),
      reaction: (baseStat + _rng.nextInt(7) - 3).clamp(20, 95),
      gameSense: (baseStat + _rng.nextInt(7) - 3).clamp(20, 95),
      teamwork: (baseStat + _rng.nextInt(7) - 3).clamp(20, 95),
      mental: (baseStat + _rng.nextInt(7) - 3).clamp(20, 95),
      stamina: (baseStat + _rng.nextInt(7) - 3).clamp(20, 95),
      potentialStars: 1 + _rng.nextInt(5),
      isPotentialRevealed: false,
      traits: [_traits[_rng.nextInt(_traits.length)]],
      jerseyColorHex: primaryColorHex,
      hairColorHex: ['#1B2A49', '#4A3728', '#0F172A', '#D97706'][_rng.nextInt(4)],
      skinColorHex: ['#E0AC69', '#C68642', '#8D5524', '#F1C27D'][_rng.nextInt(4)],
    );
  }

  static List<Player> generateFreeAgents(GameState state, {int count = 6, String? divisionId}) {
    final divId = divisionId ?? state.activeDivisionId;
    final list = <Player>[];

    final manager = state.staff.where((s) => s.role == StaffRole.manager).firstOrNull;
    final managerBonus = manager != null ? manager.level * 2 : 0;

    int minOvr = 30 + (state.houseTier * 6) + managerBonus;
    int maxOvr = 42 + (state.houseTier * 8) + managerBonus;

    final service = ScoutingService();
    for (int i = 0; i < count; i++) {
      list.add(service.generateCandidate(
        minOvr: minOvr,
        maxOvr: maxOvr,
        primaryColorHex: state.primaryColorHex,
        divisionId: divId,
      ));
    }
    return list;
  }

  static List<Player> conductOpenTryouts(GameState state, {String? divisionId}) {
    return generateFreeAgents(state, count: 10, divisionId: divisionId);
  }
}
