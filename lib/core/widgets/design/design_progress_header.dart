import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DesignProgressHeader extends StatelessWidget {
  const DesignProgressHeader({
    super.key,
    required this.progress,
    this.height = 3,
  });

  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);

    return ColoredBox(
      color: AppColors.scaffoldBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: height,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }
}
