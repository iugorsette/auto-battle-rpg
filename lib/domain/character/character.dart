import '../skills/skill.dart';
import '../progression/level_progression.dart';

class Character {
  final String name;
  int maxHp;
  int hp;
  int attack;
  int defense;
  int speed;
  double attackSpeedMultiplier = 1.0;
  final String? spritePath;
  final double sizeScale;
  final double? attackCooldownOverride;
  int maxMana;
  int mana;

  final List<Skill> skills;
  final LevelProgression progression;
  void Function(DamageEvent event)? onDamage;

  Character({
    required this.name,
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.skills,
    this.spritePath,
    this.sizeScale = 1.0,
    this.attackCooldownOverride,
    this.maxMana = 0,
    int? mana,
    int level = 1,
  }) : hp = maxHp,
       mana = mana ?? maxMana,
       progression = LevelProgression(level: level);

  bool get isAlive => hp > 0;

  DamageEvent takeDamage(
    int value, {
    Character? source,
    DamageType type = DamageType.physical,
    bool isCritical = false,
  }) {
    final rawDamage = value - defense;
    if (rawDamage <= 0) {
      final event = DamageEvent(
        source: source,
        target: this,
        amount: 0,
        isMiss: true,
        damageType: type,
        isCritical: false,
      );
      onDamage?.call(event);
      return event;
    }

    final damage = rawDamage.clamp(1, 9999).toInt();
    hp = (hp - damage).clamp(0, maxHp).toInt();

    final event = DamageEvent(
      source: source,
      target: this,
      amount: damage,
      isMiss: false,
      damageType: type,
      isCritical: isCritical,
    );
    onDamage?.call(event);
    return event;
  }

  void gainXp(int value) {
    final beforeLevel = progression.level;
    progression.gainXp(value);
    final gained = progression.level - beforeLevel;
    for (var i = 0; i < gained; i++) {
      _applyLevelUp();
    }
  }

  int basicAttack() {
    return attack;
  }

  void attackTarget(Character target) {
    target.takeDamage(
      attack,
      source: this,
      type: DamageType.physical,
      isCritical: false,
    );
  }

  bool spendMana(int value) {
    if (value <= 0) return true;
    if (mana < value) return false;
    mana -= value;
    return true;
  }

  void regenMana(int value) {
    if (maxMana <= 0) return;
    mana = (mana + value).clamp(0, maxMana).toInt();
  }

  void _applyLevelUp() {
    maxHp += 15;
    attack += 4;
    defense += 2;
    if (progression.level % 3 == 0) {
      speed += 1;
    }
    hp = maxHp;
  }

  int heal(int value) {
    final before = hp;
    hp = (hp + value).clamp(0, maxHp).toInt();
    return hp - before;
  }

  int healPercent(double percent) {
    final value = (maxHp * percent).round();
    return heal(value);
  }

  void resetForBattle() {
    hp = maxHp;
    attackSpeedMultiplier = 1.0;
    mana = maxMana;
    for (final skill in skills) {
      skill.currentCooldown = 0;
    }
  }

}

enum DamageType {
  physical,
  fire,
  ice,
  magic,
}

class DamageEvent {
  final Character? source;
  final Character target;
  final int amount;
  final bool isMiss;
  final DamageType damageType;
  final bool isCritical;

  DamageEvent({
    required this.source,
    required this.target,
    required this.amount,
    required this.isMiss,
    required this.damageType,
    required this.isCritical,
  });
}
