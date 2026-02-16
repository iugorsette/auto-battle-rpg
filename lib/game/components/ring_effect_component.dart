import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class RingEffectComponent extends PositionComponent {
  RingEffectComponent({
    required Vector2 position,
    required Color color,
    double duration = 0.6,
    double startRadius = 8,
    double endRadius = 40,
    double strokeWidth = 3,
  })  : _color = color,
        _duration = duration,
        _remaining = duration,
        _startRadius = startRadius,
        _endRadius = endRadius,
        _strokeWidth = strokeWidth,
        super(
          position: position,
          anchor: Anchor.center,
        );

  final Color _color;
  final double _duration;
  double _remaining;
  final double _startRadius;
  final double _endRadius;
  final double _strokeWidth;

  late final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = _strokeWidth
    ..color = _color;

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
    final radius = _startRadius + (_endRadius - _startRadius) * progress;
    final opacity = 1 - progress;
    _paint.color = _color.withOpacity(0.2 + 0.8 * opacity);
    canvas.drawCircle(Offset.zero, radius, _paint);
  }
}
