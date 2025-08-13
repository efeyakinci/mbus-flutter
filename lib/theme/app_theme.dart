import 'package:flutter/material.dart';
import 'package:mbus/constants.dart';

class AppTextStyles {
  static const TextStyle pageTitle = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: MICHIGAN_BLUE,
  );

  static const TextStyle headerStopName = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w800,
    color: MICHIGAN_BLUE,
  );

  static const TextStyle headerBusTitle = TextStyle(
    fontSize: 46,
    fontWeight: FontWeight.w800,
    color: MICHIGAN_BLUE,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: MICHIGAN_BLUE,
  );

  static const TextStyle settingsTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: MICHIGAN_BLUE,
  );

  static const TextStyle arrivalsSection = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: MICHIGAN_MAIZE,
  );

  static const TextStyle routeName = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: MICHIGAN_BLUE,
  );

  static const TextStyle routeMeta = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );

  static const TextStyle routeDirectionBlue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: MICHIGAN_BLUE,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: false);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      primaryColor: Colors.white,
      colorScheme: base.colorScheme.copyWith(
        primary: MICHIGAN_BLUE,
        secondary: MICHIGAN_MAIZE,
        onPrimary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MICHIGAN_BLUE,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MICHIGAN_BLUE,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade400)),
        backgroundColor: Colors.transparent,
        labelStyle:
            const TextStyle(color: MICHIGAN_BLUE, fontWeight: FontWeight.bold),
      ),
      dividerColor: Colors.grey.shade300,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: MICHIGAN_BLUE,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: false);
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      colorScheme: base.colorScheme.copyWith(
        primary: MICHIGAN_MAIZE,
        secondary: MICHIGAN_MAIZE,
        onPrimary: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF121212),
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MICHIGAN_MAIZE,
          foregroundColor: MICHIGAN_BLUE,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MICHIGAN_MAIZE,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade700)),
        backgroundColor: Colors.transparent,
        labelStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      dividerColor: Colors.grey.shade700,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: MICHIGAN_MAIZE,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.black,
      ),
    );
  }
}
