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
            'assets/backgrounds/the-kingdom-raetna.png',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.12),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 12),
                child: _MenuIconButton(
                  icon: Icons.settings,
                  tooltip: 'Configurações',
                  onPressed: () {
                    SoundManager.playClick();
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 720;
                    final buttons = [
                      _MenuButton(
                        label: 'INICIAR JOGO',
                        enabled: true,
                        onPressed: () {
                          SoundManager.playClick();
                          Navigator.pushNamed(context, '/roster');
                        },
                      ),
                      _MenuButton(
                        label: 'OUTRAS OPÇÕES',
                        enabled: false,
                        onPressed: () {
                          SoundManager.playClick();
                        },
                      ),
                    ];

                    if (isNarrow) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buttons[0],
                          const SizedBox(height: 10),
                          buttons[1],
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buttons[0],
                        const SizedBox(width: 28),
                        buttons[1],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onPressed;

  const _MenuButton({
    required this.label,
    required this.enabled,
    this.onPressed,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    final hover = _hovered && enabled;
    final baseWidth = MediaQuery.of(context).size.width;
    final width = baseWidth.clamp(280, 560) * 0.35;
    final height = (width * 0.22).clamp(52.0, 74.0);
    final gold = const Color(0xFFD2A24D);
    final goldBright = const Color(0xFFF1D28B);
    final dark = const Color(0xFF2E1A0E);
    final mid = const Color(0xFF4C2C16);
    final disabledBase = const Color(0xFF2A2A2A);
    final disabledEdge = const Color(0xFF6A6A6A);

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: enabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: hover ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            width: width,
            height: height,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: enabled
                    ? [
                        hover ? goldBright : gold,
                        hover ? gold : const Color(0xFFB07C2A),
                      ]
                    : [disabledEdge, const Color(0xFF4C4C4C)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: hover ? 16 : 10,
                  offset: const Offset(0, 6),
                ),
                if (hover)
                  BoxShadow(
                    color: goldBright.withOpacity(0.5),
                    blurRadius: 18,
                    offset: const Offset(0, 0),
                  ),
              ],
            ),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: enabled
                      ? [
                          hover ? const Color(0xFF6A3A1B) : mid,
                          hover ? const Color(0xFF2A160C) : dark,
                        ]
                      : [const Color(0xFF3A3A3A), disabledBase],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: enabled ? goldBright : const Color(0xFF7A7A7A),
                  width: 1.2,
                ),
              ),
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: height * 0.3,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: enabled ? goldBright : const Color(0xFFB0B0B0),
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _MenuIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_MenuIconButton> createState() => _MenuIconButtonState();
}

class _MenuIconButtonState extends State<_MenuIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hover = _hovered;
    final gold = const Color(0xFFD2A24D);
    final goldBright = const Color(0xFFF1D28B);
    final dark = const Color(0xFF2E1A0E);
    final mid = const Color(0xFF4C2C16);

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedScale(
            scale: hover ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              width: 54,
              height: 40,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    hover ? goldBright : gold,
                    hover ? gold : const Color(0xFFB07C2A),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: hover ? 16 : 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      hover ? const Color(0xFF6A3A1B) : mid,
                      hover ? const Color(0xFF2A160C) : dark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: goldBright, width: 1.2),
                ),
                child: Icon(
                  widget.icon,
                  color: goldBright,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
