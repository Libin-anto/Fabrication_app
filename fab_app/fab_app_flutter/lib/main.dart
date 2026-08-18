import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: FabApp(),
    ),
  );
}

class FabApp extends ConsumerWidget {
  const FabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    // Premium Light Pink & Beige/Cream/Off-White Palette
    const primaryColor = Color(0xFFF5CBDD); // Soft Blush Light Pink
    const buttonPinkColor = Color(0xFFEC4899); // Slightly deeper pink for contrast on buttons/FABs
    const textDarkColor = Color(0xFF2E1E26); // Deep charcoal plum for text contrast
    const lightBackground = Color(0xFFFAF6F0); // Elegant Cream/Beige/Off-white
    const cardBorderColor = Color(0xFFEEDCC5); // Muted beige border
    const inputFillColor = Color(0xFFF5EFE6); // Light Warm Beige Fill
    const darkBackground = Color(0xFF1C131D); // Deep Plum Background
    const darkSurface = Color(0xFF2B1F2D); // Dark Plum Surface
    const darkCardBorder = Color(0xFF473349);

    return MaterialApp.router(
      title: 'Fab Management',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: lightBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: buttonPinkColor,
          secondary: buttonPinkColor,
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 2,
          centerTitle: false,
          backgroundColor: primaryColor,
          foregroundColor: textDarkColor,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textDarkColor,
            letterSpacing: 0.15,
          ),
          iconTheme: IconThemeData(color: textDarkColor),
          actionsIconTheme: IconThemeData(color: textDarkColor),
        ),
        cardTheme: CardThemeData(
          elevation: 0.5,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: cardBorderColor, width: 1),
          ),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: inputFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: buttonPinkColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIconColor: const Color(0xFF8A7A6E),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonPinkColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: buttonPinkColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: CircleBorder(),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: buttonPinkColor,
          primary: buttonPinkColor,
          secondary: buttonPinkColor,
          brightness: Brightness.dark,
          surface: darkSurface,
        ),
        scaffoldBackgroundColor: darkBackground,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 2,
          centerTitle: false,
          backgroundColor: darkSurface,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.15,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: darkCardBorder, width: 1),
          ),
          color: darkSurface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF221824),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: buttonPinkColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIconColor: const Color(0xFFC0A4C4),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonPinkColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: buttonPinkColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: CircleBorder(),
        ),
      ),
      themeMode: ThemeMode.light,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
