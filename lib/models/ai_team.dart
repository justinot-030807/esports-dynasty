class AiTeam {
  final String id;
  final String name;
  final int tier;
  final String region;
  final List<String> colors;
  int rating;
  final String style; // 'Rush', 'Teamfight', 'Scale', 'Split'
  final String? captain;
  final String? catchphrase;
  int circuitPoints;
  int fans;
  int fame;
  int rank;
  List<String> form;

  AiTeam({
    required this.id,
    required this.name,
    required this.tier,
    required this.region,
    required this.colors,
    required this.rating,
    this.style = 'Teamfight',
    this.captain,
    this.catchphrase,
    this.circuitPoints = 0,
    this.fans = 100,
    this.fame = 0,
    this.rank = 99,
    List<String>? form,
  }) : form = form ?? [];

  bool get isFlagship => captain != null && captain!.isNotEmpty;

  factory AiTeam.fromJson(Map<String, dynamic> json) {
    return AiTeam(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      tier: (json['tier'] as num?)?.toInt() ?? 1,
      region: json['region'] as String? ?? 'NCR',
      colors: (json['colors'] as List<dynamic>? ?? ['#1B2A49', '#F5B700'])
          .map((e) => e.toString())
          .toList(),
      rating: (json['rating'] as num?)?.toInt() ?? 35,
      style: json['style'] as String? ?? 'Teamfight',
      captain: json['captain'] as String?,
      catchphrase: json['catchphrase'] as String?,
      circuitPoints: (json['circuitPoints'] as num?)?.toInt() ?? 0,
      fans: (json['fans'] as num?)?.toInt() ?? 100,
      fame: (json['fame'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 99,
      form: (json['form'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tier': tier,
    'region': region,
    'colors': colors,
    'rating': rating,
    'style': style,
    'captain': captain,
    'catchphrase': catchphrase,
    'circuitPoints': circuitPoints,
    'fans': fans,
    'fame': fame,
    'rank': rank,
    'form': form,
  };
}
