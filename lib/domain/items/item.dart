import '../character/character.dart';

abstract class Item {
  String get name;
  void apply(Character character);
}
