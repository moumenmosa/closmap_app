import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/job_post.dart';
import '../../core/models/seeker_profile.dart';
import '../../core/models/view_request.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/common_widgets.dart';
import '../../l10n/app_localizations.dart';

class SeekerPreviewScreen extends ConsumerStatefulWidget {
  const SeekerPreviewScreen({
    super.key,
    required this.seekerId,
    this.job,
    this.matchScore,
  });

  final String seekerId;
  final JobPost? job;
  final double? matchScore;

  @override
  ConsumerState<SeekerPreviewScreen> createState() =>
      _SeekerPreviewScreenState();
}

class _SeekerPreviewScreenState extends ConsumerState<SeekerPreviewScreen> {
  bool _loading = false;
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    _checkUnlock();
  }

  Future<void> _checkUnlock() async {
    final employer = ref.read(currentUserProvider).valueOrNull;
    if (employer == null) return;
    final ok = await ref
        .read(applicationRepositoryProvider)
        .hasApprovedViewRequest(employer.uid, widget.seekerId);
    if (mounted) setState(() => _unlocked = ok);
  }

  Future<void> _requestView(SeekerProfile profile, AppLocalizations l10n) async {
    final employer = ref.read(currentUserProvider).valueOrNull;
    if (employer == null) return;
    setState(() => _loading = true);
    try {
      final can = await ref
          .read(applicationRepositoryProvider)
          .canSendViewRequest(employer.uid, widget.seekerId);
      if (!can) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileUpdateLimit)),
        );
        return;
      }
      final job = widget.job;
      await ref.read(applicationRepositoryProvider).sendViewRequest(
            ViewRequest(
              id: '',
              employerId: employer.uid,
              seekerId: widget.seekerId,
              companyName: employer.companyName,
              jobId: job?.id ?? '',
              jobTitle: job?.title ?? l10n.headhunting,
              createdAt: DateTime.now(),
            ),
          );
      await ref.read(notificationServiceProvider).send(
            userId: widget.seekerId,
            subject: l10n.requests,
            body: '${employer.companyName} ${l10n.requests}',
            route: '/applications',
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('View request sent')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileStream =
        ref.watch(userRepositoryProvider).watchSeekerProfile(widget.seekerId);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: StreamBuilder<SeekerProfile?>(
        stream: profileStream,
        builder: (context, snap) {
          if (!snap.hasData) return const LoadingView();
          final profile = snap.data;
          if (profile == null) return EmptyState(message: l10n.noResults);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.matchScore != null)
                Chip(
                  label: Text(
                    '${l10n.matchingScore}: ${(widget.matchScore! * 100).toInt()}%',
                  ),
                ),
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage:
                      profile.photoUrl.isNotEmpty ? NetworkImage(profile.photoUrl) : null,
                  child: profile.photoUrl.isEmpty
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                profile.latestJobTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${profile.city}, ${profile.countryOfResidence}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _section(l10n.skills, profile.skills.map((s) => s.name).toList()),
              _section(l10n.languages, profile.languages.map((l) => l.language).toList()),
              if (_unlocked) ...[
                const Divider(),
                Text(l10n.unlockedProfiles, style: const TextStyle(fontWeight: FontWeight.bold)),
                FutureBuilder(
                  future: ref.read(userRepositoryProvider).getUser(widget.seekerId),
                  builder: (context, userSnap) {
                    final user = userSnap.data;
                    if (user == null) return const SizedBox.shrink();
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: Text(user.email),
                        ),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: Text(user.phone),
                        ),
                        if (profile.resumeUrl.isNotEmpty)
                          ListTile(
                            leading: const Icon(Icons.picture_as_pdf),
                            title: Text(profile.resumeName),
                            onTap: () => launchUrl(Uri.parse(profile.resumeUrl)),
                          ),
                      ],
                    );
                  },
                ),
              ] else
                AppButton(
                  label: l10n.requests,
                  loading: _loading,
                  onPressed: () => _requestView(profile, l10n),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _section(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...items.map((e) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('• $e'),
            )),
        const SizedBox(height: 12),
      ],
    );
  }
}
