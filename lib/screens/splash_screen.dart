import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.navy900, AppColors.navy950]
                : [AppColors.ivory50, AppColors.ivory200],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.gold500, AppColors.amber700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold500.withOpacity(isDark ? 0.3 : 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              )
              .animate()
              .fade(duration: 800.ms)
              .scale(delay: 100.ms, duration: 600.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 32),

              Text(
                'Bible Simplified',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: isDark ? AppColors.gold300 : AppColors.navy900,
                ),
              )
              .animate()
              .fade(delay: 500.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

              const SizedBox(height: 8),

              Text(
                'సులభమైన తెలుగు బైబిల్',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'NotoSansTelugu',
                  color: isDark ? Colors.white70 : AppColors.navy700,
                  letterSpacing: 0.2,
                ),
              )
              .animate()
              .fade(delay: 800.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

              const SizedBox(height: 48),

              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold500),
                ),
              )
              .animate()
              .fade(delay: 1200.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
