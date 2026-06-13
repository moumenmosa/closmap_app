import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/app_user.dart';
import '../../core/models/job_application.dart';
import '../../core/models/job_post.dart';
import '../../core/models/view_request.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/job_card.dart';
import '../../l10n/app_localizations.dart';

class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.jobs)),
        body: const LoadingView(),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: Text(l10n.jobs)),
        body: EmptyState(message: l10n.errorGeneric),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.jobs)),
            body: EmptyState(message: l10n.errorGeneric),
          );
        }
        return _ApplicationsBody(
          l10n: l10n,
          user: user,
          tabs: _tabs,
          onRespond: _respond,
        );
      },
    );
  }

  Future<void> _respond(ViewRequest r, bool approve, AppLocalizations l10n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        message: approve ? l10n.confirmApprove : l10n.confirmReject,
      ),
    );
    if (ok != true) return;
    await ref.read(applicationRepositoryProvider).respondToViewRequest(
          r.id,
          approve ? ViewRequestStatus.approved : ViewRequestStatus.rejected,
        );
    if (approve) {
      await ref.read(notificationServiceProvider).send(
            userId: r.employerId,
            subject: l10n.contactUnlocked,
            body: l10n.contactUnlocked,
            route: r.jobId.isEmpty
                ? '/employer/headhunting'
                : '/employer/job/${r.jobId}/applicants',
          );
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve ? l10n.contactUnlocked : l10n.requestDeclined),
        ),
      );
    }
  }
}

class _ApplicationsBody extends ConsumerWidget {
  const _ApplicationsBody({
    required this.l10n,
    required this.user,
    required this.tabs,
    required this.onRespond,
  });

  final AppLocalizations l10n;
  final AppUser user;
  final TabController tabs;
  final Future<void> Function(ViewRequest, bool, AppLocalizations) onRespond;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = user.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.jobs),
        bottom: TabBar(
          controller: tabs,
          isScrollable: true,
          tabs: [
            Tab(text: l10n.applied),
            Tab(text: l10n.saved),
            Tab(text: l10n.matched),
            Tab(text: l10n.requests),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabs,
        children: [
          _appliedTab(context, ref, uid),
          _savedTab(context, ref, uid),
          _matchedTab(context, ref, uid),
          _requestsTab(context, ref, uid),
        ],
      ),
    );
  }

  Widget _unavailableJobTile() {
    return ListTile(
      leading: const Icon(Icons.work_off_outlined, color: Colors.grey),
      title: Text(l10n.jobExpired),
    );
  }

  Widget _jobCard({
    required WidgetRef ref,
    required String jobId,
    required Widget Function(JobPost job) builder,
  }) {
    return FutureBuilder<JobPost?>(
      future: ref.read(jobRepositoryProvider).getJob(jobId),
      builder: (context, jobSnap) {
        if (jobSnap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LoadingView(),
          );
        }
        final job = jobSnap.data;
        if (job == null) return _unavailableJobTile();
        return builder(job);
      },
    );
  }

  String _applicationStatusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return l10n.pending;
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.offered:
        return 'Offered';
      case ApplicationStatus.hired:
        return 'Hired';
      case ApplicationStatus.rejected:
        return l10n.rejected;
    }
  }

  Widget _appliedTab(BuildContext context, WidgetRef ref, String uid) {
    return StreamBuilder<List<JobApplication>>(
      stream: ref.watch(applicationRepositoryProvider).watchSeekerApplications(uid),
      builder: (context, snap) {
        if (snap.hasError) {
          return EmptyState(message: l10n.errorGeneric);
        }
        if (!snap.hasData) {
          return const LoadingView();
        }
        final apps = snap.data!;
        if (apps.isEmpty) return EmptyState(message: l10n.emptyApplied);
        return ListView.builder(
          itemCount: apps.length,
          itemBuilder: (_, i) {
            final app = apps[i];
            return Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => ref
                        .read(applicationRepositoryProvider)
                        .removeApplication(app.id),
                    icon: Icons.delete,
                    backgroundColor: Colors.red,
                  ),
                ],
              ),
              child: _jobCard(
                ref: ref,
                jobId: app.jobId,
                builder: (job) => JobCard(
                  job: job,
                  onTap: () => context.push('/job/${job.id}'),
                  trailing: StatusChip(status: _applicationStatusLabel(app.status)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _savedTab(BuildContext context, WidgetRef ref, String uid) {
    return StreamBuilder(
      stream: ref.watch(applicationRepositoryProvider).watchSavedJobs(uid),
      builder: (context, snap) {
        if (snap.hasError) {
          return EmptyState(message: l10n.errorGeneric);
        }
        if (!snap.hasData) {
          return const LoadingView();
        }
        final saved = snap.data!;
        if (saved.isEmpty) return EmptyState(message: l10n.emptySaved);
        return ListView.builder(
          itemCount: saved.length,
          itemBuilder: (_, i) {
            final s = saved[i];
            return Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => ref
                        .read(applicationRepositoryProvider)
                        .removeSaved(s.id),
                    icon: Icons.delete,
                    backgroundColor: Colors.red,
                  ),
                ],
              ),
              child: _jobCard(
                ref: ref,
                jobId: s.jobId,
                builder: (job) => JobCard(
                  job: job,
                  bookmarked: true,
                  onTap: () => context.push('/job/${job.id}'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _matchedTab(BuildContext context, WidgetRef ref, String uid) {
    return StreamBuilder(
      stream: ref.watch(applicationRepositoryProvider).watchMatchedJobs(uid),
      builder: (context, snap) {
        if (snap.hasError) {
          return EmptyState(message: l10n.errorGeneric);
        }
        if (!snap.hasData) {
          return const LoadingView();
        }
        final matched = snap.data!;
        if (matched.isEmpty) return EmptyState(message: l10n.emptyMatched);
        return ListView.builder(
          itemCount: matched.length,
          itemBuilder: (_, i) {
            final m = matched[i];
            return _jobCard(
              ref: ref,
              jobId: m.jobId,
              builder: (job) => JobCard(
                job: job,
                onTap: () => context.push('/job/${job.id}'),
                trailing: Chip(label: Text('${(m.score * 100).toInt()}%')),
              ),
            );
          },
        );
      },
    );
  }

  Widget _requestsTab(BuildContext context, WidgetRef ref, String uid) {
    return StreamBuilder<List<ViewRequest>>(
      stream: ref.watch(applicationRepositoryProvider).watchPendingRequests(uid),
      builder: (context, snap) {
        if (snap.hasError) {
          return EmptyState(message: l10n.errorGeneric);
        }
        if (!snap.hasData) {
          return const LoadingView();
        }
        final reqs = snap.data!;
        if (reqs.isEmpty) return EmptyState(message: l10n.emptyRequests);
        return ListView.builder(
          itemCount: reqs.length,
          itemBuilder: (_, i) {
            final r = reqs[i];
            return Card(
              margin: const EdgeInsets.all(12),
              child: ListTile(
                title: Text(r.companyName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  r.jobTitle.isNotEmpty ? r.jobTitle : l10n.headhunting,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/requests/${r.id}'),
              ),
            );
          },
        );
      },
    );
  }
}
