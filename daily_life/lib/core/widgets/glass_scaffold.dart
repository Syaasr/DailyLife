import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.deepSapphire,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.deepSapphire,
                  AppColors.deepSapphireDark,
                ],
              ),
            ),
          ),

          // Bokeh orbs
          Positioned(
            top: -60,
            left: -40,
            child: _BokehOrb(
              size: 200,
              color: AppColors.glowingBlue.withValues(alpha: 0.15),
            ),
          ),
          Positioned(
            top: 300,
            right: -80,
            child: _BokehOrb(
              size: 260,
              color: AppColors.glowingBlue.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: _BokehOrb(
              size: 180,
              color: AppColors.glowingBlue.withValues(alpha: 0.12),
            ),
          ),

          // Main content
          SafeArea(child: body),
        ],
      ),
    );
  }
}

class _BokehOrb extends StatelessWidget {
  const _BokehOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
