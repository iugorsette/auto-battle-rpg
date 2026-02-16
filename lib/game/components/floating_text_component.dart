import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

class FloatingTextComponent extends PositionComponent {
  FloatingTextComponent({
    required String text,
    required Vector2 position,
    required Color color,
    double duration = 1.0,
    double fontSize = 26,
  })  : _text = text,
        _baseColor = color,
        _duration = duration,
        _remaining = duration,
        _fontSize = fontSize,
        super(
          position: position,
          anchor: Anchor.center,
        );

  final String _text;
  final Color _baseColor;
  final double _duration;
  double _remaining;
  final double _fontSize;

  late final Vector2 _velocity = Vector2(_drift, -90);
  final double _drift = (0.5 - (DateTime.now().microsecond % 1000) / 1000) * 18;
  late final TextPaint _textPaint = TextPaint(
    style: TextStyle(
      color: _baseColor,
      fontSize: _fontSize,
      fontWeight: FontWeight.bold,
      shadows: const [
        Shadow(
          blurRadius: 6,
          color: Color(0xCC000000),
          offset: Offset(0, 2),
        ),
      ],
    ),
  );

  @override
  void update(double dt) {
    super.update(dt);

    _remaining -= dt;
    position += _velocity * dt;

    if (_remaining <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (_remaining / _duration).clamp(0.0, 1.0);
    final opacity = 0.2 + 0.8 * progress;
    final scale = 1.15 - (1 - progress) * 0.15;
    final textPaint = _textPaint.copyWith(
      (style) => style.copyWith(color: _baseColor.withOpacity(opacity)),
    );

    canvas.save();
    canvas.scale(scale, scale);
    textPaint.render(canvas, _text, Vector2.zero(), anchor: Anchor.center);
    canvas.restore();
  }
}
