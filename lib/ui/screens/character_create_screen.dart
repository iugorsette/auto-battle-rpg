import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/character/archer.dart';
import '../../domain/character/knight.dart';
import '../../domain/character/mage.dart';
import '../../state/player_roster.dart';
import '../../domain/character/character_class.dart';

class CharacterCreateScreen extends StatelessWidget {
  const CharacterCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roster = context.watch<PlayerRoster>();
    final classes = [
      _ClassInfo(
        classFactory: KnightClass(),
        description: 'Resistente e forte em combate corpo a corpo.',
      ),
      _ClassInfo(
        classFactory: MageClass(),
        description: 'Ataques magicos e dano elemental.',
      ),
      _ClassInfo(
        classFactory: ArcherClass(),
        description: 'Ataques a distancia com chance de critico.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Criar Personagem')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Escolha uma classe',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...classes.map((info) {
            final preview = info.classFactory.create();
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.classFactory.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(info.description),
                    const SizedBox(height: 10),
                    Text(
                      'HP: ${preview.maxHp}  ATK: ${preview.attack}  DEF: ${preview.defense}  SPD: ${preview.speed}  MP: ${preview.maxMana}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: roster.characters.length >= roster.maxCharacters
                            ? null
                            : () {
                                roster.add(info.classFactory.create());
                                Navigator.pop(context);
                              },
                        child: const Text('Criar'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ClassInfo {
  final CharacterClass classFactory;
  final String description;

  _ClassInfo({
    required this.classFactory,
    required this.description,
  });
}
