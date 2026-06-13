import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/job_application.dart';
import '../../core/models/job_post.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/profile_image.dart';
import '../../l10n/app_localizations.dart';
import 'seeker_preview_screen.dart';

class ApplicationDetailScreen extends ConsumerStatefulWidget {
  const ApplicationDetailScreen({
    super.key,
    required this.applicationId,
    required this.jobId,
  });

  final String applicationId;
  final String jobId;

  @override
  ConsumerState<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends ConsumerState<ApplicationDetailScreen> {
  final _noteController = TextEditingController();
  bool _loading = false;
  bool _noteLoaded = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _loadNote(String note) {
    if (_noteLoaded) return;
    _noteController.text = note;
    _noteLoaded = true;
  }

  String _statusLabel(ApplicationStatus status, AppLocalizations l10n) {
    switch (status) {
      case ApplicationStatus.pending:
        return l10n.newApplicants;
      case ApplicationStatus.shortlisted:
        return l10n.viewed;
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.offered:
        return 'Offered';
      case ApplicationStatus.hired:
        return 'Hired';
      case ApplicationStatus.rejected:
        return l10n.rejectedProfiles;
    }
  }

  Future<void> _updateStatus(
    JobApplication app,
    ApplicationStatus status,
    AppLocalizations l10n,
  ) async {
    setState(() => _loading = true);
    try {
      await ref.read(applicationRepositoryProvider).updateApplicationStatus(
            app.id,
            status,
            interviewNote: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
      await ref.read(notificationServiceProvider).send(
            userId: app.seekerId,
            subject: l10n.applicants,
            body: '${app.jobTitle}: ${_statusLabel(status, l10n)}',
            route: '/applications?tab=applied',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_statusLabel(status, l10n))),
        );
        if (status == ApplicationStatus.hired ||
            status == ApplicationStatus.rejected) {
          context.pop();
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Widget> _actions(JobApplication app, AppLocalizations l10n) {
    switch (app.status) {
      case ApplicationStatus.pending:
        return [
          AppButton(
            label: l10n.viewed,
            loading: _loading,
            onPressed: () =>
                _updateStatus(app, ApplicationStatus.shortlisted, l10n),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _loading
                ? null
                : () => _updateStatus(app, ApplicationStatus.rejected, l10n),
            child: Text(l10n.reject),
          ),
        ];
      case ApplicationStatus.shortlisted:
        return [
          AppButton(
            label: 'Schedule interview',
            loading: _loading,
            onPressed: () =>
                _updateStatus(app, ApplicationStatus.interview, l10n),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _loading
                ? null
                : () => _updateStatus(app, ApplicationStatus.rejected, l10n),
            child: Text(l10n.reject),
          ),
        ];
      case ApplicationStatus.interview:
        return [
          AppButton(
            label: 'Mark offered',
            loading: _loading,
            onPressed: () => _updateStatus(app, ApplicationStatus.offered, l10n),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _loading
                ? null
                : () => _updateStatus(app, ApplicationStatus.rejected, l10n),
            child: Text(l10n.reject),
          ),
        ];
      case ApplicationStatus.offered:
        return [
          AppButton(
            label: 'Mark hired',
            loading: _loading,
            onPressed: () => _updateStatus(app, ApplicationStatus.hired, l10n),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _loading
                ? null
                : () => _updateStatus(app, ApplicationStatus.rejected, l10n),
            child: Text(l10n.reject),
          ),
        ];
      default:
        return [
          Text(
            _statusLabel(app.status, l10n),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.applicants)),
      body: FutureBuilder<JobApplication?>(
        future: ref
            .read(applicationRepositoryProvider)
            .getApplication(widget.applicationId),
        builder: (context, appSnap) {
          if (!appSnap.hasData) return const LoadingView();
          final app = appSnap.data;
          if (app == null) return EmptyState(message: l10n.noResults);

          return FutureBuilder<JobPost?>(
            future: ref.read(jobRepositoryProvider).getJob(widget.jobId),
            builder: (context, jobSnap) {
              final job = jobSnap.data;
              _loadNote(app.interviewNote);

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                          ProfileImage.provider(app.seekerPhotoUrl),
                      child: app.seekerPhotoUrl.isEmpty
                          ? const Icon(Icons.person_outline)
                          : null,
                    ),
                    title: Text(
                      app.seekerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(app.jobTitle),
                    trailing: StatusChip(status: app.status.name),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SeekerPreviewScreen(
                          seekerId: app.seekerId,
                          job: job,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Interview / offer notes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ..._actions(app, l10n),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
