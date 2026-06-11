import 'package:flutter/material.dart';

/// Optional Figma export shown behind auth screens.
class DesignBackground extends StatelessWidget {
  const DesignBackground({
    super.key,
    required this.assetPath,
    required this.child,
    this.opacity = 0.12,
  });

  final String assetPath;
  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: opacity,
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        child,
      ],
    );
  }
}
