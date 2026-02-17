import 'dart:math' as math;

import '../character/character.dart';

class EnemyDefinition {
  final String id;
  final String name;
  final int level;
  final int maxHp;
  final int attack;
  final int defense;
  final int speed;
  final String spritePath;
  final double sizeScale;
  final double? attackCooldownOverride;

  const EnemyDefinition({
    required this.id,
    required this.name,
    required this.level,
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.spritePath,
    this.sizeScale = 1.0,
    this.attackCooldownOverride,
  });

  Character create() {
    return Character(
      name: name,
      maxHp: maxHp,
      attack: attack,
      defense: defense,
      speed: speed,
      skills: const [],
      spritePath: spritePath,
      sizeScale: sizeScale,
      attackCooldownOverride: attackCooldownOverride,
      level: level,
    );
  }
}

class EnemyCatalog {
  static const List<EnemyDefinition> all = [
    EnemyDefinition(
      id: 'goblin',
      name: 'Goblin',
      level: 1,
      maxHp: 120,
      attack: 18,
      defense: 6,
      speed: 1,
      spritePath: 'characters/goblin.png',
    ),
    EnemyDefinition(
      id: 'goblin_archer',
      name: 'Goblin Arqueiro',
      level: 2,
      maxHp: 95,
      attack: 20,
      defense: 5,
      speed: 2,
      spritePath: 'characters/goblin_archer.png',
    ),
    EnemyDefinition(
      id: 'orc_sanguinario',
      name: 'Orc Sanguinario',
      level: 3,
      maxHp: 170,
      attack: 30,
      defense: 10,
      speed: 1,
      spritePath: 'characters/orc_sanguinario.png',
    ),
    EnemyDefinition(
      id: 'void_spider',
      name: 'Aranha do Vazio',
      level: 3,
      maxHp: 115,
      attack: 24,
      defense: 6,
      speed: 3,
      spritePath: 'characters/void_spider.png',
    ),
    EnemyDefinition(
      id: 'skeleton_warrior',
      name: 'Guerreiro Esqueleto',
      level: 4,
      maxHp: 145,
      attack: 28,
      defense: 12,
      speed: 1,
      spritePath: 'characters/skeleton_warrior.png',
    ),
    EnemyDefinition(
      id: 'witch',
      name: 'Bruxa',
      level: 5,
      maxHp: 140,
      attack: 30,
      defense: 9,
      speed: 2,
      spritePath: 'characters/witch.png',
    ),
    EnemyDefinition(
      id: 'elder_witch',
      name: 'Bruxa Ancia',
      level: 6,
      maxHp: 190,
      attack: 42,
      defense: 14,
      speed: 2,
      spritePath: 'characters/witch_elder.png',
    ),
    EnemyDefinition(
      id: 'dragon',
      name: 'Dragao',
      level: 6,
      maxHp: 320,
      attack: 45,
      defense: 18,
      speed: 1,
      spritePath: 'characters/dragon.png',
      sizeScale: 1.8,
      attackCooldownOverride: 0.6,
    ),
    EnemyDefinition(
      id: 'dark_skeleton_mage',
      name: 'Mago Esqueleto Sombrio',
      level: 8,
      maxHp: 260,
      attack: 60,
      defense: 18,
      sizeScale: 1.25,
      speed: 2,
      spritePath: 'characters/dark_skeleton_mage.png',
    ),
  ];
}

class BattleOption {
  final List<EnemyDefinition> enemies;
  final int totalLevel;

  BattleOption({
    required this.enemies,
    required this.totalLevel,
  });
}

class BattleOptionGenerator {
  BattleOptionGenerator({
    math.Random? rng,
    this.maxEnemies = 3,
  }) : _rng = rng ?? math.Random();

  final math.Random _rng;
  final int maxEnemies;

  List<BattleOption> generateOptions(int playerLevel, {int count = 3}) {
    final available = EnemyCatalog.all
        .where((enemy) => enemy.level <= playerLevel)
        .toList();

    if (available.isEmpty) return [];

    final combos = <List<EnemyDefinition>>[];
    _buildCombos(
      available,
      playerLevel,
      0,
      [],
      combos,
    );

    combos.shuffle(_rng);
    final selected = combos.take(count).toList();

    if (selected.isEmpty) {
      final single = available.where((e) => e.level == playerLevel).toList();
      if (single.isNotEmpty) {
        selected.add([single[_rng.nextInt(single.length)]]);
      } else {
        selected.add([available[_rng.nextInt(available.length)]]);
      }
    }

    return selected
        .map(
          (enemies) => BattleOption(
            enemies: enemies,
            totalLevel: enemies.fold(0, (sum, e) => sum + e.level),
          ),
        )
        .toList();
  }

  void _buildCombos(
    List<EnemyDefinition> available,
    int remaining,
    int startIndex,
    List<EnemyDefinition> current,
    List<List<EnemyDefinition>> output,
  ) {
    if (remaining == 0) {
      output.add(List.of(current));
      return;
    }
    if (remaining < 0) return;
    if (current.length >= maxEnemies) return;

    for (var i = startIndex; i < available.length; i++) {
      final enemy = available[i];
      if (enemy.level > remaining) continue;
      current.add(enemy);
      _buildCombos(available, remaining - enemy.level, i, current, output);
      current.removeLast();
    }
  }
}
