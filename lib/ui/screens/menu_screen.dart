import 'package:flutter/material.dart';
import '../../game/sound/sound_manager.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    SoundManager.playIntro();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/backgrounds/the-kingdom-raetna-buttons.png',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.45),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const Text(
                //   'The Kingdom Raetna',
                //   textAlign: TextAlign.center,
                //   style: TextStyle(
                //     fontSize: 30,
                //     fontWeight: FontWeight.w700,
                //     letterSpacing: 1.1,
                //   ),
                // ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    SoundManager.playClick();
                    Navigator.pushNamed(context, '/roster');
                  },
                  child: const Text('Iniciar Jogo'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    SoundManager.playClick();
                    Navigator.pushNamed(context, '/settings');
                  },
                  child: const Text('Configurações'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
