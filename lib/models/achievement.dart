/// Milestone and achievement definitions
class AchievementDef {
  final String id;
  final String title;
  final String category; // 'competition', 'base', 'roster', 'fans', 'economy', 'dynasty'
  final String desc;
  final int rewardMoney;
  final int rewardFame;
  final int rewardFans;

  const AchievementDef({
    required this.id,
    required this.title,
    this.category = 'competition',
    required this.desc,
    this.rewardMoney = 0,
    this.rewardFame = 0,
    this.rewardFans = 0,
  });

  factory AchievementDef.fromJson(Map<String, dynamic> json) {
    return AchievementDef(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? json['name'] as String? ?? 'Achievement',
      category: json['category'] as String? ?? 'competition',
      desc: json['desc'] as String? ?? '',
      rewardMoney: (json['reward_money'] as num?)?.toInt() ?? 0,
      rewardFame: (json['reward_fame'] as num?)?.toInt() ?? 0,
      rewardFans: (json['reward_fans'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'desc': desc,
    'reward_money': rewardMoney,
    'reward_fame': rewardFame,
    'reward_fans': rewardFans,
  };
}
