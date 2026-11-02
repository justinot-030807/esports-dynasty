class HallOfFameRecord {
  final String id;
  final int year;
  final String category; // 'champion', 'mvp', 'award', 'legend'
  final String title;
  final String recipientName;
  final String teamName;
  final String details;

  HallOfFameRecord({
    required this.id,
    required this.year,
    required this.category,
    required this.title,
    required this.recipientName,
    required this.teamName,
    required this.details,
  });

  factory HallOfFameRecord.fromJson(Map<String, dynamic> json) {
    return HallOfFameRecord(
      id: json['id'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 1,
      category: json['category'] as String? ?? 'champion',
      title: json['title'] as String? ?? '',
      recipientName: json['recipientName'] as String? ?? '',
      teamName: json['teamName'] as String? ?? '',
      details: json['details'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'year': year,
    'category': category,
    'title': title,
    'recipientName': recipientName,
    'teamName': teamName,
    'details': details,
  };
}

class SeasonAward {
  final String category;
  final String title;
  final String winnerName;
  final String teamName;
  final String description;
  final int rewardMoney;
  final int rewardFame;
  final int rewardFans;
  final bool isUserWinner;

  SeasonAward({
    required this.category,
    required this.title,
    required this.winnerName,
    required this.teamName,
    required this.description,
    this.rewardMoney = 0,
    this.rewardFame = 0,
    this.rewardFans = 0,
    this.isUserWinner = false,
  });
}
