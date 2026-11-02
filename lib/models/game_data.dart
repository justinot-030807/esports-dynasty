/// Typed Dart classes for all assets/data/ JSON files
class BalanceData {
  final int startingMoney;
  final int startingFame;
  final int startingFans;
  final int startingHouseTier;
  final double speed1xSeconds;
  final double speed2xSeconds;
  final double speed4xSeconds;
  final Map<String, int> salariesWeekly;
  final List<HouseTierDef> houseTiers;

  BalanceData({
    required this.startingMoney,
    required this.startingFame,
    required this.startingFans,
    required this.startingHouseTier,
    required this.speed1xSeconds,
    required this.speed2xSeconds,
    required this.speed4xSeconds,
    required this.salariesWeekly,
    required this.houseTiers,
  });

  factory BalanceData.fromJson(Map<String, dynamic> json) {
    final starting = json['starting'] as Map<String, dynamic>? ?? {};
    final time = json['time'] as Map<String, dynamic>? ?? {};
    final salaries = (json['salaries_weekly'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, (v as num).toInt()));
    final tiers = (json['house_tiers'] as List<dynamic>? ?? [])
        .map((e) => HouseTierDef.fromJson(e as Map<String, dynamic>))
        .toList();

    return BalanceData(
      startingMoney: (starting['money'] as num?)?.toInt() ?? 50000,
      startingFame: (starting['fame'] as num?)?.toInt() ?? 0,
      startingFans: (starting['fans'] as num?)?.toInt() ?? 50,
      startingHouseTier: (starting['house_tier'] as num?)?.toInt() ?? 0,
      speed1xSeconds: (time['speed_1x_seconds'] as num?)?.toDouble() ?? 8.0,
      speed2xSeconds: (time['speed_2x_seconds'] as num?)?.toDouble() ?? 4.0,
      speed4xSeconds: (time['speed_4x_seconds'] as num?)?.toDouble() ?? 2.0,
      salariesWeekly: salaries,
      houseTiers: tiers,
    );
  }
}

class HouseTierDef {
  final String id;
  final String name;
  final int gridW;
  final int gridH;
  final int cost;
  final int fameReq;
  final int rentMonthly;
  final int staffSlots;
  final int rosterCap;

  HouseTierDef({
    required this.id,
    required this.name,
    required this.gridW,
    required this.gridH,
    required this.cost,
    required this.fameReq,
    required this.rentMonthly,
    required this.staffSlots,
    required this.rosterCap,
  });

  factory HouseTierDef.fromJson(Map<String, dynamic> json) {
    return HouseTierDef(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      gridW: (json['grid_w'] as num?)?.toInt() ?? 8,
      gridH: (json['grid_h'] as num?)?.toInt() ?? 6,
      cost: (json['cost'] as num?)?.toInt() ?? 0,
      fameReq: (json['fame_req'] as num?)?.toInt() ?? 0,
      rentMonthly: (json['rent_monthly'] as num?)?.toInt() ?? 0,
      staffSlots: (json['staff_slots'] as num?)?.toInt() ?? 1,
      rosterCap: (json['roster_cap'] as num?)?.toInt() ?? 6,
    );
  }
}

class ItemDef {
  final String id;
  final String name;
  final String category;
  final int sizeX;
  final int sizeY;
  final int price;
  final int fameReq;
  final String station;
  final String desc;

  ItemDef({
    required this.id,
    required this.name,
    required this.category,
    required this.sizeX,
    required this.sizeY,
    required this.price,
    required this.fameReq,
    required this.station,
    required this.desc,
  });

  factory ItemDef.fromJson(Map<String, dynamic> json) {
    return ItemDef(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      sizeX: (json['size_x'] as num?)?.toInt() ?? 1,
      sizeY: (json['size_y'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toInt() ?? 0,
      fameReq: (json['fame_req'] as num?)?.toInt() ?? 0,
      station: json['station'] as String? ?? 'none',
      desc: json['desc'] as String? ?? '',
    );
  }
}

class TeamDef {
  final String id;
  final String name;
  final int tier;
  final String region;
  final List<String> colors;
  final int rating;
  final String? captain;
  final String? catchphrase;

  TeamDef({
    required this.id,
    required this.name,
    required this.tier,
    required this.region,
    required this.colors,
    required this.rating,
    this.captain,
    this.catchphrase,
  });

  factory TeamDef.fromJson(Map<String, dynamic> json) {
    return TeamDef(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      tier: (json['tier'] as num?)?.toInt() ?? 1,
      region: json['region'] as String? ?? '',
      colors: (json['colors'] as List<dynamic>? ?? ['#1B2A49', '#F5B700'])
          .map((e) => e.toString())
          .toList(),
      rating: (json['rating'] as num?)?.toInt() ?? 30,
      captain: json['captain'] as String?,
      catchphrase: json['catchphrase'] as String?,
    );
  }
}

class GameEventDef {
  final String id;
  final String title;
  final String category;
  final String text;

  GameEventDef({
    required this.id,
    required this.title,
    required this.category,
    required this.text,
  });

  factory GameEventDef.fromJson(Map<String, dynamic> json) {
    return GameEventDef(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }
}
