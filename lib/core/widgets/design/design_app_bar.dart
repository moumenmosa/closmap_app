import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DesignAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DesignAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actionLabel,
    this.onAction,
    this.actionColor,
    this.showBack = true,
  });

  final String title;
  final VoidCallback? onBack;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? actionColor;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.scaffoldBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: _BackButton(onPressed: onBack ?? () => Navigator.maybePop(context)),
              ),
            )
          : const SizedBox(width: 56),
      leadingWidth: 56,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: TextStyle(
                color: actionColor ?? AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          const SizedBox(width: 56),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.chevron_left, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
