import 'package:flutter/material.dart';
import '../../domain/skills/skill.dart';
import '../../domain/character/character.dart';

class SkillButton extends StatelessWidget {
  final Skill skill;
  final Character caster;
  final VoidCallback onPressed;

  const SkillButton({
    super.key,
    required this.skill,
    required this.caster,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cooldown = skill.currentCooldown;
    return ElevatedButton(
      onPressed: skill.canUse(caster) ? onPressed : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(skill.name),
          if (cooldown > 0)
            Text(
              'CD ${cooldown}s',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFD54F),
              ),
            ),
        ],
      ),
    );
  }
}
