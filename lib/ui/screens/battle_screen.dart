import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../../domain/battle/battle_setup.dart';
import '../../game/battler_game.dart';
import '../widgets/skill_button.dart';
import '../widgets/xp_bar.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late BattlerGame game;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final setup = ModalRoute.of(context)!.settings.arguments as BattleSetup;
    final player = setup.player;
    final enemies = setup.enemies;

    game = BattlerGame(player: player, enemies: enemies);
    game.onBattleEnd = () {
      final victory = game.isVictory;

      if (victory) {
        game.player.gainXp(setup.rewardXp);
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text(victory ? 'Vitória!' : 'Derrota'),
          content: Text(
            victory
                ? 'Você venceu a batalha! (+${setup.rewardXp} XP)'
                : 'Você foi derrotado.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                final navigator = Navigator.of(context, rootNavigator: true);
                navigator.pop();
                navigator.popUntil(
                  (route) =>
                      route.settings.name == '/battle-select' || route.isFirst,
                );
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      );
    };

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          Positioned(
            top: 16,
            left: 16,
            child: ValueListenableBuilder<int>(
              valueListenable: game.uiTick,
              builder: (_, __, ___) {
                return SizedBox(
                  width: 220,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: XpBar(
                      level: game.player.progression.level,
                      xp: game.player.progression.xp,
                      xpToNext: game.player.progression.xpToNext(),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ValueListenableBuilder<int>(
              valueListenable: game.uiTick,
              builder: (_, __, ___) {
                return Wrap(
                  alignment: WrapAlignment.center,
                  children: game.player.skills.map((skill) {
                return SkillButton(
                  skill: skill,
                  caster: game.player,
                  onPressed: () {
                    final target = game.firstAliveEnemy;
                    if (target == null) return;
                    game.castSkill(skill, game.player, target);
                  },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
