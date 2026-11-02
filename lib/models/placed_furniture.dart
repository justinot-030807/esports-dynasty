class PlacedFurniture {
  final String id;
  final String itemId;
  final String name;
  final int tileX;
  final int tileY;
  final int sizeX;
  final int sizeY;
  final String station;

  PlacedFurniture({
    required this.id,
    required this.itemId,
    required this.name,
    required this.tileX,
    required this.tileY,
    required this.sizeX,
    required this.sizeY,
    required this.station,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemId': itemId,
    'name': name,
    'tileX': tileX,
    'tileY': tileY,
    'sizeX': sizeX,
    'sizeY': sizeY,
    'station': station,
  };

  factory PlacedFurniture.fromJson(Map<String, dynamic> json) {
    return PlacedFurniture(
      id: json['id'] as String? ?? 'f_${DateTime.now().millisecondsSinceEpoch}',
      itemId: json['itemId'] as String? ?? 'pc_desk',
      name: json['name'] as String? ?? 'Gaming PC Desk',
      tileX: (json['tileX'] as num?)?.toInt() ?? 0,
      tileY: (json['tileY'] as num?)?.toInt() ?? 0,
      sizeX: (json['sizeX'] as num?)?.toInt() ?? 2,
      sizeY: (json['sizeY'] as num?)?.toInt() ?? 1,
      station: json['station'] as String? ?? 'pc',
    );
  }
}
