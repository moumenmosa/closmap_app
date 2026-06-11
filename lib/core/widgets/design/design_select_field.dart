import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class DesignSelectField extends StatelessWidget {
  const DesignSelectField({
    super.key,
    required this.label,
    this.value,
    this.hint,
    this.onTap,
    this.errorText,
    this.enabled = true,
  });

  final String label;
  final String? value;
  final String? hint;
  final VoidCallback? onTap;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    final displayText = hasValue ? value! : (hint ?? 'Select');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: enabled ? AppColors.surface : AppColors.surfaceMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.inputRadius),
            side: BorderSide(
              color: errorText != null ? AppColors.error : AppColors.border,
            ),
          ),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(AppTheme.inputRadius),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayText,
                      style: TextStyle(
                        color: hasValue ? AppColors.textPrimary : AppColors.textHint,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
