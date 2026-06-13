import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/leaderboard_entry.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  String _rankLabel(int rank, AppLocalizations l10n) {
    switch (rank) {
      case 1:
        return l10n.firstPlace;
      case 2:
        return l10n.secondPlace;
      case 3:
        return l10n.thirdPlace;
      default:
        return l10n.nthPlace(rank);
    }
  }

  Color _medalColor(int rank) {
    if (rank <= 3) return AppColors.gold;
    return AppColors.bronze;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: DesignAppBar(title: l10n.leaderBoard),
      body: StreamBuilder<List<LeaderboardEntry>>(
        stream: ref.watch(leaderboardRepositoryProvider).watchTopCompanies(),
        builder: (context, snap) {
          if (snap.hasError) {
            return EmptyState(message: l10n.errorGeneric);
          }
          if (!snap.hasData) {
            return const LoadingView();
          }
          final entries = snap.data!;
          if (entries.isEmpty) {
            return EmptyState(message: l10n.noResults);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(leaderboardRepositoryProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Text(
                      l10n.top10Companies,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Tooltip(
                      message:
                          'Ranked by active jobs, applicants, and hires.',
                      child: const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Score = active jobs × 10 + applicants × 5 + hires × 20',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                ...entries.map((entry) => _LeaderboardTile(
                      entry: entry,
                      rankLabel: _rankLabel(entry.rank, l10n),
                      medalColor: _medalColor(entry.rank),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.entry,
    required this.rankLabel,
    required this.medalColor,
  });

  final LeaderboardEntry entry;
  final String rankLabel;
  final Color medalColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.inputRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.surfaceMuted,
          backgroundImage: entry.logoUrl.isNotEmpty
              ? CachedNetworkImageProvider(entry.logoUrl)
              : null,
          child: entry.logoUrl.isEmpty
              ? const Icon(Icons.business, color: AppColors.textSecondary)
              : null,
        ),
        title: Text(
          entry.companyName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '$rankLabel · ${entry.score} pts',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: _MedalBadge(rank: entry.rank, color: medalColor),
      ),
    );
  }
}

class _MedalBadge extends StatelessWidget {
  const _MedalBadge({required this.rank, required this.color});

  final int rank;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = rank.toString().padLeft(2, '0');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.military_tech, color: color, size: 28),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
