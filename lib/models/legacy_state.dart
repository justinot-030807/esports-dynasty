class FinalEvaluation {
  final int score;
  final String rankTitle;
  final int titlesCount;
  final int trophiesCount;
  final int legendsDeveloped;
  final int peakFame;
  final int peakFans;
  final int totalRevenue;
  final int legacyPointsEarned;
  final String date;

  FinalEvaluation({
    required this.score,
    required this.rankTitle,
    required this.titlesCount,
    required this.trophiesCount,
    required this.legendsDeveloped,
    required this.peakFame,
    required this.peakFans,
    required this.totalRevenue,
    required this.legacyPointsEarned,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'score': score,
        'rank_title': rankTitle,
        'titles_count': titlesCount,
        'trophies_count': trophiesCount,
        'legends_developed': legendsDeveloped,
        'peak_fame': peakFame,
        'peak_fans': peakFans,
        'total_revenue': totalRevenue,
        'legacy_points_earned': legacyPointsEarned,
        'date': date,
      };

  factory FinalEvaluation.fromJson(Map<String, dynamic> json) => FinalEvaluation(
        score: (json['score'] as num?)?.toInt() ?? 0,
        rankTitle: json['rank_title'] as String? ?? 'Garage Owner',
        titlesCount: (json['titles_count'] as num?)?.toInt() ?? 0,
        trophiesCount: (json['trophies_count'] as num?)?.toInt() ?? 0,
        legendsDeveloped: (json['legends_developed'] as num?)?.toInt() ?? 0,
        peakFame: (json['peak_fame'] as num?)?.toInt() ?? 0,
        peakFans: (json['peak_fans'] as num?)?.toInt() ?? 0,
        totalRevenue: (json['total_revenue'] as num?)?.toInt() ?? 0,
        legacyPointsEarned: (json['legacy_points_earned'] as num?)?.toInt() ?? 0,
        date: json['date'] as String? ?? 'Y10 W48',
      );
}

class LegacyPerkDef {
  final String id;
  final String name;
  final String description;
  final int pointCost;

  const LegacyPerkDef({
    required this.id,
    required this.name,
    required this.description,
    required this.pointCost,
  });
}

class LegacyState {
  int totalLegacyPoints;
  List<String> activePerkIds;
  List<FinalEvaluation> pastEvaluations;
  bool isEndlessMode;

  static const List<LegacyPerkDef> availablePerks = [
    LegacyPerkDef(
      id: 'extra_cash_1',
      name: 'Dagdag Pondo I',
      description: '+P25,000 panimulang kapital sa New Game',
      pointCost: 2,
    ),
    LegacyPerkDef(
      id: 'extra_cash_2',
      name: 'Dagdag Pondo II',
      description: '+P50,000 panimulang kapital sa New Game',
      pointCost: 4,
    ),
    LegacyPerkDef(
      id: 'comfy_bed',
      name: 'Comfy Bed Upgrade',
      description: 'Panimulang kama ay Comfy Bed agad para sa mas mabilis na recovery',
      pointCost: 3,
    ),
    LegacyPerkDef(
      id: 'pro_desk',
      name: 'Pro Gaming Desks',
      description: 'Lahat ng 3 starter PC ay Pro Desks (x1.25 training boost)',
      pointCost: 4,
    ),
    LegacyPerkDef(
      id: 'legend_coach',
      name: 'Beteranong Coach',
      description: 'May kasama agad na Level 3 Head Coach sa Day 1',
      pointCost: 5,
    ),
    LegacyPerkDef(
      id: 'dynasty_emblem',
      name: 'Gintong Agila Emblem',
      description: 'Eksklusibong gintong dynasty emblem at +100 panimulang Fame',
      pointCost: 2,
    ),
  ];

  LegacyState({
    this.totalLegacyPoints = 0,
    List<String>? activePerkIds,
    List<FinalEvaluation>? pastEvaluations,
    this.isEndlessMode = false,
  })  : activePerkIds = activePerkIds ?? [],
        pastEvaluations = pastEvaluations ?? [];

  Map<String, dynamic> toJson() => {
        'total_legacy_points': totalLegacyPoints,
        'active_perk_ids': activePerkIds,
        'past_evaluations': pastEvaluations.map((e) => e.toJson()).toList(),
        'is_endless_mode': isEndlessMode,
      };

  factory LegacyState.fromJson(Map<String, dynamic> json) => LegacyState(
        totalLegacyPoints: (json['total_legacy_points'] as num?)?.toInt() ?? 0,
        activePerkIds: (json['active_perk_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        pastEvaluations: (json['past_evaluations'] as List<dynamic>?)
                ?.map((e) => FinalEvaluation.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        isEndlessMode: json['is_endless_mode'] as bool? ?? false,
      );
}
