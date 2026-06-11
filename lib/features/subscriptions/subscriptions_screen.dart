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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: DesignAppBar(title: l10n.subscriptions),
        body: const LoadingView(),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: DesignAppBar(title: l10n.subscriptions),
        body: EmptyState(message: l10n.errorGeneric),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            appBar: DesignAppBar(title: l10n.subscriptions),
            body: EmptyState(message: l10n.errorGeneric),
          );
        }
        return _SubscriptionsBody(l10n: l10n, user: user);
      },
    );
  }
}

class _SubscriptionsBody extends ConsumerWidget {
  const _SubscriptionsBody({required this.l10n, required this.user});

  final AppLocalizations l10n;
  final AppUser user;

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
            onPressed: () => _showPointPackages(context, ref, user.uid),
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
              if (snap.hasError) {
                return EmptyState(message: l10n.errorGeneric);
              }
              if (!snap.hasData) {
                return const LoadingView();
              }
              final txs = snap.data!;
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

  void _showPointPackages(BuildContext context, WidgetRef ref, String uid) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => StreamBuilder<List<PointPackage>>(
        stream: ref.read(subscriptionRepositoryProvider).watchPointPackages(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.errorGeneric),
            );
          }
          if (!snap.hasData) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: LoadingView(),
            );
          }
          final packages = snap.data!;
          if (packages.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.noResults),
            );
          }
          return ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: packages
                .map(
                  (pkg) => ListTile(
                    title: Text('${pkg.points} ${l10n.points}'),
                    subtitle: Text('${pkg.price} ${pkg.currency}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/payment?type=points&id=${pkg.id}');
                    },
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
