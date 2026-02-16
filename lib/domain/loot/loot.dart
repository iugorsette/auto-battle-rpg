import 'dart:math' as math;

import '../character/character.dart';

enum LootRarity {
  common,
  uncommon,
  rare,
  epic,
}

class LootItem {
  final String name;
  final String description;
  final LootRarity rarity;
  final int colorValue;
  final void Function(Character target) apply;

  const LootItem({
    required this.name,
    required this.description,
    required this.rarity,
    required this.colorValue,
    required this.apply,
  });
}

class LootGenerator {
  static final List<LootItem> _items = [
    LootItem(
      name: 'Broche do Vigor',
      description: '+20 HP maximo',
      rarity: LootRarity.common,
      colorValue: 0xFF90A4AE,
      apply: (target) {
        target.maxHp += 20;
        target.hp += 20;
      },
    ),
    LootItem(
      name: 'Lamina de Ferro',
      description: '+3 ATK',
      rarity: LootRarity.common,
      colorValue: 0xFF90A4AE,
      apply: (target) => target.attack += 3,
    ),
    LootItem(
      name: 'Couro Reforcado',
      description: '+3 DEF',
      rarity: LootRarity.uncommon,
      colorValue: 0xFF64B5F6,
      apply: (target) => target.defense += 3,
    ),
    LootItem(
      name: 'Marca do Caçador',
      description: '+6 ATK',
      rarity: LootRarity.uncommon,
      colorValue: 0xFF64B5F6,
      apply: (target) => target.attack += 6,
    ),
    LootItem(
      name: 'Amuleto Rubro',
      description: '+40 HP maximo',
      rarity: LootRarity.rare,
      colorValue: 0xFFFFB74D,
      apply: (target) {
        target.maxHp += 40;
        target.hp += 40;
      },
    ),
    LootItem(
      name: 'Insignia do Guardiao',
      description: '+6 DEF',
      rarity: LootRarity.rare,
      colorValue: 0xFFFFB74D,
      apply: (target) => target.defense += 6,
    ),
    LootItem(
      name: 'Coroa do Eclipse',
      description: '+1 SPD',
      rarity: LootRarity.epic,
      colorValue: 0xFFFFD54F,
      apply: (target) => target.speed += 1,
    ),
    LootItem(
      name: 'Coracao Draconico',
      description: '+80 HP maximo',
      rarity: LootRarity.epic,
      colorValue: 0xFFFFD54F,
      apply: (target) {
        target.maxHp += 80;
        target.hp += 80;
      },
    ),
  ];

  static LootItem roll(Character player, {math.Random? rng}) {
    final random = rng ?? math.Random();
    final roll = random.nextInt(100);
    LootRarity rarity;
    if (roll < 55) {
      rarity = LootRarity.common;
    } else if (roll < 80) {
      rarity = LootRarity.uncommon;
    } else if (roll < 95) {
      rarity = LootRarity.rare;
    } else {
      rarity = LootRarity.epic;
    }
    final pool = _items.where((item) => item.rarity == rarity).toList();
    return pool[random.nextInt(pool.length)];
  }
}
