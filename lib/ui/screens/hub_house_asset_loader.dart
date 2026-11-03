import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../../core/asset_manager.dart';

class HubHouseAssets {
  final ui.Image charIdle;
  final ui.Image charStep1;
  final ui.Image charStep2;
  final ui.Image deskImage;
  final ui.Image bedImage;
  final ui.Image kitchenImage;
  final ui.Image shelfImage;
  final ui.Image roomBg;
  final ui.Image? foodImage;
  final Map<String, ui.Image> stationImages;

  HubHouseAssets({
    required this.charIdle,
    required this.charStep1,
    required this.charStep2,
    required this.deskImage,
    required this.bedImage,
    required this.kitchenImage,
    required this.shelfImage,
    required this.roomBg,
    this.foodImage,
    this.stationImages = const {},
  });

  static Future<HubHouseAssets> load() async {
    final idle = await _loadImage(AssetManager.gamerM01Idle);
    final step1 = await _loadImage(AssetManager.gamerM01Step1);
    final step2 = await _loadImage(AssetManager.gamerM01Step2);
    final desk = await _loadImage(AssetManager.pcDesk);
    final bed = await _loadImage(AssetManager.bunkBed);
    final kitchen = await _loadImage(AssetManager.kitchen);
    final shelf = await _loadImage(AssetManager.trophyShelf);
    final bg = await _loadImage(AssetManager.roomBg);
    ui.Image? food;
    try {
      food = await _loadImage('assets/images/food/meal_adobo.png');
    } catch (_) {}

    final stationKeys = [
      'streaming_booth', 'streaming_booth_on1', 'streaming_booth_on2',
      'gym_corner', 'gym_corner_on1', 'gym_corner_on2',
      'merch_corner', 'merch_corner_on1', 'merch_corner_on2',
    ];
    final Map<String, ui.Image> stationMap = {};
    for (final k in stationKeys) {
      try {
        stationMap[k] = await _loadImage('assets/images/furniture/$k.png');
      } catch (_) {}
    }

    return HubHouseAssets(
      charIdle: idle,
      charStep1: step1,
      charStep2: step2,
      deskImage: desk,
      bedImage: bed,
      kitchenImage: kitchen,
      shelfImage: shelf,
      roomBg: bg,
      foodImage: food,
      stationImages: stationMap,
    );
  }

  static Future<ui.Image> _loadImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
