import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/pingu_brand.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: .92,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    Future.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceBlue,
      body: WatercolorBackdrop(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PinguMascot(size: 132, holdingNotebook: true),
                  const SizedBox(height: 20),
                  Text(
                    'Pingu Notes',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.deepOceanBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'seu caderno artístico digital',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.deepOceanBlue.withAlpha(185),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
