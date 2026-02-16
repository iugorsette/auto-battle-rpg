import 'character.dart';

abstract class CharacterClass {
  String get name;
  Character create();
}
