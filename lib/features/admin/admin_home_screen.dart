import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/app_user.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';
import '../shared/side_drawer.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          title: const Text('Admin'),
          backgroundColor: AppColors.scaffoldBg,
          elevation: 0,
        ),
        body: const LoadingView(),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          title: const Text('Admin'),
          backgroundColor: AppColors.scaffoldBg,
          elevation: 0,
        ),
        body: EmptyState(message: l10n.errorGeneric),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            appBar: AppBar(
              title: const Text('Admin'),
              backgroundColor: AppColors.scaffoldBg,
              elevation: 0,
            ),
            body: EmptyState(message: l10n.errorGeneric),
          );
        }
        return _AdminHomeBody(l10n: l10n, user: user);
      },
    );
  }
}

class _AdminHomeBody extends ConsumerStatefulWidget {
  const _AdminHomeBody({required this.l10n, required this.user});

  final AppLocalizations l10n;
  final AppUser user;

  @override
  ConsumerState<_AdminHomeBody> createState() => _AdminHomeBodyState();
}

class _AdminHomeBodyState extends ConsumerState<_AdminHomeBody> {
  bool _seeding = false;

  Future<void> _seedCatalog() async {
    setState(() => _seeding = true);
    try {
      await ref.read(seedServiceProvider).seedLookups();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catalog seeded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final user = widget.user;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Admin'),
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
      ),
      drawer: SideDrawer(user: user),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Welcome, ${user.displayName}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          DesignSectionCard(
            title: 'Demo accounts',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('admin@closemap.demo'),
                Text('sarah.seeker@closemap.demo'),
                Text('techcorp@closemap.demo'),
                SizedBox(height: 8),
                Text('Password: Demo1234!'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DesignPrimaryButton(
            label: 'Manage Lookups',
            onPressed: () => context.push('/admin/lookups'),
          ),
          const SizedBox(height: 12),
          DesignPrimaryButton(
            label: l10n.seedDemoData,
            onPressed: _seeding ? null : _seedCatalog,
            backgroundColor: AppColors.primary,
          ),
          if (_seeding) ...[
            const SizedBox(height: 12),
            const Center(child: CircularProgressIndicator()),
          ],
          const SizedBox(height: 12),
          DesignPrimaryButton(
            label: l10n.leaderBoard,
            onPressed: () => context.push('/leaderboard'),
          ),
          const SizedBox(height: 12),
          DesignPrimaryButton(
            label: l10n.settings,
            onPressed: () => context.push('/settings'),
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
