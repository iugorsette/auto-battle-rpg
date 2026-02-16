import 'components/battle_character_component.dart';

class BattleController {
  void processAutoAttack(
    BattleCharacterComponent attacker,
    BattleCharacterComponent target,
  ) {
    if (!attacker.character.isAlive || !target.character.isAlive) return;

    attacker.position.x += attacker.isPlayer ? 10 : -10;

    Future.delayed(const Duration(milliseconds: 100), () {
      attacker.position.x -= attacker.isPlayer ? 10 : -10;
    });

    if (attacker.canAttack()) {
      final damage = attacker.character.basicAttack();
      target.character.takeDamage(damage, source: attacker.character);
      attacker.resetAttack();
    }
  }
}
