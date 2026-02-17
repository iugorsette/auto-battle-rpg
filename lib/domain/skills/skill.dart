import '../character/character.dart';

abstract class Skill {
  String get name;
  int cooldown;
  int currentCooldown = 0;
  final int manaCost;
  final int minLevel;

  Skill(this.cooldown, {this.manaCost = 0, this.minLevel = 1});

  bool get available => currentCooldown == 0;

  void activate(Character caster, Character target);

  bool canUse(Character caster) {
    if (caster.progression.level < minLevel) return false;
    if (!available) return false;
    if (manaCost <= 0) return true;
    return caster.mana >= manaCost;
  }

  void tick() {
    if (currentCooldown > 0) currentCooldown--;
  }
}
