import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.outlined = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton(
        onPressed: loading ? null : onPressed,
        child: _child(),
      );
    }
    return ElevatedButton(
      style: color != null
          ? ElevatedButton.styleFrom(backgroundColor: color)
          : null,
      onPressed: loading ? null : onPressed,
      child: _child(),
    );
  }

  Widget _child() {
    if (loading) {
      return const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }
    return Text(label);
  }
}

class AppLogoHeader extends StatelessWidget {
  const AppLogoHeader({super.key, this.size = 120, this.showTitle = false});

  final double size;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/logo.png', height: size),
        if (showTitle) ...[
          const SizedBox(height: 8),
          Text(
            'CloseMap',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ],
    );
  }
}
