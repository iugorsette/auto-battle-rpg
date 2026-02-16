import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/character/character.dart';
import '../../state/player_roster.dart';
import '../widgets/xp_bar.dart';

class CharacterRosterScreen extends StatelessWidget {
  const CharacterRosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roster = context.watch<PlayerRoster>();

    return Scaffold(
      appBar: AppBar(title: const Text('Seus Personagens')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (roster.characters.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('Nenhum personagem criado ainda.'),
            ),
          ...roster.characters.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final character = entry.value;
            return _CharacterCard(
              character: character,
              slot: index,
              onSelect: () {
                character.resetForBattle();
                Navigator.pushNamed(
                  context,
                  '/battle-select',
                  arguments: character,
                );
              },
            );
          }),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: roster.characters.length >= roster.maxCharacters
                ? null
                : () => Navigator.pushNamed(context, '/create'),
            child: Text(
              roster.characters.length >= roster.maxCharacters
                  ? 'Limite de personagens atingido'
                  : 'Criar novo personagem',
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final Character character;
  final int slot;
  final VoidCallback onSelect;

  const _CharacterCard({
    required this.character,
    required this.slot,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${character.name} (Slot $slot)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'HP: ${character.maxHp}  ATK: ${character.attack}  DEF: ${character.defense}  SPD: ${character.speed}  MP: ${character.maxMana}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            XpBar(
              level: character.progression.level,
              xp: character.progression.xp,
              xpToNext: character.progression.xpToNext(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onSelect,
                child: const Text('Selecionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
