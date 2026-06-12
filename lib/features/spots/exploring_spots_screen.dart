import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/app_user.dart';
import '../../core/models/exploring_spot.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/common_widgets.dart';
import '../../l10n/app_localizations.dart';

class ExploringSpotsScreen extends ConsumerWidget {
  const ExploringSpotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.exploringSpots)),
        body: const LoadingView(),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: Text(l10n.exploringSpots)),
        body: EmptyState(message: l10n.errorGeneric),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.exploringSpots)),
            body: EmptyState(message: l10n.errorGeneric),
          );
        }
        return _ExploringSpotsBody(l10n: l10n, user: user);
      },
    );
  }
}

class _ExploringSpotsBody extends ConsumerWidget {
  const _ExploringSpotsBody({required this.l10n, required this.user});

  final AppLocalizations l10n;
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxSpots = user.activeTier.maxExploringSpots;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exploringSpots)),
      body: StreamBuilder<List<ExploringSpot>>(
        stream: ref.watch(spotRepositoryProvider).watchSpots(user.uid),
        builder: (context, snap) {
          if (snap.hasError) {
            return EmptyState(message: l10n.errorGeneric);
          }
          if (!snap.hasData) {
            return const LoadingView();
          }
          final spots = snap.data!;
          if (spots.isEmpty) {
            return EmptyState(
              message: '${l10n.emptySpots}\n${l10n.defineSpotHint}',
              icon: Icons.explore_outlined,
            );
          }
          return ListView.builder(
            itemCount: spots.length,
            itemBuilder: (_, i) {
              final s = spots[i];
              return ListTile(
                leading: const Icon(Icons.place_outlined),
                title: Text(s.name),
                subtitle: Text('${s.locationText} · ${s.radiusKm.toInt()} KM'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () =>
                      ref.read(spotRepositoryProvider).deleteSpot(s.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final spots = await ref
              .read(spotRepositoryProvider)
              .watchSpots(user.uid)
              .first;
          if (spots.length >= maxSpots) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Max $maxSpots spots for ${user.activeTier.name} plan',
                  ),
                ),
              );
            }
            return;
          }
          if (context.mounted) context.push('/spots/add');
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.addSpot),
      ),
    );
  }
}
