import 'package:flutter/material.dart';
import '../../domain/character/knight.dart';
import '../../domain/character/mage.dart';
import '../../domain/character/archer.dart';
import '../../game/sound/sound_manager.dart';

class ClassSelectionScreen extends StatefulWidget {
  const ClassSelectionScreen({super.key});

  @override
  State<ClassSelectionScreen> createState() => _ClassSelectionScreenState();
}

class _ClassSelectionScreenState extends State<ClassSelectionScreen> {
  @override
  void initState() {
    super.initState();
    SoundManager.playIntro();
  }

  @override
  Widget build(BuildContext context) {
    final classes = [
      KnightClass(),
      MageClass(),
      ArcherClass(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Escolha sua classe')),
      body: ListView(
        children: classes.map((c) {
          return ListTile(
            title: Text(c.name),
            onTap: () {
              SoundManager.playClick();
              Navigator.pushNamed(
                context,
                '/battle',
                arguments: c.create(),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
