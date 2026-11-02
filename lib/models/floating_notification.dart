class FloatingNotification {
  final String text;
  final String colorHex;
  double posX;
  double posY;
  double lifeTime;

  FloatingNotification({
    required this.text,
    required this.colorHex,
    required this.posX,
    required this.posY,
    this.lifeTime = 1.0,
  });
}
