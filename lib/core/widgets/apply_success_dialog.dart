import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/app_user.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'design/design_widgets.dart';
import '../../l10n/app_localizations.dart';

Future<void> showApplySuccessDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String companyName,
  required AppUser user,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ApplySuccessSheet(
      companyName: companyName,
      user: user,
      onDone: () {
        Navigator.pop(ctx);
        if (context.mounted) context.pop();
      },
      onRenew: () {
        Navigator.pop(ctx);
        if (context.mounted) context.push('/subscriptions');
      },
    ),
  );
}

class _ApplySuccessSheet extends StatelessWidget {
  const _ApplySuccessSheet({
    required this.companyName,
    required this.user,
    required this.onDone,
    required this.onRenew,
  });

  final String companyName;
  final AppUser user;
  final VoidCallback onDone;
  final VoidCallback onRenew;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final daysLeft = user.subscriptionExpiry != null
        ? user.subscriptionExpiry!.difference(DateTime.now()).inDays
        : 0;
    final tierPoints = switch (user.activeTier) {
      SubscriptionTier.bronze => 30,
      SubscriptionTier.silver => 80,
      SubscriptionTier.gold => 150,
      _ => 100,
    };

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onDone,
              icon: const Icon(Icons.close),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AvatarRing(child: const Icon(Icons.person, size: 36)),
              const SizedBox(width: 16),
              _AvatarRing(
                child: Text(
                  companyName.isNotEmpty ? companyName[0].toUpperCase() : 'C',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.successfully,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.applicationSentTo(companyName),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.inputRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.subscriptions,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: AppColors.primary),
                          children: [
                            TextSpan(
                              text: '${user.points}/$tierPoints',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: ' ${l10n.points.toLowerCase()}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.daysLeft(daysLeft.clamp(0, 999)),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onRenew,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(l10n.renewSubscription),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          DesignPrimaryButton(label: l10n.done, onPressed: onDone),
        ],
      ),
    );
  }
}

class _AvatarRing extends StatelessWidget {
  const _AvatarRing({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.teal, AppColors.blue],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}
