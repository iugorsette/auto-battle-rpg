import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'state/player_roster.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PlayerRoster(),
      child: const App(),
    ),
  );
}
