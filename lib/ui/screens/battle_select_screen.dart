import 'package:flutter/material.dart';

import '../../domain/battle/battle_setup.dart';
import '../../domain/battle/enemy_catalog.dart';
import '../../domain/character/character.dart';
import '../widgets/xp_bar.dart';
import '../../game/sound/sound_manager.dart';

class BattleSelectScreen extends StatefulWidget {
  const BattleSelectScreen({super.key});

  @override
  State<BattleSelectScreen> createState() => _BattleSelectScreenState();
}

class _BattleSelectScreenState extends State<BattleSelectScreen> {
  late Character player;
  late List<BattleOption> options;

  @override
  void initState() {
    super.initState();
    SoundManager.playIntro();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    player = ModalRoute.of(context)!.settings.arguments as Character;
    options = BattleOptionGenerator().generateOptions(player.progression.level);
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
          color: Color(0x55000000),
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha uma batalha'),
        actions: [
          IconButton(
            onPressed: () {
              SoundManager.playClick();
              setState(() {
                options = BattleOptionGenerator()
                    .generateOptions(player.progression.level);
              });
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Gerar novas batalhas',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: panelDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                XpBar(
                  level: player.progression.level,
                  xp: player.progression.xp,
                  xpToNext: player.progression.xpToNext(),
                ),
                const SizedBox(height: 10),
                Text(
                  'HP ${player.maxHp}  ATK ${player.attack}  DEF ${player.defense}  SPD ${player.speed}  MP ${player.maxMana}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  'DPS estimado: ${_estimateDps(player).toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((option) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dificuldade: Nivel ${option.totalLevel}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...option.enemies.map(
                      (enemy) => Text('- ${enemy.name} (Nv ${enemy.level})'),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          SoundManager.playClick();
                          player.resetForBattle();
                          final enemies = option.enemies.map((e) => e.create()).toList();
                          final setup = BattleSetup(
                            player: player,
                            enemies: enemies,
                            rewardXp: option.totalLevel * 100,
                            totalEnemyLevel: option.totalLevel,
                          );
                          Navigator.pushNamed(
                            context,
                            '/battle',
                            arguments: setup,
                          );
                        },
                        child: const Text('Batalhar'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (options.isEmpty)
            const Text('Nenhuma batalha disponivel para este nivel.'),
        ],
      ),
    );
  }

  double _estimateDps(Character character) {
    final speedFactor = (1 + character.speed * 0.25) * character.attackSpeedMultiplier;
    final cooldown = (3.0 / speedFactor).clamp(1.5, 5.0);
    return character.attack / cooldown;
  }
}
