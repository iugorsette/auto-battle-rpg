import 'character_class.dart';
import 'character.dart';
import '../skills/basic_skills.dart';

class MageClass implements CharacterClass {
  @override
  String get name => 'Mago';

  @override
  Character create() {
    return Character(
      name: name,
      maxHp: 90,
      attack: 25,
      defense: 5,
      speed: 1,
      maxMana: 100,
      skills: [
        FireballSkill(),
        FreezeSkill(),
        IncinerateSkill(),
      ],
    );
  }
}
