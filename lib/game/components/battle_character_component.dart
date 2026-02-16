import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import '../../domain/character/character.dart';
import '../../domain/character/status_effect.dart';

class BattleCharacterComponent extends SpriteComponent {
  final Character character;
  final bool isPlayer;
  late final Paint normalPaint;
  late final Paint flashPaint;
  late final Paint telegraphPaint;
  late final TextPaint hpTextPaint;
  late final TextPaint nameTextPaint;
  late final Paint manaPaint;
  late final Paint hpBackPaint;
  late final Paint hpFillPaint;
  late final Paint manaBackPaint;
  late final Paint shadowPaint;
  late final TextPaint statusTextPaint;
  Vector2 _basePosition;

  double attackTimer = 0;
  final double baseCooldown = 3.0;

  double hitFlash = 0;
  bool telegraphActive = false;
  double _telegraphPhase = 0;
  double _idlePhase = 0;
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
    hpBackPaint = Paint()..color = const Color(0xFF263238);
    hpFillPaint = Paint()..color = const Color(0xFF66BB6A);
    manaBackPaint = Paint()..color = const Color(0xFF1B2A3A);
    shadowPaint = Paint()..color = Colors.black.withOpacity(0.3);
    statusTextPaint = TextPaint(
      style: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    );
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
    _idlePhase += dt * 2.2;

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
      scale = Vector2.all(1.0 + 0.02 * math.sin(progress * math.pi));
    } else {
      final idleY = math.sin(_idlePhase) * 3.0;
      final idleX = math.sin(_idlePhase * 0.6) * 1.5;
      position = _basePosition + Vector2(idleX, idleY);
      angle = 0;
      final pulse = telegraphActive ? 0.03 : 0.012;
      final speed = telegraphActive ? 7.0 : 3.0;
      scale = Vector2.all(1.0 + pulse * math.sin(_idlePhase * speed));
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
    final shadowWidth = size.x * 0.6;
    final shadowHeight = size.y * 0.16;
    final shadowRect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y * 0.88),
      width: shadowWidth,
      height: shadowHeight,
    );
    canvas.drawOval(shadowRect, shadowPaint);

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
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, -12, size.x, 6),
        const Radius.circular(3),
      ),
      hpBackPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, -12, barWidth, 6),
        const Radius.circular(3),
      ),
      hpFillPaint,
    );

    if (character.maxMana > 0) {
      final manaPercent = character.mana / character.maxMana;
      final manaWidth = size.x * manaPercent;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, -4, size.x, 4),
          const Radius.circular(2),
        ),
        manaBackPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, -4, manaWidth, 4),
          const Radius.circular(2),
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

    _renderStatuses(canvas);
  }

  void _renderStatuses(Canvas canvas) {
    if (character.statuses.isEmpty) return;
    final entries = character.statuses.entries.toList();
    final iconSize = 12.0;
    final spacing = 4.0;
    final totalWidth = entries.length * iconSize + (entries.length - 1) * spacing;
    var startX = (size.x - totalWidth) / 2;
    final y = -52.0;

    for (final entry in entries) {
      final color = _colorForStatus(entry.key);
      final label = _labelForStatus(entry.key);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(startX, y, iconSize, iconSize),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, Paint()..color = color);
      statusTextPaint.render(
        canvas,
        label,
        Vector2(startX + iconSize / 2, y + iconSize / 2),
        anchor: Anchor.center,
      );
      startX += iconSize + spacing;
    }
  }

  Color _colorForStatus(StatusType type) {
    switch (type) {
      case StatusType.burn:
        return const Color(0xFFFF7043);
      case StatusType.freeze:
        return const Color(0xFF4FC3F7);
      case StatusType.warcry:
        return const Color(0xFFFFD54F);
      case StatusType.poison:
        return const Color(0xFF66BB6A);
      case StatusType.hex:
        return const Color(0xFF9575CD);
      case StatusType.berserk:
        return const Color(0xFFFF5252);
      case StatusType.enraged:
        return const Color(0xFFFF3D00);
    }
  }

  String _labelForStatus(StatusType type) {
    switch (type) {
      case StatusType.burn:
        return 'B';
      case StatusType.freeze:
        return 'F';
      case StatusType.warcry:
        return 'W';
      case StatusType.poison:
        return 'P';
      case StatusType.hex:
        return 'H';
      case StatusType.berserk:
        return 'R';
      case StatusType.enraged:
        return 'E';
    }
  }
}
