import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../core/models/app_user.dart';
import '../../core/models/notification_item.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  Color _tierColor(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.bronze:
        return AppColors.bronze;
      case SubscriptionTier.silver:
        return AppColors.silver;
      case SubscriptionTier.gold:
        return AppColors.gold;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: DesignAppBar(title: l10n.subscriptions),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (user.points <= AppConfig.lowPointsThreshold)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: AppColors.orange),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.lowPointsWarning)),
                ],
              ),
            ),
          if (user.hasActiveSubscription &&
              user.subscriptionExpiry != null &&
              user.subscriptionExpiry!.difference(DateTime.now()).inDays <=
                  AppConfig.expiryReminderDays)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: AppColors.gold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l10n.subscriptionExpiring(
                      user.subscriptionExpiry!.difference(DateTime.now()).inDays,
                    )),
                  ),
                ],
              ),
            ),
          DesignSectionCard(
            title: l10n.subscriptions,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.hasActiveSubscription
                      ? user.tier.name.toUpperCase()
                      : l10n.noSubscription,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _tierColor(user.activeTier),
                  ),
                ),
                const SizedBox(height: 8),
                Text('${l10n.points}: ${user.points}'),
                if (user.subscriptionExpiry != null) ...[
                  Text(l10n.daysLeft(
                    user.subscriptionExpiry!.difference(DateTime.now()).inDays,
                  )),
                  Text(l10n.renewalDate(Formatters.date(user.subscriptionExpiry))),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          DesignPrimaryButton(
            label: l10n.addNewPlan,
            onPressed: () => context.push('/plans'),
          ),
          const SizedBox(height: 12),
          DesignPrimaryButton(
            label: l10n.buyPoints,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.primaryAction,
            onPressed: () => context.push('/payment?type=points&id=pkg10'),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.transactionHistory,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<TransactionItem>>(
            stream: ref.watch(subscriptionRepositoryProvider).watchTransactions(user.uid),
            builder: (context, snap) {
              final txs = snap.data ?? [];
              if (txs.isEmpty) return EmptyState(message: l10n.noResults);
              return Column(
                children: txs.map((t) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListTile(
                      title: Text(t.description),
                      subtitle: Text(Formatters.dateTime(t.createdAt)),
                      trailing: Text(
                        '${t.pointsDelta > 0 ? '+' : ''}${t.pointsDelta}',
                        style: TextStyle(
                          color: t.pointsDelta >= 0 ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
