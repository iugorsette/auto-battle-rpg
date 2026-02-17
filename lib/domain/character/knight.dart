import 'character_class.dart';
import 'character.dart';
import '../skills/basic_skills.dart';

class KnightClass implements CharacterClass {
  @override
  String get name => 'Cavaleiro';

  @override
  Character create() {
    return Character(
      name: name,
      maxHp: 150,
      attack: 30,
      defense: 15,
      speed: 1,
      skills: [
        WarCrySkill(),
        SwordSpinSkill(),
      ],
    );
  }
}
