/// Sponsor models for ESPORTS DYNASTY
class SponsorDef {
  final String id;
  final String name;
  final int tier;
  final int weeklyPay;
  final int bonusPay;
  final int minFame;
  final int durationWeeks;
  final String goalType; // 'win_matches', 'gain_fans', 'reach_playoffs', 'stream_hours', 'high_morale'
  final int goalTarget;
  final String desc;

  const SponsorDef({
    required this.id,
    required this.name,
    required this.tier,
    required this.weeklyPay,
    required this.bonusPay,
    required this.minFame,
    required this.durationWeeks,
    required this.goalType,
    required this.goalTarget,
    required this.desc,
  });

  String get goalTitle {
    switch (goalType) {
      case 'win_matches':
        return 'Win $goalTarget official matches';
      case 'gain_fans':
        return 'Gain $goalTarget new fans';
      case 'reach_playoffs':
        return 'Reach playoffs in $goalTarget tournament(s)';
      case 'stream_hours':
        return 'Log $goalTarget streaming sessions';
      case 'high_morale':
        return 'Keep 75+ team morale for $goalTarget weeks';
      default:
        return 'Fulfill sponsor contract obligations';
    }
  }

  factory SponsorDef.fromJson(Map<String, dynamic> json) {
    return SponsorDef(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Sponsor',
      tier: (json['tier'] as num?)?.toInt() ?? 1,
      weeklyPay: (json['weekly_pay'] as num?)?.toInt() ?? 2000,
      bonusPay: (json['bonus_pay'] as num?)?.toInt() ?? 5000,
      minFame: (json['min_fame'] as num?)?.toInt() ?? 0,
      durationWeeks: (json['duration_weeks'] as num?)?.toInt() ?? 12,
      goalType: json['goal_type'] as String? ?? 'win_matches',
      goalTarget: (json['goal_target'] as num?)?.toInt() ?? 3,
      desc: json['desc'] as String? ?? '',
    );
  }
}

class ActiveSponsor {
  final String id;
  final String name;
  final int tier;
  final int weeklyPay;
  final int bonusPay;
  final int durationWeeks;
  int weeksRemaining;
  final String goalType;
  final int goalTarget;
  int goalProgress;
  bool isCompleted;
  bool isBonusClaimed;

  ActiveSponsor({
    required this.id,
    required this.name,
    required this.tier,
    required this.weeklyPay,
    required this.bonusPay,
    required this.durationWeeks,
    required this.weeksRemaining,
    required this.goalType,
    required this.goalTarget,
    this.goalProgress = 0,
    this.isCompleted = false,
    this.isBonusClaimed = false,
  });

  String get goalDescription {
    switch (goalType) {
      case 'win_matches':
        return 'Manalo ng $goalTarget laban ($goalProgress / $goalTarget)';
      case 'gain_fans':
        return 'Makaipon ng $goalTarget fans ($goalProgress / $goalTarget)';
      case 'reach_playoffs':
        return 'Umakyat sa playoffs $goalTarget beses ($goalProgress / $goalTarget)';
      case 'stream_hours':
        return 'Maka-stream ng $goalTarget beses ($goalProgress / $goalTarget)';
      case 'high_morale':
        return '75+ Morale ($goalProgress / $goalTarget weeks)';
      default:
        return 'Layunin: $goalProgress / $goalTarget';
    }
  }

  void addProgress(int amount) {
    if (isCompleted) return;
    goalProgress += amount;
    if (goalProgress >= goalTarget) {
      goalProgress = goalTarget;
      isCompleted = true;
    }
  }

  bool tickWeek() {
    weeksRemaining--;
    return weeksRemaining <= 0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tier': tier,
    'weeklyPay': weeklyPay,
    'bonusPay': bonusPay,
    'durationWeeks': durationWeeks,
    'weeksRemaining': weeksRemaining,
    'goalType': goalType,
    'goalTarget': goalTarget,
    'goalProgress': goalProgress,
    'isCompleted': isCompleted,
    'isBonusClaimed': isBonusClaimed,
  };

  factory ActiveSponsor.fromJson(Map<String, dynamic> json) {
    return ActiveSponsor(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Sponsor',
      tier: (json['tier'] as num?)?.toInt() ?? 1,
      weeklyPay: (json['weeklyPay'] as num?)?.toInt() ?? 2000,
      bonusPay: (json['bonusPay'] as num?)?.toInt() ?? 5000,
      durationWeeks: (json['durationWeeks'] as num?)?.toInt() ?? 12,
      weeksRemaining: (json['weeksRemaining'] as num?)?.toInt() ?? 12,
      goalType: json['goalType'] as String? ?? 'win_matches',
      goalTarget: (json['goalTarget'] as num?)?.toInt() ?? 3,
      goalProgress: (json['goalProgress'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isBonusClaimed: json['isBonusClaimed'] as bool? ?? false,
    );
  }

  factory ActiveSponsor.fromDef(SponsorDef def) {
    return ActiveSponsor(
      id: def.id,
      name: def.name,
      tier: def.tier,
      weeklyPay: def.weeklyPay,
      bonusPay: def.bonusPay,
      durationWeeks: def.durationWeeks,
      weeksRemaining: def.durationWeeks,
      goalType: def.goalType,
      goalTarget: def.goalTarget,
    );
  }
}
