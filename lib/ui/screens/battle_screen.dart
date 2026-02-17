import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../../domain/battle/battle_setup.dart';
import '../../domain/loot/loot.dart';
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
  final math.Random _rng = math.Random();

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
      LootItem? loot;

      if (victory) {
        game.player.gainXp(setup.rewardXp);
        loot = LootGenerator.roll(game.player, rng: _rng);
        loot.apply(game.player);
        game.player.addRelic(loot.name);
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text(victory ? 'Vitória!' : 'Derrota'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                victory
                    ? 'Você venceu a batalha! (+${setup.rewardXp} XP)'
                    : 'Você foi derrotado.',
              ),
              if (loot != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Recompensa: ${loot.name}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(loot.colorValue),
                  ),
                ),
                Text(
                  loot.description,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ],
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
    final panelDecoration = BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xCC0F1B2A),
          Color(0xCC1A2B3F),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF2E445F)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );

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
                  width: 240,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: panelDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.player.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        XpBar(
                          level: game.player.progression.level,
                          xp: game.player.progression.xp,
                          xpToNext: game.player.progression.xpToNext(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          game.player.maxMana > 0
                              ? 'HP ${game.player.hp}/${game.player.maxHp}  MP ${game.player.mana}/${game.player.maxMana}'
                              : 'HP ${game.player.hp}/${game.player.maxHp}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: ValueListenableBuilder<int>(
              valueListenable: game.uiTick,
              builder: (_, __, ___) {
                final log = game.combatLog;
                return SizedBox(
                  width: 280,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: panelDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Log de Combate',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        if (log.isEmpty)
                          const Text(
                            'Aguardando...',
                            style: TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ...log.map(
                          (line) => Text(
                            line,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
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
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: panelDecoration,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: game.player.skills
                        .where(
                          (skill) => skill.minLevel <= game.player.progression.level,
                        )
                        .map((skill) {
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
