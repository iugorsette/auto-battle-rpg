import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ProjectileComponent extends PositionComponent {
  ProjectileComponent({
    required Vector2 start,
    required Vector2 end,
    required double duration,
    required Color color,
    double radius = 6,
    this.isArrow = false,
    this.onHit,
  })  : _start = start.clone(),
        _end = end.clone(),
        _duration = duration,
        _remaining = duration,
        _color = color,
        _radius = radius,
        super(
          position: start.clone(),
          anchor: Anchor.center,
        ) {
    final dir = _end - _start;
    _angle = math.atan2(dir.y, dir.x);
  }

  final Vector2 _start;
  final Vector2 _end;
  final double _duration;
  double _remaining;
  final Color _color;
  final double _radius;
  final bool isArrow;
  final VoidCallback? onHit;

  late final Paint _paint = Paint()..color = _color;
  late final Paint _glowPaint = Paint()..color = _color.withOpacity(0.35);
  late final double _angle;

  @override
  void update(double dt) {
    super.update(dt);

    _remaining -= dt;
    final progress = (1 - (_remaining / _duration)).clamp(0.0, 1.0);
    position = _start + (_end - _start) * progress;
    angle = _angle;

    if (_remaining <= 0) {
      onHit?.call();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (isArrow) {
      _renderArrow(canvas);
    } else {
      _renderOrb(canvas);
    }
  }

  void _renderArrow(Canvas canvas) {
    final path = Path()
      ..moveTo(-_radius, -_radius * 0.35)
      ..lineTo(_radius, 0)
      ..lineTo(-_radius, _radius * 0.35)
      ..close();
    canvas.drawPath(path, _paint);
  }

  void _renderOrb(Canvas canvas) {
    canvas.drawCircle(Offset.zero, _radius + 3, _glowPaint);
    canvas.drawCircle(Offset.zero, _radius, _paint);
  }
}
