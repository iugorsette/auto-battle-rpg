import 'package:flutter/material.dart';
import '../../game/sound/sound_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _musicVolume = SoundManager.musicVolume;
  double _sfxVolume = SoundManager.sfxVolume;
  bool _muted = SoundManager.muted;

  @override
  void initState() {
    super.initState();
    SoundManager.playIntro();
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: panelDecoration,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Som desligado'),
                  value: _muted,
                  onChanged: (value) async {
                    setState(() => _muted = value);
                    await SoundManager.setMuted(value);
                  },
                ),
                const SizedBox(height: 12),
                Text('Música: ${(_musicVolume * 100).round()}%'),
                Slider(
                  value: _musicVolume,
                  onChanged: _muted
                      ? null
                      : (value) async {
                          setState(() => _musicVolume = value);
                          await SoundManager.setMusicVolume(value);
                        },
                ),
                const SizedBox(height: 6),
                Text('Efeitos: ${(_sfxVolume * 100).round()}%'),
                Slider(
                  value: _sfxVolume,
                  onChanged: _muted
                      ? null
                      : (value) {
                          setState(() => _sfxVolume = value);
                          SoundManager.setSfxVolume(value);
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
