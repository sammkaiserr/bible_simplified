import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/book.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/reading_screen.dart';
import 'screens/book_selection_screen.dart';
import 'screens/chapter_selection_screen.dart';
import 'screens/search_screen.dart';
import 'screens/library_screen.dart';
import 'screens/settings_screen.dart';

import 'providers/app_settings_provider.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/read',
          builder: (context, state) => const ReadingScreen(),
        ),
        GoRoute(
          path: '/books',
          builder: (context, state) => const BookSelectionScreen(),
        ),
        GoRoute(
          path: '/chapters',
          builder: (context, state) => ChapterSelectionScreen(book: state.extra as Book),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/library',
          builder: (context, state) => const LibraryScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Bible Simplified',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeMode: settings.themeMode,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.gold500,
          brightness: Brightness.light,
          primary: AppColors.gold500,
          onPrimary: Colors.white,
          secondary: AppColors.amber700,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.ivory50,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.ivory50,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: AppColors.navy900),
          titleTextStyle: TextStyle(
            color: AppColors.navy900,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: GoogleFonts.outfitTextTheme().copyWith(
          titleLarge: GoogleFonts.outfit(
            color: AppColors.navy950,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: GoogleFonts.outfit(
            color: AppColors.navy900,
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.gold500,
          thumbColor: AppColors.gold500,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.gold500,
          brightness: Brightness.dark,
          primary: AppColors.gold500,
          onPrimary: Colors.white,
          secondary: AppColors.gold300,
          surface: AppColors.navy850,
        ),
        scaffoldBackgroundColor: AppColors.navy950,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy950,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
          titleLarge: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: GoogleFonts.outfit(
            color: Colors.white70,
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.gold500,
          thumbColor: AppColors.gold500,
        ),
      ),
    );
  }
}
