import 'package:flutter/material.dart';
import '../../domain/character/knight.dart';
import '../../domain/character/mage.dart';
import '../../domain/character/archer.dart';

class ClassSelectionScreen extends StatelessWidget {
  const ClassSelectionScreen({super.key});

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
