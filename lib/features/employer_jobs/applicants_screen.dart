import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/job_application.dart';
import '../../core/models/job_post.dart';
import '../../core/models/seeker_profile.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/common_widgets.dart';
import '../../l10n/app_localizations.dart';
import 'seeker_preview_screen.dart';

class ApplicantsScreen extends ConsumerWidget {
  const ApplicantsScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider).valueOrNull;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.applicants),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.newApplicants),
              Tab(text: l10n.unlockedProfiles),
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
              stream: ref.watch(applicationRepositoryProvider).watchJobApplications(jobId),
              builder: (context, snap) {
                final apps = snap.data ?? [];
                final pending =
                    apps.where((a) => a.status == ApplicationStatus.pending).toList();
                final rejected =
                    apps.where((a) => a.status == ApplicationStatus.rejected).toList();

                return TabBarView(
                  children: [
                    _list(context, ref, pending, l10n, user, job),
                    _unlocked(context, ref, l10n, user),
                    _list(context, ref, rejected, l10n, user, job, showActions: false),
                    _matching(context, ref, l10n, job),
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
    WidgetRef ref,
    List<JobApplication> apps,
    AppLocalizations l10n,
    dynamic user,
    JobPost? job, {
    bool showActions = true,
  }) {
    if (apps.isEmpty) return EmptyState(message: l10n.noResults);
    return ListView.builder(
      itemCount: apps.length,
      itemBuilder: (_, i) {
        final a = apps[i];
        return ListTile(
          title: Text(a.seekerName),
          subtitle: Text(a.status.name),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SeekerPreviewScreen(
                seekerId: a.seekerId,
                job: job,
              ),
            ),
          ),
          trailing: showActions
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _updateStatus(
                        context,
                        ref,
                        a,
                        ApplicationStatus.viewed,
                        l10n,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _updateStatus(
                        context,
                        ref,
                        a,
                        ApplicationStatus.rejected,
                        l10n,
                      ),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    JobApplication app,
    ApplicationStatus status,
    AppLocalizations l10n,
  ) async {
    await ref
        .read(applicationRepositoryProvider)
        .updateApplicationStatus(app.id, status);
    await ref.read(notificationServiceProvider).send(
          userId: app.seekerId,
          subject: l10n.applicants,
          body: '${app.jobTitle}: ${status.name}',
          route: '/applications',
        );
  }

  Widget _unlocked(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    dynamic user,
  ) {
    if (user == null) return const SizedBox.shrink();
    return StreamBuilder(
      stream: ref
          .watch(applicationRepositoryProvider)
          .watchApprovedViewRequests(user.uid, jobId: jobId),
      builder: (context, snap) {
        final reqs = snap.data ?? [];
        if (reqs.isEmpty) return EmptyState(message: l10n.unlockedProfiles);
        return ListView.builder(
          itemCount: reqs.length,
          itemBuilder: (_, i) {
            final r = reqs[i];
            return FutureBuilder<SeekerProfile?>(
              future: ref.read(userRepositoryProvider).getSeekerProfile(r.seekerId),
              builder: (context, pSnap) {
                final name = pSnap.data?.latestJobTitle ?? r.seekerId;
                return ListTile(
                  title: Text(name),
                  subtitle: Text(r.jobTitle.isEmpty ? l10n.headhunting : r.jobTitle),
                  trailing: const Icon(Icons.lock_open, color: Colors.green),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SeekerPreviewScreen(
                        seekerId: r.seekerId,
                        job: null,
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

  Widget _matching(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    JobPost? job,
  ) {
    if (job == null) return EmptyState(message: l10n.noResults);
    return FutureBuilder<List<SeekerProfile>>(
      future: ref.read(userRepositoryProvider).getAllSeekerProfiles(),
      builder: (context, snap) {
        if (!snap.hasData) return const LoadingView();
        final matcher = ref.read(matchingServiceProvider);
        final appliedIds = <String>{};
        return StreamBuilder<List<JobApplication>>(
          stream: ref.watch(applicationRepositoryProvider).watchJobApplications(jobId),
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
                  title: Text(e.profile.latestJobTitle),
                  subtitle: Text('${l10n.matchingScore}: ${(e.score * 100).toInt()}%'),
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
