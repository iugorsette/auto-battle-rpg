import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../domain/character/character.dart';
import '../domain/character/status_effect.dart';
import '../domain/skills/basic_skills.dart';
import '../domain/skills/skill.dart';
import 'components/battle_character_component.dart';
import 'components/floating_text_component.dart';
import 'components/frost_overlay_component.dart';
import 'components/projectile_component.dart';
import 'components/ring_effect_component.dart';
import 'components/battle_background_component.dart';
import 'sound/sound_manager.dart';

class BattlerGame extends FlameGame {
  final Character player;
  final List<Character> enemies;

  /// Callback chamado quando a batalha termina
  VoidCallback? onBattleEnd;
  /// Callback para atualizar a UI a cada "tick" de batalha
  VoidCallback? onBattleTick;
  final ValueNotifier<int> uiTick = ValueNotifier<int>(0);
  bool _uiUpdateScheduled = false;

  bool _battleEnded = false;
  bool _playerWon = false;
  bool _componentsReady = false;

  late BattleCharacterComponent playerComponent;
  late List<BattleCharacterComponent> enemyComponents;
  BattleBackgroundComponent? backgroundComponent;

  static const double _attackWindUp = 0.35;
  static const double _attackRecovery = 0.15;
  static const double _parryWindow = 0.2;
  static const double _skillTickInterval = 1.0;
  static const double _turnGap = 0.25;
  static const double _archerLuckyShotChance = 0.2;
  static const double _archerCritMultiplier = 1.5;
  static const double _arrowTravelTime = 0.22;
  static const double _fireballTravelTime = 0.35;
  static const double _sureShotChargeTime = 1.0;
  static const double _dragonWindUp = 0.3;
  static const double _dragonFireTravelTime = 0.25;
  static const int _manaRegenPerTick = 8;
  static const double _spinMultiplier = 1.15;
  static const double _arrowRainDamageMultiplier = 0.6;
  static const int _arrowRainWaves = 3;
  static const double _arrowRainInterval = 1.0;
  static const double _arrowRainDropHeight = 160;
  static const double _incinerateTotalMultiplier = 1.8;
  static const double _incinerateSpreadMultiplier = 1.2;
  static const int _incinerateTicks = 3;
  static const double _incinerateWindow = 3.0;

  double battleTime = 0;
  double _skillTickTimer = 0;
  double _turnGapTimer = 0;

  _PendingAttack? _activeAttack;
  BattleCharacterComponent? _activeAttacker;
  BattleCharacterComponent? _activeDefender;
  bool _nextAttackIsPlayer = true;
  int _nextEnemyIndex = 0;
  final math.Random _rng = math.Random();
  final List<_TimedEffect> _timedEffects = [];
  final List<_DelayedAction> _delayedActions = [];
  final List<String> _combatLog = [];
  final Map<Character, int> _attackCounts = {};
  final Set<Character> _berserked = {};
  final Set<Character> _phaseTwo = {};
  final Map<Character, _IncinerateMark> _incinerateMarks = {};

  BattlerGame({
    required this.player,
    required this.enemies,
  });

  /// Indica se o jogador venceu a batalha
  bool get isVictory => _playerWon;

  Character? get firstAliveEnemy {
    for (final enemy in enemies) {
      if (enemy.isAlive) return enemy;
    }
    return null;
  }

  List<String> get combatLog => List.unmodifiable(_combatLog);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    images.prefix = 'assets/';
    await SoundManager.init();

    backgroundComponent = BattleBackgroundComponent()..priority = -10;

    add(backgroundComponent!);

    final playerImage = await images.load(
      _spriteForCharacter(player),
    );

    final playerSprite = Sprite(playerImage);

    final baseSize = Vector2(96, 96);
    playerComponent = BattleCharacterComponent(
      character: player,
      isPlayer: true,
      position: Vector2(120, size.y / 2),
      sprite: playerSprite,
      size: baseSize * player.sizeScale,
    );

    enemyComponents = [];
    for (final enemy in enemies) {
      final enemyImage = await images.load(
        _spriteForCharacter(enemy),
      );
      final enemySprite = Sprite(enemyImage);
      enemyComponents.add(
        BattleCharacterComponent(
          character: enemy,
          isPlayer: false,
          position: Vector2(size.x - 120, size.y / 2),
          sprite: enemySprite,
          size: baseSize * enemy.sizeScale,
        ),
      );
    }

    addAll([
      playerComponent,
      ...enemyComponents,
    ]);

    _componentsReady = true;
    _layoutEnemyComponents();

    player.onDamage = (event) => _spawnDamageText(event, playerComponent);
    for (final enemyComponent in enemyComponents) {
      enemyComponent.character.onDamage =
          (event) => _spawnDamageText(event, enemyComponent);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layoutEnemyComponents();
  }

  void _layoutEnemyComponents() {
    if (!_componentsReady) return;
    if (enemyComponents.isEmpty) return;

    playerComponent.setBasePosition(Vector2(120, size.y / 2));

    var maxHeight = 96.0;
    for (final enemyComponent in enemyComponents) {
      if (enemyComponent.size.y > maxHeight) {
        maxHeight = enemyComponent.size.y;
      }
    }
    final spacing = maxHeight + 24;
    final totalHeight = spacing * (enemyComponents.length - 1);
    final startY = (size.y / 2) - (totalHeight / 2);

    for (var i = 0; i < enemyComponents.length; i++) {
      enemyComponents[i]
          .setBasePosition(Vector2(size.x - 120, startY + i * spacing));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_battleEnded) return;
    if (!_componentsReady) return;

    battleTime += dt;
    _updateSkillCooldowns(dt);
    _updateDelayedActions(dt);
    _checkEnemyPhases();
    _turnGapTimer = (_turnGapTimer - dt).clamp(0.0, _turnGap);

    if (_activeAttack != null) {
      _updateActiveAttack(dt);
      checkBattleEnd();
      return;
    }

    bool startedAttack = false;
    if (_nextAttackIsPlayer) {
      startedAttack = _tryStartPlayerAttack();
      if (!startedAttack) {
        startedAttack = _tryStartEnemyAttack();
      }
    } else {
      startedAttack = _tryStartEnemyAttack();
      if (!startedAttack) {
        startedAttack = _tryStartPlayerAttack();
      }
    }

    if (startedAttack) {
      _nextAttackIsPlayer = !_nextAttackIsPlayer;
      _turnGapTimer = _turnGap;
    }

    checkBattleEnd();
  }

  void _updateSkillCooldowns(double dt) {
    _skillTickTimer += dt;
    if (_skillTickTimer < _skillTickInterval) return;

    final ticks = (_skillTickTimer / _skillTickInterval).floor();
    _skillTickTimer -= ticks * _skillTickInterval;

    for (var i = 0; i < ticks; i++) {
      for (final skill in player.skills) {
        skill.tick();
      }
      player.regenMana(_manaRegenPerTick);
      player.tickStatuses();
      for (final enemy in enemies) {
        for (final skill in enemy.skills) {
          skill.tick();
        }
        enemy.regenMana(_manaRegenPerTick);
        enemy.tickStatuses();
      }
      _tickEffects();
    }

    onBattleTick?.call();
    _notifyUi();
  }

  void _tickEffects() {
    for (var i = _timedEffects.length - 1; i >= 0; i--) {
      final effect = _timedEffects[i];
      effect.onTick?.call();
      effect.remainingTicks -= 1;
      if (effect.remainingTicks <= 0) {
        effect.onEnd?.call();
        _timedEffects.removeAt(i);
      }
    }
  }

  void _notifyUi() {
    if (_uiUpdateScheduled) return;
    _uiUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      uiTick.value = uiTick.value + 1;
      _uiUpdateScheduled = false;
    });
  }

  void _updateActiveAttack(double dt) {
    if (_activeAttack == null || _activeAttacker == null || _activeDefender == null) {
      _clearActiveAttack();
      return;
    }

    if (!_activeAttacker!.character.isAlive || !_activeDefender!.character.isAlive) {
      _clearActiveAttack();
      return;
    }

    _activeAttacker!.telegraphActive = !_activeAttack!.struck;
    _activeAttack!.elapsed += dt;

    if (!_activeAttack!.struck && _activeAttack!.elapsed >= _activeAttack!.windUp) {
      _performAttack(_activeAttacker!, _activeDefender!);
      _activeAttack!.struck = true;
      _activeAttacker!.telegraphActive = false;
      onBattleTick?.call();
      _notifyUi();
    }

    if (_activeAttack!.elapsed >= _activeAttack!.windUp + _attackRecovery) {
      _clearActiveAttack();
    }
  }

  void _clearActiveAttack() {
    _activeAttacker?.telegraphActive = false;
    _activeAttack = null;
    _activeAttacker = null;
    _activeDefender = null;
  }

  bool _tryStartPlayerAttack() {
    if (_turnGapTimer > 0) return false;
    if (!playerComponent.character.isAlive) return false;
    final target = _selectTargetEnemy();
    if (target == null) return false;
    if (!playerComponent.canAttack()) return false;

    _startAttack(attacker: playerComponent, defender: target);
    return true;
  }

  bool _tryStartEnemyAttack() {
    if (_turnGapTimer > 0) return false;
    if (enemyComponents.isEmpty) return false;

    for (var i = 0; i < enemyComponents.length; i++) {
      final index = (_nextEnemyIndex + i) % enemyComponents.length;
      final enemyComponent = enemyComponents[index];
      if (!enemyComponent.character.isAlive) continue;
      if (!enemyComponent.canAttack()) continue;

      _nextEnemyIndex = (index + 1) % enemyComponents.length;
      _startAttack(attacker: enemyComponent, defender: playerComponent);
      return true;
    }

    return false;
  }

  void _startAttack({
    required BattleCharacterComponent attacker,
    required BattleCharacterComponent defender,
  }) {
    attacker.resetAttack();
    if (!_isArcher(attacker.character) &&
        !_isMage(attacker.character) &&
        !_isDragon(attacker.character)) {
      attacker.triggerLunge();
    }

    _activeAttack = _PendingAttack(
      windUp: _isDragon(attacker.character) ? _dragonWindUp : _attackWindUp,
      parryWindow: _parryWindow,
    );
    _activeAttacker = attacker;
    _activeDefender = defender;
  }

  bool get isEnemyParryWindow =>
      _activeAttacker != null &&
      !_activeAttacker!.isPlayer &&
      (_activeAttack?.isParryWindow ?? false);

  double? get timeUntilEnemyStrike =>
      (_activeAttacker != null && !_activeAttacker!.isPlayer)
          ? _activeAttack?.timeUntilStrike
          : null;

  void castSkill(Skill skill, Character caster, Character target) {
    if (!skill.canUse(caster)) return;

    final casterComponent = _componentFor(caster);
    final targetComponent = _componentFor(target);
    _logEvent('${caster.name} usou ${skill.name}');

    if (skill is FireballSkill) {
      _spawnFireball(casterComponent, targetComponent);
      SoundManager.playSkill();
      caster.spendMana(skill.manaCost);
      skill.currentCooldown = skill.cooldown;
    } else if (skill is FreezeSkill) {
      _spawnFreeze(targetComponent);
      target.takeDamage(
        caster.attack,
        source: caster,
        type: DamageType.ice,
      );
      SoundManager.playSkill();
      caster.spendMana(skill.manaCost);
      skill.currentCooldown = skill.cooldown;
    } else if (skill is IncinerateSkill) {
      _castIncinerate(casterComponent, targetComponent);
      SoundManager.playSkill();
      caster.spendMana(skill.manaCost);
      skill.currentCooldown = skill.cooldown;
    } else if (skill is WarCrySkill) {
      _spawnWarCry(casterComponent);
      _applyWarCry(caster);
      SoundManager.playSkill();
      skill.currentCooldown = skill.cooldown;
    } else if (skill is SwordSpinSkill) {
      _castSwordSpin(casterComponent);
      SoundManager.playSkill();
      skill.currentCooldown = skill.cooldown;
    } else if (skill is SureShotSkill) {
      _spawnSureShotCharge(casterComponent);
      _scheduleSureShot(casterComponent, targetComponent);
      SoundManager.playSkill();
      caster.spendMana(skill.manaCost);
      skill.currentCooldown = skill.cooldown;
    } else if (skill is ArrowRainSkill) {
      _castArrowRain(casterComponent, targetComponent);
      SoundManager.playSkill();
      skill.currentCooldown = skill.cooldown;
    } else if (skill is ShieldSkill) {
      _spawnShield(casterComponent);
      skill.activate(caster, target);
      SoundManager.playSkill();
    } else if (skill is TauntSkill) {
      _spawnTaunt(targetComponent);
      skill.activate(caster, target);
      SoundManager.playSkill();
    } else if (skill is RapidShotSkill) {
      _spawnRapidShot(casterComponent, targetComponent);
      skill.activate(caster, target);
      SoundManager.playSkill();
    } else if (skill is FocusSkill) {
      _spawnFocus(casterComponent);
      skill.activate(caster, target);
      SoundManager.playSkill();
    } else {
      skill.activate(caster, target);
      SoundManager.playSkill();
    }
    onBattleTick?.call();
    _notifyUi();
  }

  void _spawnDamageText(
    DamageEvent event,
    BattleCharacterComponent targetComponent,
  ) {
    final text = event.isMiss ? 'Miss' : '-${event.amount}';
    final color = event.isMiss
        ? const Color(0xFF90A4AE)
        : (event.isCritical
            ? const Color(0xFFFFD54F)
            : _colorForDamageType(event.damageType));
    final position = Vector2(
      targetComponent.position.x,
      targetComponent.position.y - targetComponent.size.y / 2 - 38,
    );

    add(
      FloatingTextComponent(
        text: text,
        position: position,
        color: color,
        fontSize: 26,
      ),
    );

    if (!event.isMiss) {
      SoundManager.playHit();
    }

    _logDamage(event);

    if (!event.isMiss && !event.target.isAlive) {
      _checkIncinerateSpread(event.target);
    }
  }

  Color _colorForDamageType(DamageType type) {
    switch (type) {
      case DamageType.fire:
        return const Color(0xFFFF5252);
      case DamageType.ice:
        return const Color(0xFF42A5F5);
      case DamageType.physical:
        return const Color(0xFF9E9E9E);
      case DamageType.magic:
        return const Color(0xFF7E57C2);
      case DamageType.poison:
        return const Color(0xFF66BB6A);
    }
  }

  BattleCharacterComponent _componentFor(Character character) {
    if (character == player) return playerComponent;
    for (final enemyComponent in enemyComponents) {
      if (enemyComponent.character == character) {
        return enemyComponent;
      }
    }
    return playerComponent;
  }

  BattleCharacterComponent? _selectTargetEnemy() {
    for (final enemyComponent in enemyComponents) {
      if (enemyComponent.character.isAlive) return enemyComponent;
    }
    return null;
  }

  bool _isArcher(Character character) => character.name.contains('Arqueiro');
  bool _isMage(Character character) =>
      character.name.contains('Mago') || character.name.contains('Bruxa');
  bool _isDragon(Character character) => character.name.contains('Dragao');

  void _performAttack(
    BattleCharacterComponent attacker,
    BattleCharacterComponent defender,
  ) {
    _recordAttack(attacker.character);
    if (_isDragon(attacker.character)) {
      _spawnDragonFire(attacker, defender);
      return;
    }

    if (_isArcher(attacker.character)) {
      final isGoblinArcher = !attacker.isPlayer && attacker.character.name == 'Goblin Arqueiro';
      if (isGoblinArcher && (_attackCounts[attacker.character] ?? 0) % 3 == 0) {
        _spawnArrowProjectile(
          attacker: attacker,
          defender: defender,
          damage: (attacker.character.attack * 0.8).round(),
          isCrit: false,
        );
        _spawnArrowProjectile(
          attacker: attacker,
          defender: defender,
          damage: (attacker.character.attack * 0.8).round(),
          isCrit: false,
        );
        return;
      }

      final isCrit = _rng.nextDouble() < _archerLuckyShotChance;
      final multiplier = isCrit ? _archerCritMultiplier : 1.0;
      _spawnArrowProjectile(
        attacker: attacker,
        defender: defender,
        damage: (attacker.character.attack * multiplier).round(),
        isCrit: isCrit,
      );
      return;
    }

    if (_isMage(attacker.character)) {
      _spawnMagicBolt(attacker, defender);
      return;
    }

    attacker.character.attackTarget(defender.character);
    defender.hitFlash = 0.15;
    _maybeApplyEnemyControl(attacker, defender);
  }

  void _spawnArrowProjectile({
    required BattleCharacterComponent attacker,
    required BattleCharacterComponent defender,
    required int damage,
    required bool isCrit,
  }) {
    final start = Vector2(
      attacker.position.x + (attacker.isPlayer ? attacker.size.x / 2 : -attacker.size.x / 2),
      attacker.position.y,
    );
    final end = Vector2(defender.position.x, defender.position.y);

    add(
      ProjectileComponent(
        start: start,
        end: end,
        duration: _arrowTravelTime,
        color: isCrit ? const Color(0xFFFFD54F) : const Color(0xFF9E9E9E),
        radius: isCrit ? 7 : 6,
        isArrow: true,
        onHit: () {
          defender.hitFlash = 0.15;
          defender.character.takeDamage(
            damage,
            source: attacker.character,
            type: DamageType.physical,
            isCritical: isCrit,
          );
          _maybeApplyEnemyControl(attacker, defender);
        },
      ),
    );
  }

  void _spawnMagicBolt(
    BattleCharacterComponent attacker,
    BattleCharacterComponent defender,
  ) {
    final start = Vector2(
      attacker.position.x + (attacker.isPlayer ? attacker.size.x / 2 : -attacker.size.x / 2),
      attacker.position.y - 6,
    );
    final end = Vector2(defender.position.x, defender.position.y - 6);

    add(
      ProjectileComponent(
        start: start,
        end: end,
        duration: 0.3,
        color: const Color(0xFF7E57C2),
        radius: 7,
        onHit: () {
          defender.hitFlash = 0.15;
          defender.character.takeDamage(
            attacker.character.attack,
            source: attacker.character,
            type: DamageType.magic,
          );
          _maybeApplyEnemyControl(attacker, defender);
        },
      ),
    );
  }

  void _spawnDragonFire(
    BattleCharacterComponent attacker,
    BattleCharacterComponent defender,
  ) {
    final start = Vector2(
      attacker.position.x - (attacker.size.x / 2),
      attacker.position.y - 10,
    );
    final end = Vector2(defender.position.x, defender.position.y - 6);

    add(
      ProjectileComponent(
        start: start,
        end: end,
        duration: _dragonFireTravelTime,
        color: const Color(0xFFFF7043),
        radius: 10,
        onHit: () {
          defender.hitFlash = 0.15;
          add(
            RingEffectComponent(
              position: defender.position.clone(),
              color: const Color(0xFFFF8A65),
              startRadius: 14,
              endRadius: 60,
              duration: 0.35,
              strokeWidth: 4,
            ),
          );
          defender.character.takeDamage(
            attacker.character.attack,
            source: attacker.character,
            type: DamageType.fire,
          );
        },
      ),
    );
  }

  void _spawnFireball(
    BattleCharacterComponent caster,
    BattleCharacterComponent target,
  ) {
    final start = Vector2(
      caster.position.x + (caster.isPlayer ? caster.size.x / 2 : -caster.size.x / 2),
      caster.position.y - 8,
    );
    final end = Vector2(target.position.x, target.position.y - 6);

    add(
      ProjectileComponent(
        start: start,
        end: end,
        duration: _fireballTravelTime,
        color: const Color(0xFFFF6E40),
        radius: 8,
        onHit: () {
          add(
            RingEffectComponent(
              position: target.position.clone(),
              color: const Color(0xFFFF7043),
              startRadius: 10,
              endRadius: 46,
              duration: 0.35,
              strokeWidth: 4,
            ),
          );
          _applyFireballDamage(caster.character, target.character);
        },
      ),
    );
  }

  void _spawnFreeze(BattleCharacterComponent target) {
    target.character.addStatus(StatusType.freeze, 2);
    _notifyUi();
    add(
      FrostOverlayComponent(
        position: target.position.clone(),
        radius: target.size.x * 0.55,
      ),
    );

    add(
      RingEffectComponent(
        position: target.position.clone(),
        color: const Color(0xFF81D4FA),
        startRadius: 12,
        endRadius: 52,
        duration: 0.6,
        strokeWidth: 4,
      ),
    );
  }

  void _spawnWarCry(BattleCharacterComponent caster) {
    caster.character.addStatus(StatusType.warcry, 3);
    _notifyUi();
    add(
      RingEffectComponent(
        position: caster.position.clone(),
        color: const Color(0xFFFFD54F),
        startRadius: 10,
        endRadius: 50,
        duration: 0.5,
        strokeWidth: 4,
      ),
    );

    add(
      FloatingTextComponent(
        text: 'Grito!',
        position: Vector2(caster.position.x, caster.position.y - caster.size.y / 2 - 48),
        color: const Color(0xFFFFD54F),
        fontSize: 22,
        duration: 0.7,
      ),
    );
  }

  void _spawnSureShotCharge(BattleCharacterComponent caster) {
    add(
      RingEffectComponent(
        position: caster.position.clone(),
        color: const Color(0xFFFFD54F),
        startRadius: 8,
        endRadius: 36,
        duration: _sureShotChargeTime,
        strokeWidth: 3,
      ),
    );
  }

  void _scheduleSureShot(
    BattleCharacterComponent caster,
    BattleCharacterComponent target,
  ) {
    _delayedActions.add(
      _DelayedAction(
        delay: _sureShotChargeTime,
        action: () {
          if (!caster.character.isAlive || !target.character.isAlive) return;
          final damage = (caster.character.attack * _archerCritMultiplier).round();
          _spawnArrowProjectile(
            attacker: caster,
            defender: target,
            damage: damage,
            isCrit: true,
          );
        },
      ),
    );
  }

  void _applyFireballDamage(Character caster, Character target) {
    final total = caster.attack * 2;
    final instant = (total * 0.7).round();
    final burnTotal = total - instant;

    target.takeDamage(
      instant,
      source: caster,
      type: DamageType.fire,
    );

    _applyBurn(
      target: target,
      source: caster,
      totalDamage: burnTotal,
      ticks: 3,
    );
  }

  void _applyBurn({
    required Character target,
    required Character source,
    required int totalDamage,
    required int ticks,
  }) {
    if (totalDamage <= 0 || ticks <= 0) return;
    target.addStatus(StatusType.burn, ticks);
    _notifyUi();
    final base = totalDamage ~/ ticks;
    final remainder = totalDamage % ticks;
    var index = 0;

    _timedEffects.add(
      _TimedEffect(
        remainingTicks: ticks,
        onTick: () {
          final damage = base + (index < remainder ? 1 : 0);
          index += 1;
          target.takeDamage(
            damage,
            source: source,
            type: DamageType.fire,
          );
        },
      ),
    );
  }

  void _checkIncinerateSpread(Character target) {
    final mark = _incinerateMarks.remove(target);
    if (mark == null) return;
    if (battleTime > mark.expiresAt) return;
    _spreadIncinerate(mark.source);
  }

  void _spreadIncinerate(Character source) {
    final targets = enemyComponents
        .where((enemy) => enemy.character.isAlive)
        .toList();
    if (targets.isEmpty) return;

    final totalDamage = (source.attack * _incinerateSpreadMultiplier).round();
    for (final enemy in targets) {
      _applyBurn(
        target: enemy.character,
        source: source,
        totalDamage: totalDamage,
        ticks: _incinerateTicks,
      );
      add(
        RingEffectComponent(
          position: enemy.position.clone(),
          color: const Color(0xFFFF7043),
          startRadius: 10,
          endRadius: 46,
          duration: 0.45,
          strokeWidth: 3,
        ),
      );
    }

    _logEvent('Incinerar espalhou!');
  }

  void _applyWarCry(Character caster) {
    caster.attackSpeedMultiplier *= 2;

    _timedEffects.add(
      _TimedEffect(
        remainingTicks: 3,
        onTick: () {
          caster.healPercent(0.1);
          onBattleTick?.call();
          _notifyUi();
        },
        onEnd: () {
          caster.attackSpeedMultiplier /= 2;
        },
      ),
    );
  }

  void _applyPoison({
    required Character target,
    required Character source,
    required int totalDamage,
    required int ticks,
  }) {
    if (totalDamage <= 0 || ticks <= 0) return;
    target.addStatus(StatusType.poison, ticks);
    _notifyUi();
    final base = totalDamage ~/ ticks;
    final remainder = totalDamage % ticks;
    var index = 0;
    _timedEffects.add(
      _TimedEffect(
        remainingTicks: ticks,
        onTick: () {
          final damage = base + (index < remainder ? 1 : 0);
          index += 1;
          target.takeDamage(
            damage,
            source: source,
            type: DamageType.poison,
          );
        },
      ),
    );
  }

  void _maybeApplyEnemyControl(
    BattleCharacterComponent attacker,
    BattleCharacterComponent defender,
  ) {
    if (attacker.isPlayer) return;
    final enemy = attacker.character;
    if (enemy.name == 'Bruxa' || enemy.name == 'Bruxa Ancia') {
      if (defender.character.statuses.containsKey(StatusType.hex)) return;
      if (_rng.nextDouble() < 0.35) {
        defender.character.addStatus(StatusType.hex, 3);
        defender.character.attack = (defender.character.attack - 2).clamp(1, 9999);
        _notifyUi();
        _timedEffects.add(
          _TimedEffect(
            remainingTicks: 3,
            onEnd: () {
              defender.character.attack += 2;
              defender.character.clearStatus(StatusType.hex);
            },
          ),
        );
        add(
          FloatingTextComponent(
            text: 'Maldição',
            position: Vector2(
              defender.position.x,
              defender.position.y - defender.size.y / 2 - 48,
            ),
            color: const Color(0xFF9575CD),
            fontSize: 20,
            duration: 0.8,
          ),
        );
      }
    }

    if (enemy.name == 'Mago Esqueleto Sombrio') {
      if ((_attackCounts[enemy] ?? 0) % 4 == 0) {
        _spawnFreeze(defender);
        defender.character.takeDamage(
          (enemy.attack * 0.6).round(),
          source: enemy,
          type: DamageType.ice,
        );
      }
    }

    if (enemy.name == 'Aranha do Vazio') {
      if (_rng.nextDouble() < 0.4) {
        _applyPoison(
          target: defender.character,
          source: enemy,
          totalDamage: (enemy.attack * 0.9).round(),
          ticks: 3,
        );
      }
    }
  }

  void _recordAttack(Character attacker) {
    _attackCounts[attacker] = (_attackCounts[attacker] ?? 0) + 1;
  }

  void _checkEnemyPhases() {
    for (final enemy in enemies) {
      if (!enemy.isAlive) continue;
      if (enemy.name == 'Orc Sanguinario' && !_berserked.contains(enemy)) {
        if (enemy.hp <= (enemy.maxHp * 0.5)) {
          _berserked.add(enemy);
          enemy.attackSpeedMultiplier *= 1.3;
          enemy.attack += 5;
          enemy.addStatus(StatusType.berserk, 6);
          final component = _componentFor(enemy);
          add(
            FloatingTextComponent(
              text: 'Fúria!',
              position: Vector2(
                component.position.x,
                component.position.y - component.size.y / 2 - 50,
              ),
              color: const Color(0xFFFF5252),
              fontSize: 20,
              duration: 0.9,
            ),
          );
          _notifyUi();
        }
      }

      if (enemy.name == 'Dragao' && !_phaseTwo.contains(enemy)) {
        if (enemy.hp <= (enemy.maxHp * 0.5)) {
          _phaseTwo.add(enemy);
          enemy.attackSpeedMultiplier *= 1.4;
          enemy.attack += 8;
          enemy.addStatus(StatusType.enraged, 6);
          final component = _componentFor(enemy);
          add(
            RingEffectComponent(
              position: component.position.clone(),
              color: const Color(0xFFFF7043),
              startRadius: 18,
              endRadius: 68,
              duration: 0.6,
              strokeWidth: 5,
            ),
          );
          add(
            FloatingTextComponent(
              text: 'Chamas!',
              position: Vector2(
                component.position.x,
                component.position.y - component.size.y / 2 - 52,
              ),
              color: const Color(0xFFFF7043),
              fontSize: 22,
              duration: 0.9,
            ),
          );
          _notifyUi();
        }
      }
    }
  }

  void _logDamage(DamageEvent event) {
    final source = event.source?.name ?? 'Desconhecido';
    final target = event.target.name;
    if (event.isMiss) {
      _logEvent('$source errou $target');
      return;
    }
    final type = _labelForDamage(event.damageType);
    final crit = event.isCritical ? ' CRIT' : '';
    _logEvent('$source causou ${event.amount} $type em $target$crit');
  }

  String _labelForDamage(DamageType type) {
    switch (type) {
      case DamageType.physical:
        return 'fisico';
      case DamageType.fire:
        return 'fogo';
      case DamageType.ice:
        return 'gelo';
      case DamageType.magic:
        return 'magia';
      case DamageType.poison:
        return 'veneno';
    }
  }

  void _logEvent(String message) {
    if (message.trim().isEmpty) return;
    _combatLog.insert(0, message);
    if (_combatLog.length > 6) {
      _combatLog.removeLast();
    }
    onBattleTick?.call();
    _notifyUi();
  }

  void _updateDelayedActions(double dt) {
    for (var i = _delayedActions.length - 1; i >= 0; i--) {
      final action = _delayedActions[i];
      action.remaining -= dt;
      if (action.remaining <= 0) {
        _delayedActions.removeAt(i);
        action.action();
      }
    }
  }

  void _spawnShield(BattleCharacterComponent caster) {
    add(
      RingEffectComponent(
        position: caster.position.clone(),
        color: const Color(0xFF64B5F6),
        startRadius: 10,
        endRadius: 40,
        duration: 0.5,
        strokeWidth: 4,
      ),
    );
  }

  void _spawnTaunt(BattleCharacterComponent target) {
    add(
      RingEffectComponent(
        position: target.position.clone(),
        color: const Color(0xFFFF7043),
        startRadius: 14,
        endRadius: 58,
        duration: 0.45,
        strokeWidth: 4,
      ),
    );

    add(
      FloatingTextComponent(
        text: '!',
        position: Vector2(target.position.x, target.position.y - target.size.y / 2 - 48),
        color: const Color(0xFFFF7043),
        fontSize: 26,
        duration: 0.6,
      ),
    );
  }

  void _spawnRapidShot(
    BattleCharacterComponent caster,
    BattleCharacterComponent target,
  ) {
    final start = Vector2(
      caster.position.x + (caster.isPlayer ? caster.size.x / 2 : -caster.size.x / 2),
      caster.position.y - 4,
    );
    final end = Vector2(target.position.x, target.position.y - 4);

    add(
      ProjectileComponent(
        start: start,
        end: end,
        duration: 0.18,
        color: const Color(0xFFB0BEC5),
        radius: 5,
        isArrow: true,
      ),
    );

    add(
      ProjectileComponent(
        start: start + Vector2(0, -6),
        end: end + Vector2(0, -6),
        duration: 0.22,
        color: const Color(0xFFB0BEC5),
        radius: 5,
        isArrow: true,
      ),
    );
  }

  void _castSwordSpin(BattleCharacterComponent caster) {
    add(
      RingEffectComponent(
        position: caster.position.clone(),
        color: const Color(0xFFB0BEC5),
        startRadius: 14,
        endRadius: 72,
        duration: 0.45,
        strokeWidth: 4,
      ),
    );

    add(
      RingEffectComponent(
        position: caster.position.clone(),
        color: const Color(0xFFFFD54F),
        startRadius: 8,
        endRadius: 52,
        duration: 0.3,
        strokeWidth: 2.5,
      ),
    );

    final damage = (caster.character.attack * _spinMultiplier).round();
    for (final enemy in enemyComponents) {
      if (!enemy.character.isAlive) continue;
      enemy.hitFlash = 0.15;
      enemy.character.takeDamage(
        damage,
        source: caster.character,
        type: DamageType.physical,
      );
    }
  }

  void _castArrowRain(
    BattleCharacterComponent caster,
    BattleCharacterComponent target,
  ) {
    final center = target.position.clone();
    add(
      RingEffectComponent(
        position: center,
        color: const Color(0xFF90A4AE),
        startRadius: 18,
        endRadius: 88,
        duration: 0.55,
        strokeWidth: 3,
      ),
    );

    for (var wave = 0; wave < _arrowRainWaves; wave++) {
      _delayedActions.add(
        _DelayedAction(
          delay: wave * _arrowRainInterval,
          action: () {
            if (!caster.character.isAlive) return;
            final damage = (caster.character.attack * _arrowRainDamageMultiplier).round();
            final targets = enemyComponents
                .where((enemy) => enemy.character.isAlive)
                .toList();
            if (targets.isEmpty) return;

            add(
              RingEffectComponent(
                position: center,
                color: const Color(0xFFB0BEC5),
                startRadius: 12,
                endRadius: 76,
                duration: 0.35,
                strokeWidth: 2.5,
              ),
            );

            for (final enemy in targets) {
              final end = enemy.position.clone();
              final offsetX = (_rng.nextDouble() * 80) - 40;
              final offsetY = (_rng.nextDouble() * 20) - 10;
              final start = Vector2(
                end.x + offsetX,
                end.y - _arrowRainDropHeight + offsetY,
              );
              add(
                ProjectileComponent(
                  start: start,
                  end: end,
                  duration: 0.35,
                  color: const Color(0xFFB0BEC5),
                  radius: 5.5,
                  isArrow: true,
                  onHit: () {
                    if (!enemy.character.isAlive) return;
                    enemy.hitFlash = 0.15;
                    enemy.character.takeDamage(
                      damage,
                      source: caster.character,
                      type: DamageType.physical,
                    );
                  },
                ),
              );
            }
          },
        ),
      );
    }
  }

  void _castIncinerate(
    BattleCharacterComponent caster,
    BattleCharacterComponent target,
  ) {
    add(
      RingEffectComponent(
        position: target.position.clone(),
        color: const Color(0xFFFF7043),
        startRadius: 14,
        endRadius: 64,
        duration: 0.55,
        strokeWidth: 4,
      ),
    );

    add(
      FloatingTextComponent(
        text: 'Incinerar!',
        position: Vector2(target.position.x, target.position.y - target.size.y / 2 - 50),
        color: const Color(0xFFFF7043),
        fontSize: 20,
        duration: 0.8,
      ),
    );

    final totalDamage = (caster.character.attack * _incinerateTotalMultiplier).round();
    _applyBurn(
      target: target.character,
      source: caster.character,
      totalDamage: totalDamage,
      ticks: _incinerateTicks,
    );

    final mark = _IncinerateMark(
      source: caster.character,
      expiresAt: battleTime + _incinerateWindow,
    );
    _incinerateMarks[target.character] = mark;
    _delayedActions.add(
      _DelayedAction(
        delay: _incinerateWindow,
        action: () {
          if (_incinerateMarks[target.character] == mark) {
            _incinerateMarks.remove(target.character);
          }
        },
      ),
    );
  }

  void _spawnFocus(BattleCharacterComponent caster) {
    add(
      RingEffectComponent(
        position: caster.position.clone(),
        color: const Color(0xFF81C784),
        startRadius: 10,
        endRadius: 36,
        duration: 0.5,
        strokeWidth: 3,
      ),
    );
  }

  /// Resolve o sprite com base no personagem
  /// Caminho relativo a assets/ (NÃO prefixar com assets/)
  String _spriteForCharacter(Character character) {
    if (character.spritePath != null) {
      return character.spritePath!;
    }
    switch (character.name) {
      case 'Cavaleiro':
        return 'characters/knight.png';
      case 'Mago':
        return 'characters/mage.png';
      case 'Arqueiro':
        return 'characters/archer.png';
      default:
        return 'characters/goblin.png';
    }
  }

  /// Verifica se a batalha terminou
  void checkBattleEnd() {
    if (_battleEnded) return;

    if (player.hp <= 0) {
      _battleEnded = true;
      _playerWon = false;
      onBattleEnd?.call();
    } else if (enemies.every((enemy) => !enemy.isAlive)) {
      _battleEnded = true;
      _playerWon = true;
      onBattleEnd?.call();
    }
  }
}

class _PendingAttack {
  _PendingAttack({
    required this.windUp,
    required this.parryWindow,
  });

  final double windUp;
  final double parryWindow;

  double elapsed = 0;
  bool struck = false;

  bool get isParryWindow {
    final start = (windUp - parryWindow).clamp(0.0, windUp);
    return elapsed >= start && elapsed < windUp;
  }

  double get timeUntilStrike => (windUp - elapsed).clamp(0.0, windUp);
}

class _TimedEffect {
  _TimedEffect({
    required this.remainingTicks,
    this.onTick,
    this.onEnd,
  });

  int remainingTicks;
  final VoidCallback? onTick;
  final VoidCallback? onEnd;
}

class _DelayedAction {
  _DelayedAction({
    required double delay,
    required this.action,
  }) : remaining = delay;

  double remaining;
  final VoidCallback action;
}

class _IncinerateMark {
  const _IncinerateMark({
    required this.source,
    required this.expiresAt,
  });

  final Character source;
  final double expiresAt;
}
