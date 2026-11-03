import 'dart:math';
import '../models/ai_team.dart';

class RivalPlayerDisplayData {
  final String gamerTag;
  final String roleName;
  final String roleIconPath;
  final String conditionIconPath;
  final String avatarPath;
  final int mental;
  final int ovr;
  double focus;
  double tilt;
  String state; // 'idle', 'attacking', 'hit', 'dead', 'hot_streak', 'tilted'
  int killStreak;
  int respawnSeconds;

  RivalPlayerDisplayData({
    required this.gamerTag,
    required this.roleName,
    required this.roleIconPath,
    required this.conditionIconPath,
    required this.avatarPath,
    required this.mental,
    required this.ovr,
    this.focus = 50.0,
    this.tilt = 10.0,
    this.state = 'idle',
    this.killStreak = 0,
    this.respawnSeconds = 0,
  });
}

class RivalRosterService {
  static const List<String> standardRoles = [
    'Carry',
    'Mid',
    'Roamer',
    'Tank',
    'Support',
  ];

  static const List<String> roleIconPaths = [
    'assets/images/icons/role_carry.png',
    'assets/images/icons/role_mid.png',
    'assets/images/icons/role_roamer.png',
    'assets/images/icons/role_tank.png',
    'assets/images/icons/role_support.png',
  ];

  static const List<String> tagPool = [
    'Kidlat', 'Bagsik', 'Tsinelas', 'Kupido', 'Alon', 'Suntok', 'Amihan',
    'Datu', 'Gilas', 'Lodi', 'Petmalu', 'Kape', 'PusongBato', 'Agila',
    'Tala', 'Bituin', 'Kulog', 'Mayon', 'Banaue', 'PinoyPride', 'Hagis',
    'Sibat', 'Talas', 'Balisong', 'KidlatBoy', 'KuyaClutch', 'SiopaoKing',
    'KantoSniper', 'LabanPinoy', 'Tikbalang', 'Diwata', 'Kapre', 'Bathala',
    'Ginoo', 'Bayani', 'Tadhana', 'Mahiwaga', 'Asero', 'LakasTae'
  ];

  static List<RivalPlayerDisplayData> generateRoster(AiTeam team) {
    final cleanId = team.id.toLowerCase().replaceAll('team_', '').replaceAll('rival_', '');
    final flagshipRivals = ['kidlat', 'bakal', 'dagat', 'mayon', 'tarsier', 'pawikan', 'agila', 'banaue', 'siargao'];
    final isFlagship = flagshipRivals.contains(cleanId);

    final seed = team.id.hashCode.abs();
    final rng = Random(seed);

    final roster = <RivalPlayerDisplayData>[];

    for (int i = 0; i < 5; i++) {
      final role = standardRoles[i];
      final roleIcon = roleIconPaths[i];

      String tag;
      String avatar;

      if (i == 0 && team.captain != null && team.captain!.isNotEmpty) {
        // Strip single quotes if captain has nickname e.g. "Mark 'Thunder' Santos" -> "Thunder"
        final match = RegExp(r"'([^']+)'").firstMatch(team.captain!);
        tag = match != null ? match.group(1)! : team.captain!.split(' ').first;
        avatar = isFlagship
            ? 'assets/images/characters/rival_$cleanId/rival_${cleanId}_front_idle.png'
            : 'assets/images/characters/gamer_m02/gamer_m02_front_idle.png';
      } else {
        final tagIndex = (seed + (i * 7) + 3) % tagPool.length;
        tag = tagPool[tagIndex];
        final spriteNum = ((seed + i) % 9) + 2;
        final padded = spriteNum.toString().padLeft(2, '0');
        final isFemale = (seed + i) % 3 == 0;
        avatar = isFemale
            ? 'assets/images/characters/gamer_f0$spriteNum/gamer_f0${spriteNum}_front_idle.png'
            : 'assets/images/characters/gamer_m$padded/gamer_m${padded}_front_idle.png';
      }

      final mental = (40 + rng.nextInt(35) + (team.tier * 5)).clamp(30, 95);
      final ovr = (team.rating + rng.nextInt(6) - 3).clamp(25, 99);

      // Condition icon
      final condRoll = rng.nextInt(5);
      final condIcons = [
        'assets/images/icons/face_great.png',
        'assets/images/icons/face_good.png',
        'assets/images/icons/face_normal.png',
        'assets/images/icons/face_tired.png',
        'assets/images/icons/face_exhausted.png',
      ];

      roster.add(RivalPlayerDisplayData(
        gamerTag: tag,
        roleName: role,
        roleIconPath: roleIcon,
        conditionIconPath: condIcons[condRoll],
        avatarPath: avatar,
        mental: mental,
        ovr: ovr,
        focus: 50.0 + rng.nextInt(20) - 10,
        tilt: 10.0 + rng.nextInt(15),
      ));
    }

    return roster;
  }
}
