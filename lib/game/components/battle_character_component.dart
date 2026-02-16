import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import '../../domain/character/character.dart';

class BattleCharacterComponent extends SpriteComponent {
  final Character character;
  final bool isPlayer;
  late final Paint normalPaint;
  late final Paint flashPaint;
  late final Paint telegraphPaint;
  late final TextPaint hpTextPaint;
  late final TextPaint nameTextPaint;
  late final Paint manaPaint;
  Vector2 _basePosition;

  double attackTimer = 0;
  final double baseCooldown = 3.0;

  double hitFlash = 0;
  bool telegraphActive = false;
  double _telegraphPhase = 0;
  double _lungeTimer = 0;
  final double _lungeDuration = 0.22;
  final double _lungeDistance = 12;

  BattleCharacterComponent({
    required this.character,
    required this.isPlayer,
    required Vector2 position,
    required Sprite sprite,
    Vector2? size,
  })  : _basePosition = position.clone(),
        super(
          sprite: sprite,
          position: position,
          size: size ?? Vector2(96, 96),
          anchor: Anchor.center,
        ) {
    normalPaint = Paint();
    flashPaint = Paint()..color = const Color(0xFFFFFFFF);
    telegraphPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    hpTextPaint = TextPaint(
      style: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
    nameTextPaint = TextPaint(
      style: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
    manaPaint = Paint()..color = const Color(0xFF42A5F5);
  }

  double get attackCooldown {
    final override = character.attackCooldownOverride;
    if (override != null) {
      final adjusted = override / character.attackSpeedMultiplier;
      return adjusted.clamp(0.1, 10.0);
    }
    final speedFactor = (1 + character.speed * 0.25) * character.attackSpeedMultiplier;
    final cooldown = baseCooldown / speedFactor;
    return cooldown.clamp(1.5, 5.0);
  }

  @override
  void update(double dt) {
    super.update(dt);
    attackTimer += dt;

    if (hitFlash > 0) {
      hitFlash -= dt;
    }

    if (telegraphActive) {
      _telegraphPhase += dt * 6;
    } else {
      _telegraphPhase = 0;
    }

    if (_lungeTimer > 0) {
      _lungeTimer = (_lungeTimer - dt).clamp(0.0, _lungeDuration);
      final progress = 1 - (_lungeTimer / _lungeDuration);
      final eased = progress <= 0.5 ? (progress * 2) : (2 - progress * 2);
      final direction = isPlayer ? 1.0 : -1.0;
      final offset = _lungeDistance * eased * direction;
      position = _basePosition + Vector2(offset, 0);
      angle = 0.08 * math.sin(progress * math.pi) * direction;
    } else {
      position = _basePosition.clone();
      angle = 0;
    }
  }

  bool canAttack() => attackTimer >= attackCooldown;

  void resetAttack() {
    attackTimer = 0;
  }

  void setBasePosition(Vector2 value) {
    _basePosition = value.clone();
    position = value.clone();
  }

  void triggerLunge() {
    _lungeTimer = _lungeDuration;
  }

  @override
  void render(Canvas canvas) {
    if (telegraphActive) {
      final pulse = 0.5 + 0.5 * math.sin(_telegraphPhase);
      final radius = (size.x * 0.6) + (6 * pulse);
      final center = Offset(size.x / 2, size.y / 2);
      telegraphPaint.color = const Color(0xFFFFD54F).withOpacity(0.2 + 0.35 * pulse);
      canvas.drawCircle(center, radius, telegraphPaint);
    }

    paint = hitFlash > 0 ? flashPaint : normalPaint;

    super.render(canvas);

    // HP BAR
    final hpPercent = character.hp / character.maxHp;
    final barWidth = size.x * hpPercent;

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        -10,
        barWidth,
        6,
      ),
      Paint()..color = const Color(0xFF00FF00),
    );

    if (character.maxMana > 0) {
      final manaPercent = character.mana / character.maxMana;
      final manaWidth = size.x * manaPercent;
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          -2,
          manaWidth,
          4,
        ),
        manaPaint,
      );
    }

    hpTextPaint.render(
      canvas,
      '${character.hp}/${character.maxHp}',
      Vector2(size.x / 2, -22),
      anchor: Anchor.center,
    );

    nameTextPaint.render(
      canvas,
      character.name,
      Vector2(size.x / 2, -36),
      anchor: Anchor.center,
    );
  }
}
