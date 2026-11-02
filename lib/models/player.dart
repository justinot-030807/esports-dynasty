/// Player model for Arena Clash, Strike Zone, and Last Island divisions
enum PlayerRole {
  // Arena Clash (MOBA)
  carry,
  mid,
  roamer,
  tank,
  support,
  // Strike Zone (Tactical FPS)
  entry,
  sniper,
  igl,
  lurker,
  anchor,
  // Last Island (Battle Royale)
  scout,
  assault,
  caller,
  medic,
}

enum PlayerCondition { great, good, normal, tired, exhausted }

class Player {
  final String id;
  String realName;
  String gamerTag;
  PlayerRole role;
  String divisionId; // 'arena_clash', 'strike_zone', 'last_island'
  int age;

  // Stats (0 - 100)
  int aim;
  int reaction;
  int gameSense;
  int teamwork;
  int mental;
  int stamina;

  // Vitals
  int fatigue; // 0 - 100
  int morale; // 0 - 100
  int potentialStars; // 1 - 5
  bool isPotentialRevealed;
  List<String> traits;
  Map<String, int> roleMastery;
  Map<String, double> trainingCarry;
  int contractWeeksLeft;
  bool isStarter;

  // Appearance palette
  String jerseyColorHex;
  String hairColorHex;
  String skinColorHex;

  // Station & positioning state in Living House
  String currentStation; // 'pc', 'bed', 'kitchen', 'idle'
  double posX;
  double posY;
  double targetX;
  double targetY;
  bool isWalking;
  int walkFrame;
  double breathPhase;

  Player({
    required this.id,
    required this.realName,
    required this.gamerTag,
    required this.role,
    this.divisionId = 'arena_clash',
    this.age = 18,
    required this.aim,
    required this.reaction,
    required this.gameSense,
    required this.teamwork,
    required this.mental,
    required this.stamina,
    this.fatigue = 10,
    this.morale = 75,
    this.potentialStars = 3,
    this.isPotentialRevealed = false,
    List<String>? traits,
    Map<String, int>? roleMastery,
    Map<String, double>? trainingCarry,
    this.contractWeeksLeft = 48,
    this.isStarter = true,
    this.jerseyColorHex = '#3FA7FF',
    this.hairColorHex = '#1B2A49',
    this.skinColorHex = '#E0AC69',
    this.currentStation = 'idle',
    this.posX = 0.5,
    this.posY = 0.5,
    this.targetX = 0.5,
    this.targetY = 0.5,
    this.isWalking = false,
    this.walkFrame = 0,
    this.breathPhase = 0.0,
  })  : traits = traits ?? ['Team Player'],
        roleMastery = roleMastery ?? {for (var r in PlayerRole.values) r.name: r == role ? 70 : 20},
        trainingCarry = trainingCarry ?? {};

  int get ovr {
    switch (role) {
      // Arena Clash (MOBA)
      case PlayerRole.carry:
        return (aim * 0.30 + reaction * 0.25 + gameSense * 0.15 + mental * 0.15 + stamina * 0.10 + teamwork * 0.05).round();
      case PlayerRole.mid:
        return (gameSense * 0.30 + aim * 0.20 + reaction * 0.15 + mental * 0.15 + teamwork * 0.10 + stamina * 0.10).round();
      case PlayerRole.roamer:
        return (gameSense * 0.25 + teamwork * 0.25 + reaction * 0.20 + mental * 0.10 + aim * 0.10 + stamina * 0.10).round();
      case PlayerRole.tank:
        return (mental * 0.25 + stamina * 0.20 + teamwork * 0.20 + reaction * 0.15 + gameSense * 0.10 + aim * 0.10).round();
      case PlayerRole.support:
        return (teamwork * 0.30 + gameSense * 0.25 + mental * 0.15 + reaction * 0.10 + stamina * 0.10 + aim * 0.10).round();
      // Strike Zone (Tactical FPS)
      case PlayerRole.entry:
        return (aim * 0.35 + reaction * 0.30 + mental * 0.15 + gameSense * 0.10 + stamina * 0.05 + teamwork * 0.05).round();
      case PlayerRole.sniper:
        return (reaction * 0.35 + aim * 0.30 + mental * 0.15 + gameSense * 0.10 + stamina * 0.05 + teamwork * 0.05).round();
      case PlayerRole.igl:
        return (gameSense * 0.35 + teamwork * 0.25 + mental * 0.20 + aim * 0.10 + reaction * 0.05 + stamina * 0.05).round();
      case PlayerRole.lurker:
        return (gameSense * 0.30 + aim * 0.25 + reaction * 0.20 + mental * 0.15 + teamwork * 0.05 + stamina * 0.05).round();
      case PlayerRole.anchor:
        return (mental * 0.30 + stamina * 0.25 + teamwork * 0.20 + aim * 0.10 + reaction * 0.10 + gameSense * 0.05).round();
      // Last Island (Battle Royale)
      case PlayerRole.scout:
        return (reaction * 0.30 + gameSense * 0.25 + stamina * 0.20 + mental * 0.10 + aim * 0.10 + teamwork * 0.05).round();
      case PlayerRole.assault:
        return (aim * 0.35 + reaction * 0.25 + mental * 0.15 + gameSense * 0.10 + stamina * 0.10 + teamwork * 0.05).round();
      case PlayerRole.caller:
        return (gameSense * 0.35 + mental * 0.25 + teamwork * 0.20 + reaction * 0.10 + aim * 0.05 + stamina * 0.05).round();
      case PlayerRole.medic:
        return (teamwork * 0.35 + mental * 0.20 + stamina * 0.20 + gameSense * 0.15 + aim * 0.05 + reaction * 0.05).round();
    }
  }

  String get rankTitle {
    final score = ovr;
    if (score < 35) return 'Rookie';
    if (score < 50) return 'Amateur';
    if (score < 65) return 'Semi-Pro';
    if (score < 80) return 'Pro';
    if (score < 92) return 'Star';
    return 'Legend';
  }

  int get weeklySalary {
    switch (rankTitle) {
      case 'Rookie': return 400;
      case 'Amateur': return 900;
      case 'Semi-Pro': return 2500;
      case 'Pro': return 7000;
      case 'Star': return 20000;
      default: return 60000;
    }
  }

  PlayerCondition get condition {
    if (fatigue >= 85) return PlayerCondition.exhausted;
    if (fatigue >= 60) return PlayerCondition.tired;
    if (morale >= 80 && fatigue < 30) return PlayerCondition.great;
    if (morale >= 50 && fatigue < 50) return PlayerCondition.good;
    return PlayerCondition.normal;
  }

  bool get isExhausted => condition == PlayerCondition.exhausted;

  int getStatCap(String statKey) {
    int baseCap;
    switch (potentialStars) {
      case 1: baseCap = 55; break;
      case 2: baseCap = 68; break;
      case 3: baseCap = 80; break;
      case 4: baseCap = 91; break;
      default: baseCap = 99; break;
    }
    // +8 for the role's top 2 stats
    final top2 = _getTopTwoStatsForRole(role);
    if (top2.contains(statKey)) {
      return baseCap + 8;
    }
    return baseCap;
  }

  List<String> _getTopTwoStatsForRole(PlayerRole r) {
    switch (r) {
      case PlayerRole.carry: return ['aim', 'reaction'];
      case PlayerRole.mid: return ['gameSense', 'aim'];
      case PlayerRole.roamer: return ['gameSense', 'teamwork'];
      case PlayerRole.tank: return ['mental', 'stamina'];
      case PlayerRole.support: return ['teamwork', 'gameSense'];
      case PlayerRole.entry: return ['aim', 'reaction'];
      case PlayerRole.sniper: return ['reaction', 'aim'];
      case PlayerRole.igl: return ['gameSense', 'teamwork'];
      case PlayerRole.lurker: return ['gameSense', 'aim'];
      case PlayerRole.anchor: return ['mental', 'stamina'];
      case PlayerRole.scout: return ['reaction', 'gameSense'];
      case PlayerRole.assault: return ['aim', 'reaction'];
      case PlayerRole.caller: return ['gameSense', 'mental'];
      case PlayerRole.medic: return ['teamwork', 'stamina'];
    }
  }

  String get roleDisplayName {
    switch (role) {
      case PlayerRole.carry: return 'Carry';
      case PlayerRole.mid: return 'Mid';
      case PlayerRole.roamer: return 'Roamer';
      case PlayerRole.tank: return 'Tank';
      case PlayerRole.support: return 'Support';
      case PlayerRole.entry: return 'Entry Fragger';
      case PlayerRole.sniper: return 'Sniper / AWPer';
      case PlayerRole.igl: return 'IGL';
      case PlayerRole.lurker: return 'Lurker';
      case PlayerRole.anchor: return 'Anchor';
      case PlayerRole.scout: return 'Scout';
      case PlayerRole.assault: return 'Assault';
      case PlayerRole.caller: return 'Survival Caller';
      case PlayerRole.medic: return 'Combat Medic';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'realName': realName,
    'gamerTag': gamerTag,
    'role': role.name,
    'divisionId': divisionId,
    'age': age,
    'aim': aim,
    'reaction': reaction,
    'gameSense': gameSense,
    'teamwork': teamwork,
    'mental': mental,
    'stamina': stamina,
    'fatigue': fatigue,
    'morale': morale,
    'potentialStars': potentialStars,
    'isPotentialRevealed': isPotentialRevealed,
    'traits': traits,
    'roleMastery': roleMastery,
    'trainingCarry': trainingCarry,
    'contractWeeksLeft': contractWeeksLeft,
    'isStarter': isStarter,
    'jerseyColorHex': jerseyColorHex,
    'hairColorHex': hairColorHex,
    'skinColorHex': skinColorHex,
    'currentStation': currentStation,
    'posX': posX,
    'posY': posY,
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String? ?? 'p_${DateTime.now().millisecondsSinceEpoch}',
      realName: json['realName'] as String? ?? 'Juan Dela Cruz',
      gamerTag: json['gamerTag'] as String? ?? 'Kidlat',
      role: PlayerRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => PlayerRole.carry,
      ),
      divisionId: json['divisionId'] as String? ?? 'arena_clash',
      age: (json['age'] as num?)?.toInt() ?? 18,
      aim: (json['aim'] as num?)?.toInt() ?? 35,
      reaction: (json['reaction'] as num?)?.toInt() ?? 35,
      gameSense: (json['gameSense'] as num?)?.toInt() ?? 35,
      teamwork: (json['teamwork'] as num?)?.toInt() ?? 35,
      mental: (json['mental'] as num?)?.toInt() ?? 35,
      stamina: (json['stamina'] as num?)?.toInt() ?? 35,
      fatigue: (json['fatigue'] as num?)?.toInt() ?? 10,
      morale: (json['morale'] as num?)?.toInt() ?? 75,
      potentialStars: (json['potentialStars'] as num?)?.toInt() ?? 3,
      isPotentialRevealed: json['isPotentialRevealed'] as bool? ?? false,
      traits: (json['traits'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      roleMastery: (json['roleMastery'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toInt())),
      trainingCarry: (json['trainingCarry'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toDouble())),
      contractWeeksLeft: (json['contractWeeksLeft'] as num?)?.toInt() ?? 48,
      isStarter: json['isStarter'] as bool? ?? true,
      jerseyColorHex: json['jerseyColorHex'] as String? ?? '#3FA7FF',
      hairColorHex: json['hairColorHex'] as String? ?? '#1B2A49',
      skinColorHex: json['skinColorHex'] as String? ?? '#E0AC69',
      currentStation: json['currentStation'] as String? ?? 'idle',
      posX: (json['posX'] as num?)?.toDouble() ?? 0.5,
      posY: (json['posY'] as num?)?.toDouble() ?? 0.5,
      targetX: (json['posX'] as num?)?.toDouble() ?? 0.5,
      targetY: (json['posY'] as num?)?.toDouble() ?? 0.5,
    );
  }
}
