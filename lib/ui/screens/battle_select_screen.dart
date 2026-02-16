import 'package:flutter/material.dart';

import '../../domain/battle/battle_setup.dart';
import '../../domain/battle/enemy_catalog.dart';
import '../../domain/character/character.dart';
import '../widgets/xp_bar.dart';

class BattleSelectScreen extends StatefulWidget {
  const BattleSelectScreen({super.key});

  @override
  State<BattleSelectScreen> createState() => _BattleSelectScreenState();
}

class _BattleSelectScreenState extends State<BattleSelectScreen> {
  late Character player;
  late List<BattleOption> options;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    player = ModalRoute.of(context)!.settings.arguments as Character;
    options = BattleOptionGenerator().generateOptions(player.progression.level);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha uma batalha'),
        actions: [
          IconButton(
            onPressed: () {
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
}
