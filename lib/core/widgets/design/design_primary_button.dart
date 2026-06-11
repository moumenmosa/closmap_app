import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class DesignPrimaryButton extends StatelessWidget {
  const DesignPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.minimumHeight = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double minimumHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: minimumHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryAction,
          foregroundColor: foregroundColor ?? Colors.white,
          disabledBackgroundColor:
              (backgroundColor ?? AppColors.primaryAction).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
          ),
          elevation: 0,
        ),
        onPressed: loading ? null : onPressed,
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    if (loading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: foregroundColor ?? Colors.white,
        ),
      );
    }

    if (leading != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leading!,
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }

    return Text(
      label,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}
