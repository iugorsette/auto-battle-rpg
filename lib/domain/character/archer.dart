import 'character_class.dart';
import 'character.dart';
import '../skills/basic_skills.dart';

class ArcherClass implements CharacterClass {
  @override
  String get name => 'Arqueiro';

  @override
  Character create() {
    return Character(
      name: name,
      maxHp: 110,
      attack: 25,
      defense: 8,
      speed: 2,
      skills: [
        SureShotSkill(),
      ],
    );
  }
}
