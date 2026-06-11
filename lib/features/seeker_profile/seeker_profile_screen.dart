import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/seeker_profile.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';

class SeekerProfileScreen extends ConsumerWidget {
  const SeekerProfileScreen({super.key});

  static String _totalExperience(List<ExperienceEntry> exp) {
    var months = 0;
    for (final e in exp) {
      final start = e.startDate ?? DateTime.now();
      final end = e.ongoing ? DateTime.now() : (e.endDate ?? start);
      months += (end.year - start.year) * 12 + end.month - start.month;
    }
    final y = months ~/ 12;
    final m = months % 12;
    return '${y}Y - ${m}M';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder(
      stream: ref.watch(userRepositoryProvider).watchSeekerProfile(uid),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: LoadingView());
        }
        final p = snap.data;
        if (p == null) {
          return Scaffold(
            appBar: DesignAppBar(title: l10n.profile, showBack: true),
            body: EmptyState(message: l10n.profile),
          );
        }

        final totalExp = _totalExperience(p.experience);

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DesignGradientHeader(
                  height: 160,
                  imageUrl: p.photoUrl.isNotEmpty ? p.photoUrl : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => context.push(
                            '/seeker/profile-wizard?edit=1',
                            extra: p,
                          ),
                          icon: const Icon(Icons.edit_outlined,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -40),
                  child: Center(
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.surface,
                      backgroundImage: p.photoUrl.isNotEmpty
                          ? CachedNetworkImageProvider(p.photoUrl)
                          : null,
                      child: p.photoUrl.isEmpty
                          ? const Icon(Icons.person, size: 48)
                          : null,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Text(
                      user?.displayName ?? '',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      p.latestJobTitle,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.experience}: $totalExp',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    DesignSectionCard(
                      title: l10n.personalInfo,
                      onEdit: () => context.push(
                        '/seeker/profile-wizard?edit=1',
                        extra: p,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _row(l10n.dateOfBirth, Formatters.date(p.dateOfBirth)),
                          _row(l10n.gender, p.gender),
                          _row(l10n.maritalStatus, p.maritalStatus),
                          _row(l10n.nationality, p.nationality),
                          _row(l10n.countryOfResidence, p.countryOfResidence),
                          const Divider(),
                          _verifiedRow(l10n.email, user?.email ?? '', true),
                          _verifiedRow(
                            l10n.phone,
                            user?.phone ?? '',
                            (user?.phone.isNotEmpty ?? false) && user!.emailVerified,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    DesignSectionCard(
                      title: l10n.education,
                      onEdit: () => context.push(
                        '/seeker/profile-wizard?edit=1',
                        extra: p,
                      ),
                      child: Column(
                        children: p.education.map((e) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('${e.level} - ${e.field}'),
                            subtitle: Text(
                              '${Formatters.date(e.startDate)} - ${Formatters.date(e.endDate)}',
                            ),
                            trailing: Chip(
                              label: Text(e.level.toUpperCase()),
                              backgroundColor:
                                  AppColors.primaryAction.withValues(alpha: 0.1),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DesignSectionCard(
                      title: l10n.experience,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${l10n.experience}: $totalExp',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          ...p.experience.map((e) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      margin: const EdgeInsets.only(top: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primaryAction,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(e.jobTitle,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          Chip(label: Text(e.employmentType)),
                                          Text(e.companyName),
                                          Text(
                                            '${Formatters.date(e.startDate)} - ${e.ongoing ? l10n.ongoing : Formatters.date(e.endDate)}',
                                            style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    DesignSectionCard(
                      title: l10n.skills,
                      child: Column(
                        children: p.skills
                            .map((s) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(s.name),
                                  subtitle: Text(s.source),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DesignSectionCard(
                      title: l10n.languages,
                      child: Column(
                        children: p.languages
                            .map((l) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(l.language),
                                  subtitle: Text(l.proficiency),
                                ))
                            .toList(),
                      ),
                    ),
                    if (p.resumeUrl.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      DesignSectionCard(
                        title: l10n.resume,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.picture_as_pdf,
                              color: AppColors.error),
                          title: Text(
                              p.resumeName.isEmpty ? l10n.resume : p.resumeName),
                          subtitle: p.resumeSizeBytes > 0
                              ? Text('${(p.resumeSizeBytes / 1024).round()} KB')
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.download_outlined),
                            onPressed: () => launchUrl(Uri.parse(p.resumeUrl)),
                          ),
                        ),
                      ),
                    ],
                    if (p.linkedInUrl.isNotEmpty || p.otherLinks.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      DesignSectionCard(
                        title: 'Links',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (p.linkedInUrl.isNotEmpty)
                              _linkTile('LinkedIn', p.linkedInUrl),
                            ...p.otherLinks.map((l) => _linkTile('Website', l)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Joining Date: ${Formatters.monthYear(user?.createdAt)}',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  Widget _verifiedRow(String label, String value, bool verified) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value)),
          if (verified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Verified',
                style: TextStyle(color: AppColors.success, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _linkTile(String title, String url) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(url, style: const TextStyle(color: AppColors.primary)),
      onTap: () => launchUrl(Uri.parse(url)),
    );
  }
}
