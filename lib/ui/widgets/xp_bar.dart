import 'package:flutter/material.dart';

class XpBar extends StatelessWidget {
  final int level;
  final int xp;
  final int xpToNext;

  const XpBar({
    super.key,
    required this.level,
    required this.xp,
    required this.xpToNext,
  });

  @override
  Widget build(BuildContext context) {
    final progress = xpToNext == 0 ? 0.0 : (xp / xpToNext).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nivel $level'),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.white12,
            color: Colors.lightGreenAccent,
          ),
        ),
        const SizedBox(height: 2),
        Text('$xp / $xpToNext XP', style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
