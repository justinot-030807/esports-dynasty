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

  HubHouseAssets({
    required this.charIdle,
    required this.charStep1,
    required this.charStep2,
    required this.deskImage,
    required this.bedImage,
    required this.kitchenImage,
    required this.shelfImage,
    required this.roomBg,
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

    return HubHouseAssets(
      charIdle: idle,
      charStep1: step1,
      charStep2: step2,
      deskImage: desk,
      bedImage: bed,
      kitchenImage: kitchen,
      shelfImage: shelf,
      roomBg: bg,
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
