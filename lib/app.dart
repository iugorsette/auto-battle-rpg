import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.cinzelTextTheme(baseTheme.textTheme).copyWith(
      bodyMedium: GoogleFonts.cardo(textStyle: baseTheme.textTheme.bodyMedium),
      bodySmall: GoogleFonts.cardo(textStyle: baseTheme.textTheme.bodySmall),
      titleMedium: GoogleFonts.cinzel(textStyle: baseTheme.textTheme.titleMedium),
      titleLarge: GoogleFonts.cinzel(textStyle: baseTheme.textTheme.titleLarge),
      headlineSmall: GoogleFonts.cinzel(textStyle: baseTheme.textTheme.headlineSmall),
    );

    return MaterialApp(
      title: 'Auto Battler RPG',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: textTheme,
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: const Color(0xFFFFD54F),
          secondary: const Color(0xFF4FC3F7),
          surface: const Color(0xFF162235),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F1B2A),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF162235),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF20324A),
            foregroundColor: const Color(0xFFFFE082),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFFE082),
          ),
        ),
      ),
      initialRoute: '/',
      routes: routes,
    );
  }
}
