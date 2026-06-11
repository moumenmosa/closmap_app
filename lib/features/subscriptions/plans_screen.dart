import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/notification_item.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  Color _planColor(String id) {
    switch (id) {
      case 'bronze':
        return AppColors.bronze;
      case 'silver':
        return AppColors.silver;
      case 'gold':
        return AppColors.gold;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: DesignAppBar(title: l10n.selectPlan),
      body: StreamBuilder<List<SubscriptionPlan>>(
        stream: ref.watch(subscriptionRepositoryProvider).watchPlans(),
        builder: (context, snap) {
          final plans = snap.data ?? [];
          if (plans.isEmpty) {
            return Center(child: Text(l10n.noResults));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(20),
            itemCount: plans.length,
            itemBuilder: (_, i) {
              final plan = plans[i];
              final color = _planColor(plan.id);
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                  border: Border.all(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${plan.price} ${plan.currency}/month',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text('${plan.points} ${l10n.points}'),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          plan.description,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      DesignPrimaryButton(
                        label: l10n.payNow,
                        onPressed: () =>
                            context.push('/payment?type=plan&id=${plan.id}'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
