import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/character/archer.dart';
import '../../domain/character/knight.dart';
import '../../domain/character/mage.dart';
import '../../state/player_roster.dart';
import '../../domain/character/character_class.dart';
import '../../game/sound/sound_manager.dart';
import '../widgets/character_portrait.dart';
import '../../domain/skills/skill.dart';
import '../../domain/skills/basic_skills.dart';

class CharacterCreateScreen extends StatefulWidget {
  const CharacterCreateScreen({super.key});

  @override
  State<CharacterCreateScreen> createState() => _CharacterCreateScreenState();
}

class _CharacterCreateScreenState extends State<CharacterCreateScreen> {
  @override
  void initState() {
    super.initState();
    SoundManager.playIntro();
  }

  @override
  Widget build(BuildContext context) {
    final roster = context.watch<PlayerRoster>();
    final panelDecoration = BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xCC0F1B2A),
          Color(0xCC1A2B3F),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF2E445F)),
    );
    final classes = [
      _ClassInfo(
        classFactory: KnightClass(),
        description: 'Resistente e forte em combate corpo a corpo.',
      ),
      _ClassInfo(
        classFactory: MageClass(),
        description: 'Ataques magicos e dano elemental.',
      ),
      _ClassInfo(
        classFactory: ArcherClass(),
        description: 'Ataques a distancia com chance de critico.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Criar Personagem')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Escolha uma classe',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...classes.map((info) {
            final preview = info.classFactory.create();
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: panelDecoration,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CharacterPortrait(character: preview, size: 72),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              info.classFactory.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(info.description),
                            const SizedBox(height: 10),
                            Text(
                              'HP: ${preview.maxHp}  ATK: ${preview.attack}  DEF: ${preview.defense}  SPD: ${preview.speed}  MP: ${preview.maxMana}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Habilidades',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            ...preview.skills.map(
                              (skill) {
                                final info = _skillInfo(skill);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: _SkillLine(
                                    name: skill.name,
                                    description: info.description,
                                    cooldown: skill.cooldown,
                                    mana: skill.manaCost,
                                    minLevel: skill.minLevel,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: roster.characters.length >= roster.maxCharacters
                          ? null
                          : () {
                              SoundManager.playClick();
                              roster.add(info.classFactory.create());
                              Navigator.pop(context);
                            },
                      child: const Text('Criar'),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ClassInfo {
  final CharacterClass classFactory;
  final String description;

  _ClassInfo({
    required this.classFactory,
    required this.description,
  });
}

_SkillInfo _skillInfo(Skill skill) {
  if (skill is FireballSkill) {
    return const _SkillInfo('Projétil que causa dano total ATK * 2 (70% instantâneo + queimadura).');
  }
  if (skill is FreezeSkill) {
    return const _SkillInfo('Aplica Congelar por 2 ticks e causa dano mágico igual ao ATK.');
  }
  if (skill is IncinerateSkill) {
    return const _SkillInfo('Queimadura por 3 ticks (ATK * 1.8). Espalha se o alvo morrer em 3s.');
  }
  if (skill is WarCrySkill) {
    return const _SkillInfo('Dobra a velocidade de ataque por 3 ticks e cura 10% HP por tick.');
  }
  if (skill is SwordSpinSkill) {
    return const _SkillInfo('Ataque em área: ATK * 1.15 em todos os inimigos vivos.');
  }
  if (skill is SureShotSkill) {
    return const _SkillInfo('Após 1s, dispara flecha crítica com ATK * 1.5.');
  }
  if (skill is ArrowRainSkill) {
    return const _SkillInfo('3 ondas em 3s: cada uma causa ATK * 0.6 em todos os inimigos.');
  }
  if (skill is RapidShotSkill) {
    return const _SkillInfo('Dispara duas flechas rápidas (visual).');
  }
  if (skill is ShieldSkill) {
    return const _SkillInfo('Aumenta DEF em +10.');
  }
  if (skill is TauntSkill) {
    return const _SkillInfo('Provoca o inimigo (efeito visual).');
  }
  if (skill is FocusSkill) {
    return const _SkillInfo('Aumenta ATK em +5.');
  }

  return const _SkillInfo('Habilidade especial.');
}

class _SkillInfo {
  final String description;

  const _SkillInfo(this.description);
}

class _SkillLine extends StatelessWidget {
  final String name;
  final String description;
  final int cooldown;
  final int mana;
  final int minLevel;

  const _SkillLine({
    required this.name,
    required this.description,
    required this.cooldown,
    required this.mana,
    required this.minLevel,
  });

  @override
  Widget build(BuildContext context) {
    final unlock = minLevel > 1 ? 'Nv $minLevel' : 'Inicial';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF132235),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF24364C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$name ($unlock)',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
          const SizedBox(height: 2),
          Text(
            'CD ${cooldown}s  Mana $mana',
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
