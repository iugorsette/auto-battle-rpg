import '../character/character.dart';

class BattleSetup {
  final Character player;
  final List<Character> enemies;
  final int rewardXp;
  final int totalEnemyLevel;

  BattleSetup({
    required this.player,
    required this.enemies,
    required this.rewardXp,
    required this.totalEnemyLevel,
  });
}
