import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/app_user.dart';
import '../../core/models/job_post.dart';
import '../../core/providers/providers.dart';
import '../../core/services/job_publish_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/job_card.dart';
import '../../l10n/app_localizations.dart';

class PostedJobsScreen extends ConsumerStatefulWidget {
  const PostedJobsScreen({super.key});

  @override
  ConsumerState<PostedJobsScreen> createState() => _PostedJobsScreenState();
}

class _PostedJobsScreenState extends ConsumerState<PostedJobsScreen> {
  String _filter = 'all';
  String? _publishingId;

  Future<void> _publishDraft(JobPost job, AppUser user, AppLocalizations l10n) async {
    setState(() => _publishingId = job.id);
    try {
      final result = await publishJobWithSubscription(
        ref,
        job: job,
        validityDays: job.validityDays > 0 ? job.validityDays : 7,
        user: user,
      );
      if (!mounted) return;
      if (!result.success) {
        final msg = switch (result.errorMessage) {
          'no_subscription' => l10n.noSubscription,
          'insufficient_points' => l10n.insufficientPoints,
          _ => result.errorMessage ?? l10n.errorGeneric,
        };
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${job.title} ${l10n.active.toLowerCase()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _publishingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final uid = user?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.jobPosts)),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _chip(l10n.all, 'all'),
                _chip(l10n.active, 'active'),
                _chip(l10n.expired, 'expired'),
                _chip(l10n.draft, 'draft'),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<JobPost>>(
              stream: ref.watch(jobRepositoryProvider).watchEmployerJobs(uid),
              builder: (context, snap) {
                var jobs = snap.data ?? [];
                jobs = _filterJobs(jobs);
                if (jobs.isEmpty) return EmptyState(message: l10n.noResults);
                return ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (_, i) {
                    final job = jobs[i];
                    final isDraft = job.isDraft;
                    final publishing = _publishingId == job.id;
                    return Column(
                      children: [
                        JobCard(
                          job: job,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (job.isActive && job.applicantsCount > 0)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryAction
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${job.applicantsCount}',
                                    style: const TextStyle(
                                      color: AppColors.primaryAction,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              StatusChip(status: job.effectiveStatus.name),
                            ],
                          ),
                          onTap: () {
                            if (isDraft) {
                              context.push('/employer/job/add?id=${job.id}');
                            } else {
                              context.push('/employer/job/${job.id}/applicants');
                            }
                          },
                        ),
                        if (isDraft)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: publishing
                                    ? null
                                    : () => _publishDraft(job, user!, l10n),
                                child: publishing
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(l10n.publish),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/employer/job/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _chip(String label, String id) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _filter == id,
        onSelected: (_) => setState(() => _filter = id),
      ),
    );
  }

  List<JobPost> _filterJobs(List<JobPost> jobs) {
    switch (_filter) {
      case 'active':
        return jobs.where((j) => j.isActive).toList();
      case 'expired':
        return jobs
            .where((j) => j.isExpired || j.effectiveStatus.name == 'expired')
            .toList();
      case 'draft':
        return jobs.where((j) => j.isDraft).toList();
      default:
        return jobs;
    }
  }
}
