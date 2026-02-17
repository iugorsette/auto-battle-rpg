import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/character/character.dart';
import '../../state/player_roster.dart';
import '../widgets/xp_bar.dart';
import '../../game/sound/sound_manager.dart';
import '../widgets/character_portrait.dart';

class CharacterRosterScreen extends StatefulWidget {
  const CharacterRosterScreen({super.key});

  @override
  State<CharacterRosterScreen> createState() => _CharacterRosterScreenState();
}

class _CharacterRosterScreenState extends State<CharacterRosterScreen> {
  @override
  void initState() {
    super.initState();
    SoundManager.playIntro();
  }

  @override
  Widget build(BuildContext context) {
    final roster = context.watch<PlayerRoster>();
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
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seus Personagens'),
        actions: [
          IconButton(
            onPressed: () {
              SoundManager.playClick();
              Navigator.pushNamed(context, '/bestiary');
            },
            icon: const Icon(Icons.menu_book),
            tooltip: 'Livro dos Monstros',
          ),
        ],
      ),
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
              decoration: panelDecoration,
              onSelect: () {
              character.resetForBattle();
              SoundManager.playClick();
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
                : () {
                    SoundManager.playClick();
                    Navigator.pushNamed(context, '/create');
                  },
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
  final BoxDecoration decoration;

  const _CharacterCard({
    required this.character,
    required this.slot,
    required this.onSelect,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: decoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CharacterPortrait(character: character, size: 76),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${character.name} (Slot $slot)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'HP: ${character.maxHp}  ATK: ${character.attack}  DEF: ${character.defense}  SPD: ${character.speed}  MP: ${character.maxMana}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Relics: ${character.relics.length}',
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
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
    );
  }
}
