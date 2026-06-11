import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/app_user.dart';
import '../../core/models/notification_item.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.type, required this.itemId});

  final String type;
  final String itemId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _loading = false;
  String _cardNumber = '**** **** **** 4242';
  String _cardHolder = 'Demo User';

  Future<void> _pay() async {
    final l10n = AppLocalizations.of(context);
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    setState(() => _loading = true);
    final repo = ref.read(subscriptionRepositoryProvider);

    try {
      if (widget.type == 'plan') {
        final plans = await repo.watchPlans().first;
        SubscriptionPlan? plan;
        for (final p in plans) {
          if (p.id == widget.itemId) {
            plan = p;
            break;
          }
        }
        if (plan == null) throw Exception('plan_not_found');
        final tier = SubscriptionTier.values.firstWhere(
          (t) => t.name == plan!.id,
          orElse: () => SubscriptionTier.bronze,
        );
        await repo.subscribe(uid, tier, plan.points);
      } else {
        final packages = await repo.watchPointPackages().first;
        PointPackage? pkg;
        for (final p in packages) {
          if (p.id == widget.itemId) {
            pkg = p;
            break;
          }
        }
        if (pkg == null) throw Exception('package_not_found');
        await repo.purchasePoints(uid, pkg.points, pkg.id);
      }
      if (mounted) context.go('/subscriptions');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: DesignAppBar(title: l10n.payNow),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navy, AppColors.blue],
                ),
                borderRadius: BorderRadius.circular(AppTheme.inputRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.credit_card, color: Colors.white, size: 32),
                  const SizedBox(height: 24),
                  Text(
                    _cardNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _cardHolder,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DesignSectionCard(
              title: l10n.payNow,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.payment, color: AppColors.primaryAction),
                    title: const Text('Visa'),
                    trailing: const Icon(Icons.check_circle, color: AppColors.primaryAction),
                  ),
                  const Divider(),
                  Text(
                    l10n.mockPaymentNote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Spacer(),
            DesignPrimaryButton(
              label: l10n.payNow,
              loading: _loading,
              onPressed: _pay,
            ),
          ],
        ),
      ),
    );
  }
}
