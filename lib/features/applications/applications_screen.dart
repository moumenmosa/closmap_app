import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
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
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.jobs),
        bottom: TabBar(
          controller: _tabs,
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
        controller: _tabs,
        children: [
          _appliedTab(uid, l10n),
          _savedTab(uid, l10n),
          _matchedTab(uid, l10n),
          _requestsTab(uid, l10n),
        ],
      ),
    );
  }

  Widget _appliedTab(String uid, AppLocalizations l10n) {
    return StreamBuilder<List<JobApplication>>(
      stream: ref.watch(applicationRepositoryProvider).watchSeekerApplications(uid),
      builder: (context, snap) {
        final apps = snap.data ?? [];
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
              child: FutureBuilder<JobPost?>(
                future: ref.read(jobRepositoryProvider).getJob(app.jobId),
                builder: (context, jobSnap) {
                  final job = jobSnap.data;
                  if (job == null) return const SizedBox.shrink();
                  return JobCard(
                    job: job,
                    onTap: () => context.push('/job/${job.id}'),
                    trailing: StatusChip(status: app.status.name),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _savedTab(String uid, AppLocalizations l10n) {
    return StreamBuilder(
      stream: ref.watch(applicationRepositoryProvider).watchSavedJobs(uid),
      builder: (context, snap) {
        final saved = snap.data ?? [];
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
              child: FutureBuilder<JobPost?>(
                future: ref.read(jobRepositoryProvider).getJob(s.jobId),
                builder: (context, jobSnap) {
                  final job = jobSnap.data;
                  if (job == null) return const SizedBox.shrink();
                  return JobCard(
                    job: job,
                    bookmarked: true,
                    onTap: () => context.push('/job/${job.id}'),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _matchedTab(String uid, AppLocalizations l10n) {
    return StreamBuilder(
      stream: ref.watch(applicationRepositoryProvider).watchMatchedJobs(uid),
      builder: (context, snap) {
        final matched = snap.data ?? [];
        if (matched.isEmpty) return EmptyState(message: l10n.emptyMatched);
        return ListView.builder(
          itemCount: matched.length,
          itemBuilder: (_, i) {
            final m = matched[i];
            return FutureBuilder<JobPost?>(
              future: ref.read(jobRepositoryProvider).getJob(m.jobId),
              builder: (context, jobSnap) {
                final job = jobSnap.data;
                if (job == null) return const SizedBox.shrink();
                return JobCard(
                  job: job,
                  onTap: () => context.push('/job/${job.id}'),
                  trailing: Chip(label: Text('${(m.score * 100).toInt()}%')),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _requestsTab(String uid, AppLocalizations l10n) {
    return StreamBuilder<List<ViewRequest>>(
      stream: ref.watch(applicationRepositoryProvider).watchPendingRequests(uid),
      builder: (context, snap) {
        final reqs = snap.data ?? [];
        if (reqs.isEmpty) return EmptyState(message: l10n.emptyRequests);
        return ListView.builder(
          itemCount: reqs.length,
          itemBuilder: (_, i) {
            final r = reqs[i];
            return Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.companyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (r.jobTitle.isNotEmpty) Text(r.jobTitle),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: () => _respond(r, true, l10n),
                            child: Text(l10n.approve),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            onPressed: () => _respond(r, false, l10n),
                            child: Text(l10n.reject),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
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
