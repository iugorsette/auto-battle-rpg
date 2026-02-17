import 'skill.dart';
import '../character/character.dart';

class FireballSkill extends Skill {
  FireballSkill() : super(3, manaCost: 30);

  @override
  String get name => 'Bola de Fogo';

  @override
  void activate(Character caster, Character target) {
    currentCooldown = cooldown;
  }
}

class IncinerateSkill extends Skill {
  IncinerateSkill() : super(6, manaCost: 35, minLevel: 4);

  @override
  String get name => 'Incinerar';

  @override
  void activate(Character caster, Character target) {
    currentCooldown = cooldown;
  }
}

class ShieldSkill extends Skill {
  ShieldSkill() : super(4);

  @override
  String get name => 'Escudo';

  @override
  void activate(Character caster, Character target) {
    caster.defense += 10;
    currentCooldown = cooldown;
  }
}

class SwordSpinSkill extends Skill {
  SwordSpinSkill() : super(6, minLevel: 4);

  @override
  String get name => 'Giro da Espada';

  @override
  void activate(Character caster, Character target) {
    currentCooldown = cooldown;
  }
}

class WarCrySkill extends Skill {
  WarCrySkill() : super(6);

  @override
  String get name => 'Grito de Guerra';

  @override
  void activate(Character caster, Character target) {
    currentCooldown = cooldown;
  }

  @override
  bool canUse(Character caster) {
    if (!super.canUse(caster)) return false;
    return caster.hp < caster.maxHp;
  }
}

class SureShotSkill extends Skill {
  SureShotSkill() : super(4, manaCost: 0);

  @override
  String get name => 'Tiro Certo';

  @override
  void activate(Character caster, Character target) {
    currentCooldown = cooldown;
  }
}

class ArrowRainSkill extends Skill {
  ArrowRainSkill() : super(6, minLevel: 4);

  @override
  String get name => 'Chuva de Flechas';

  @override
  void activate(Character caster, Character target) {
    currentCooldown = cooldown;
  }
}

class RapidShotSkill extends Skill {
  RapidShotSkill() : super(2);

  @override
  String get name => 'Tiro Rápido';

  @override
  void activate(Character caster, Character target) {
    currentCooldown = cooldown;
  }
}

class FreezeSkill extends Skill {
  FreezeSkill() : super(4, manaCost: 25);

  @override
  String get name => 'Congelar';

  @override
  void activate(Character caster, Character target) {
    currentCooldown = cooldown;
  }
}

class TauntSkill extends Skill {
  TauntSkill() : super(5);

  @override
  String get name => 'Provocar';

  @override
  void activate(Character caster, Character target) {
    currentCooldown = cooldown;
  }
}

class FocusSkill extends Skill {
  FocusSkill() : super(5);

  @override
  String get name => 'Foco';

  @override
  void activate(Character caster, Character target) {
    caster.attack += 5;
    currentCooldown = cooldown;
  }
}
