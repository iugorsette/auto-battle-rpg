import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class BattleBackgroundComponent extends PositionComponent with HasGameRef<FlameGame> {
  BattleBackgroundComponent({
    math.Random? rng,
  }) : _rng = rng ?? math.Random();

  final math.Random _rng;
  final List<_Cloud> _clouds = [];
  double _time = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _clouds.clear();
    for (var i = 0; i < 7; i++) {
      _clouds.add(
        _Cloud(
          x: _rng.nextDouble(),
          y: 0.1 + _rng.nextDouble() * 0.35,
          scale: 0.6 + _rng.nextDouble() * 0.6,
          speed: 0.02 + _rng.nextDouble() * 0.05,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    for (final cloud in _clouds) {
      cloud.x += cloud.speed * dt;
      if (cloud.x > 1.2) {
        cloud.x = -0.2;
        cloud.y = 0.1 + _rng.nextDouble() * 0.35;
        cloud.scale = 0.6 + _rng.nextDouble() * 0.6;
        cloud.speed = 0.02 + _rng.nextDouble() * 0.05;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0E1C2E),
          Color(0xFF1E3554),
          Color(0xFF2D4B6A),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    final sunCenter = Offset(size.x * 0.78, size.y * 0.18);
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFE8A3).withOpacity(0.9),
          const Color(0x00FFE8A3),
        ],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: size.x * 0.25));
    canvas.drawCircle(sunCenter, size.x * 0.18, sunPaint);

    _drawMountainLayer(
      canvas,
      size,
      baseline: size.y * 0.62,
      amplitude: 0.14,
      color: const Color(0xFF20314A),
      seedOffset: 0,
    );
    _drawMountainLayer(
      canvas,
      size,
      baseline: size.y * 0.68,
      amplitude: 0.18,
      color: const Color(0xFF17263A),
      seedOffset: 2,
    );

    final groundRect = Rect.fromLTWH(0, size.y * 0.7, size.x, size.y * 0.3);
    final groundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2B3F2E),
          Color(0xFF1A271E),
        ],
      ).createShader(groundRect);
    canvas.drawRect(groundRect, groundPaint);

    for (final cloud in _clouds) {
      final cx = size.x * cloud.x;
      final cy = size.y * cloud.y;
      final cloudWidth = size.x * 0.18 * cloud.scale;
      final cloudHeight = size.y * 0.06 * cloud.scale;
      final alpha = (0.3 + 0.2 * math.sin(_time + cloud.x)).clamp(0.2, 0.5);
      final cloudPaint = Paint()..color = const Color(0xFFE0F2FF).withOpacity(alpha);
      final baseRect = Rect.fromCenter(
        center: Offset(cx, cy),
        width: cloudWidth,
        height: cloudHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(baseRect, Radius.circular(cloudHeight / 2)),
        cloudPaint,
      );
      canvas.drawCircle(Offset(cx - cloudWidth * 0.25, cy - cloudHeight * 0.15), cloudHeight * 0.45, cloudPaint);
      canvas.drawCircle(Offset(cx, cy - cloudHeight * 0.25), cloudHeight * 0.55, cloudPaint);
      canvas.drawCircle(Offset(cx + cloudWidth * 0.2, cy - cloudHeight * 0.1), cloudHeight * 0.42, cloudPaint);
    }

    final vignettePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x00000000),
          const Color(0xAA000000),
        ],
        stops: const [0.6, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignettePaint);
  }

  void _drawMountainLayer(
    Canvas canvas,
    Vector2 size, {
    required double baseline,
    required double amplitude,
    required Color color,
    required int seedOffset,
  }) {
    final path = Path()..moveTo(0, baseline);
    for (var i = 0; i <= 6; i++) {
      final x = size.x * (i / 6);
      final wave = math.sin((i + seedOffset) * 1.3) * amplitude;
      final y = baseline - size.y * (0.05 + wave);
      path.lineTo(x, y);
    }
    path.lineTo(size.x, size.y);
    path.lineTo(0, size.y);
    path.close();
    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }
}

class _Cloud {
  _Cloud({
    required this.x,
    required this.y,
    required this.scale,
    required this.speed,
  });

  double x;
  double y;
  double scale;
  double speed;
}
