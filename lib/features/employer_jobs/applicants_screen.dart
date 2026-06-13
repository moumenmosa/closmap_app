import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/job_application.dart';
import '../../core/models/job_post.dart';
import '../../core/models/seeker_profile.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/profile_image.dart';
import '../../l10n/app_localizations.dart';
import 'seeker_preview_screen.dart';

class ApplicantsScreen extends ConsumerWidget {
  const ApplicantsScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final employerId = ref.watch(authStateProvider).valueOrNull?.uid;
    if (employerId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.applicants)),
        body: EmptyState(message: l10n.errorGeneric),
      );
    }

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.applicants),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.newApplicants),
              Tab(text: l10n.viewed),
              const Tab(text: 'Interview'),
              const Tab(text: 'Hired'),
              Tab(text: l10n.rejectedProfiles),
              Tab(text: l10n.matchingCandidates),
            ],
          ),
        ),
        body: FutureBuilder<JobPost?>(
          future: ref.read(jobRepositoryProvider).getJob(jobId),
          builder: (context, jobSnap) {
            final job = jobSnap.data;
            return StreamBuilder<List<JobApplication>>(
              stream: ref
                  .watch(applicationRepositoryProvider)
                  .watchJobApplications(jobId, employerId),
              builder: (context, snap) {
                if (snap.hasError) {
                  return EmptyState(message: l10n.errorGeneric);
                }
                if (!snap.hasData) {
                  return const LoadingView();
                }
                final apps = snap.data!;
                final pending = apps
                    .where((a) => a.status == ApplicationStatus.pending)
                    .toList();
                final shortlisted = apps
                    .where((a) => a.status == ApplicationStatus.shortlisted)
                    .toList();
                final interview = apps
                    .where((a) => a.status == ApplicationStatus.interview)
                    .toList();
                final offered = apps
                    .where((a) => a.status == ApplicationStatus.offered)
                    .toList();
                final hired = apps
                    .where((a) => a.status == ApplicationStatus.hired)
                    .toList();
                final rejected = apps
                    .where((a) => a.status == ApplicationStatus.rejected)
                    .toList();

                return TabBarView(
                  children: [
                    _list(context, pending, l10n),
                    _list(context, [...shortlisted, ...offered], l10n),
                    _list(context, interview, l10n),
                    _list(context, hired, l10n, showActions: false),
                    _list(context, rejected, l10n, showActions: false),
                    _matching(context, ref, l10n, job, employerId),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _list(
    BuildContext context,
    List<JobApplication> apps,
    AppLocalizations l10n, {
    bool showActions = true,
  }) {
    if (apps.isEmpty) return EmptyState(message: l10n.noResults);
    return ListView.builder(
      itemCount: apps.length,
      itemBuilder: (_, i) {
        final a = apps[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            backgroundImage: ProfileImage.provider(a.seekerPhotoUrl),
            child: a.seekerPhotoUrl.isEmpty
                ? const Icon(Icons.person_outline)
                : null,
          ),
          title: Text(a.seekerName),
          subtitle: Text(a.status.name),
          trailing: StatusChip(status: a.status.name),
          onTap: () => context.push(
            '/employer/job/$jobId/applicants/${a.id}',
          ),
        );
      },
    );
  }

  Widget _matching(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    JobPost? job,
    String employerId,
  ) {
    if (job == null) return EmptyState(message: l10n.noResults);
    return FutureBuilder<List<SeekerProfile>>(
      future: ref.read(userRepositoryProvider).getAllSeekerProfiles(),
      builder: (context, snap) {
        if (!snap.hasData) return const LoadingView();
        final matcher = ref.read(matchingServiceProvider);
        final appliedIds = <String>{};
        return StreamBuilder<List<JobApplication>>(
          stream: ref
              .watch(applicationRepositoryProvider)
              .watchJobApplications(jobId, employerId),
          builder: (context, appSnap) {
            for (final a in appSnap.data ?? []) {
              appliedIds.add(a.seekerId);
            }
            final scored = snap.data!
                .where((p) => !appliedIds.contains(p.uid))
                .map((p) => (profile: p, score: matcher.scoreJob(p, job)))
                .where((e) => e.score >= 0.25)
                .toList()
              ..sort((a, b) => b.score.compareTo(a.score));

            if (scored.isEmpty) {
              return EmptyState(message: l10n.matchingCandidates);
            }
            return ListView.builder(
              itemCount: scored.length,
              itemBuilder: (_, i) {
                final e = scored[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: ProfileImage.provider(e.profile.photoUrl),
                    child: e.profile.photoUrl.isEmpty
                        ? const Icon(Icons.person_outline)
                        : null,
                  ),
                  title: Text(e.profile.latestJobTitle),
                  subtitle:
                      Text('${l10n.matchingScore}: ${(e.score * 100).toInt()}%'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SeekerPreviewScreen(
                        seekerId: e.profile.uid,
                        job: job,
                        matchScore: e.score,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
