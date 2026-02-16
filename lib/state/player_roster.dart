import 'package:flutter/material.dart';
import '../domain/character/character.dart';

class PlayerRoster extends ChangeNotifier {
  final List<Character> _characters = [];
  final int maxCharacters;

  PlayerRoster({this.maxCharacters = 3});

  List<Character> get characters => List.unmodifiable(_characters);

  bool add(Character character) {
    if (_characters.length >= maxCharacters) return false;
    _characters.add(character);
    notifyListeners();
    return true;
  }

  void remove(Character character) {
    _characters.remove(character);
    notifyListeners();
  }
}
