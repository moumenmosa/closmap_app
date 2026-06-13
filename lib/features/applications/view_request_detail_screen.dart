import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/view_request.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/common_widgets.dart';
import '../../l10n/app_localizations.dart';

class ViewRequestDetailScreen extends ConsumerStatefulWidget {
  const ViewRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<ViewRequestDetailScreen> createState() =>
      _ViewRequestDetailScreenState();
}

class _ViewRequestDetailScreenState extends ConsumerState<ViewRequestDetailScreen> {
  bool _loading = false;
  ViewRequest? _request;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await ref
        .read(applicationRepositoryProvider)
        .getViewRequest(widget.requestId);
    if (mounted) setState(() => _request = r);
  }

  Future<void> _respond(bool approve, AppLocalizations l10n) async {
    final r = _request;
    if (r == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        message: approve ? l10n.confirmApprove : l10n.confirmReject,
      ),
    );
    if (ok != true) return;

    setState(() => _loading = true);
    try {
      await ref.read(applicationRepositoryProvider).respondToViewRequest(
            r.id,
            approve ? ViewRequestStatus.approved : ViewRequestStatus.rejected,
          );
      if (approve) {
        await ref.read(notificationServiceProvider).send(
              userId: r.employerId,
              subject: l10n.contactUnlocked,
              body: l10n.contactUnlocked,
              route: '/employer/headhunting',
            );
      }
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? l10n.contactUnlocked : l10n.requestDeclined),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final r = _request;
    if (r == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.requests)),
        body: const LoadingView(),
      );
    }

    final approved = r.status == ViewRequestStatus.approved;
    final pending = r.status == ViewRequestStatus.pending;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.requests)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            r.companyName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            r.jobTitle.isNotEmpty ? r.jobTitle : l10n.headhunting,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          StatusChip(status: r.status.name),
          const SizedBox(height: 24),
          if (pending) ...[
            Text(l10n.requests),
            const SizedBox(height: 16),
            AppButton(
              label: l10n.approve,
              loading: _loading,
              onPressed: () => _respond(true, l10n),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loading ? null : () => _respond(false, l10n),
              child: Text(l10n.reject),
            ),
          ],
          if (approved) ...[
            Text(
              l10n.contactUnlocked,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder(
              future: ref.read(userRepositoryProvider).getUser(r.employerId),
              builder: (context, userSnap) {
                final user = userSnap.data;
                if (user == null) return const LoadingView();
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(user.email),
                      onTap: () => launchUrl(Uri.parse('mailto:${user.email}')),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(user.phone),
                      onTap: () => launchUrl(Uri.parse('tel:${user.phone}')),
                    ),
                  ],
                );
              },
            ),
          ],
          if (r.status == ViewRequestStatus.rejected)
            EmptyState(message: l10n.requestDeclined),
        ],
      ),
    );
  }
}
