import 'package:flutter/material.dart';
import '../../domain/character/character.dart';

class CharacterPortrait extends StatelessWidget {
  final Character character;
  final double size;

  const CharacterPortrait({
    super.key,
    required this.character,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = _spriteForCharacter(character);

    return Container(
      width: size,
      height: size,
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

  String _spriteForCharacter(Character character) {
    if (character.spritePath != null) {
      return 'assets/${character.spritePath!}';
    }
    switch (character.name) {
      case 'Cavaleiro':
        return 'assets/characters/knight.png';
      case 'Mago':
        return 'assets/characters/mage.png';
      case 'Arqueiro':
        return 'assets/characters/archer.png';
      default:
        return 'assets/characters/goblin.png';
    }
  }
}
