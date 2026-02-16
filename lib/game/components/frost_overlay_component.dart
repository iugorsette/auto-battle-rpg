import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FrostOverlayComponent extends PositionComponent {
  FrostOverlayComponent({
    required Vector2 position,
    double duration = 0.7,
    double radius = 46,
  })  : _duration = duration,
        _remaining = duration,
        _radius = radius,
        super(
          position: position,
          anchor: Anchor.center,
        );

  final double _duration;
  double _remaining;
  final double _radius;

  late final Paint _paint = Paint()..color = const Color(0xFF90CAF9);

  @override
  void update(double dt) {
    super.update(dt);
    _remaining -= dt;
    if (_remaining <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (1 - (_remaining / _duration)).clamp(0.0, 1.0);
    final opacity = 0.15 + 0.35 * (1 - progress);
    _paint.color = const Color(0xFF90CAF9).withOpacity(opacity);
    canvas.drawCircle(Offset.zero, _radius, _paint);
  }
}
