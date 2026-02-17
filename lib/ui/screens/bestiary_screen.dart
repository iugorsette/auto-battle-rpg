import 'package:flutter/material.dart';
import '../../domain/battle/enemy_catalog.dart';

class BestiaryScreen extends StatelessWidget {
  const BestiaryScreen({super.key});

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

    final monsters = EnemyCatalog.all;

    return Scaffold(
      appBar: AppBar(title: const Text('Livro dos Monstros')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: monsters.length,
        itemBuilder: (context, index) {
          final monster = monsters[index];
          final details = _detailsFor(monster.id);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: panelDecoration,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MonsterPortrait(assetPath: _assetFor(monster)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${monster.name} (Nv ${monster.level})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'HP: ${monster.maxHp}  ATK: ${monster.attack}  DEF: ${monster.defense}  SPD: ${monster.speed}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (details.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          details.description,
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                      if (details.traits.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...details.traits.map(
                          (trait) => Text(
                            '- $trait',
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _assetFor(EnemyDefinition enemy) => 'assets/${enemy.spritePath}';

  _MonsterDetails _detailsFor(String id) {
    switch (id) {
      case 'goblin':
        return const _MonsterDetails(
          description: 'Criatura básica e agressiva de baixa resistência.',
        );
      case 'goblin_archer':
        return const _MonsterDetails(
          description: 'Atirador rápido que alterna disparos duplos.',
          traits: [
            'A cada 3 ataques, dispara duas flechas com 0.8x ATK cada.',
          ],
        );
      case 'orc_sanguinario':
        return const _MonsterDetails(
          description: 'Guerreiro brutal que fica mais forte quando ferido.',
          traits: [
            'Entra em fúria ao chegar a 50% de HP.',
            'ATK +5 e velocidade de ataque +30%.',
          ],
        );
      case 'void_spider':
        return const _MonsterDetails(
          description: 'Criatura veloz do vazio com veneno debilitante.',
          traits: [
            '40% de chance de aplicar veneno.',
            'Dano total ATK * 0.9 em 3 ticks.',
          ],
        );
      case 'skeleton_warrior':
        return const _MonsterDetails(
          description: 'Soldado resistente com defesa acima da média.',
        );
      case 'witch':
        return const _MonsterDetails(
          description: 'Usuária de magia sombria com maldições.',
          traits: [
            '35% de chance de aplicar Maldição por 3 ticks.',
            'Reduz ATK do alvo em 2 enquanto durar.',
          ],
        );
      case 'elder_witch':
        return const _MonsterDetails(
          description: 'Bruxa experiente com magias mais destrutivas.',
          traits: [
            '35% de chance de aplicar Maldição por 3 ticks.',
            'Reduz ATK do alvo em 2 enquanto durar.',
          ],
        );
      case 'dragon':
        return const _MonsterDetails(
          description: 'Chefe lendário com ataque de fogo à distância.',
          traits: [
            'Ataque de fogo com projétil.',
            'Fase 2 ao chegar a 50% de HP: ATK +8 e velocidade +40%.',
          ],
        );
      case 'dark_skeleton_mage':
        return const _MonsterDetails(
          description: 'Mago sombrio com controle de gelo e alto dano.',
          traits: [
            'A cada 4 ataques, congela e causa dano de gelo ATK * 0.6.',
          ],
        );
      default:
        return const _MonsterDetails();
    }
  }
}

class _MonsterPortrait extends StatelessWidget {
  final String assetPath;

  const _MonsterPortrait({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF31455E), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _MonsterDetails {
  final String description;
  final List<String> traits;

  const _MonsterDetails({
    this.description = '',
    this.traits = const [],
  });
}
