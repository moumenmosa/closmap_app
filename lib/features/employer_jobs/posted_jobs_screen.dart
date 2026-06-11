import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/job_post.dart';
import '../../core/providers/providers.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
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
                    return JobCard(
                      job: job,
                      trailing: StatusChip(status: job.effectiveStatus.name),
                      onTap: () => context.push('/employer/job/${job.id}/applicants'),
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
        return jobs.where((j) => j.isExpired || j.effectiveStatus.name == 'expired').toList();
      case 'draft':
        return jobs.where((j) => j.isDraft).toList();
      default:
        return jobs;
    }
  }
}
