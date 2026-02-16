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
      child: SizedBox(
        width: 110,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(skill.name, textAlign: TextAlign.center),
            if (cooldown > 0)
              Text(
                'CD ${cooldown}s',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFD54F),
                ),
              ),
            if (cooldown > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: cooldown / skill.cooldown,
                    minHeight: 5,
                    backgroundColor: const Color(0xFF1B2A3A),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD54F)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
