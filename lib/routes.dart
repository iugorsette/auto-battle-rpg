import 'package:flutter/material.dart';
import 'ui/screens/menu_screen.dart';
import 'ui/screens/battle_screen.dart';
import 'ui/screens/character_create_screen.dart';
import 'ui/screens/character_roster_screen.dart';
import 'ui/screens/battle_select_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/bestiary_screen.dart';

final routes = <String, WidgetBuilder>{
  '/': (_) => const MenuScreen(),
  '/roster': (_) => const CharacterRosterScreen(),
  '/create': (_) => const CharacterCreateScreen(),
  '/battle-select': (_) => const BattleSelectScreen(),
  '/battle': (_) => const BattleScreen(),
  '/settings': (_) => const SettingsScreen(),
  '/bestiary': (_) => const BestiaryScreen(),
};
