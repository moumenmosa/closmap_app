import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../profile_image.dart';

class DesignGradientHeader extends StatelessWidget {
  const DesignGradientHeader({
    super.key,
    this.imageUrl,
    this.height = 180,
    this.child,
    this.bottomRadius = 24,
  });

  final String? imageUrl;
  final double height;
  final Widget? child;
  final double bottomRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(bottomRadius),
      ),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty)
              ProfileImage(
                url: imageUrl!,
                fit: BoxFit.cover,
                errorWidget: const _DefaultGradient(),
              )
            else
              const _DefaultGradient(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
            if (child != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: child!,
              ),
          ],
        ),
      ),
    );
  }
}

class _DefaultGradient extends StatelessWidget {
  const _DefaultGradient();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.teal,
            AppColors.blue,
          ],
        ),
      ),
    );
  }
}
