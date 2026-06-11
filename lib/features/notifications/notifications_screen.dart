import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/models/notification_item.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../l10n/app_localizations.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  String _groupLabel(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return l10n.today;
    }
    return DateFormat('dd MMM yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: StreamBuilder<List<NotificationItem>>(
        stream: ref.watch(notificationServiceProvider).watch(uid),
        builder: (context, snap) {
          final items = snap.data ?? [];
          if (items.isEmpty) return EmptyState(message: l10n.emptyNotifications);

          final grouped = <String, List<NotificationItem>>{};
          for (final n in items) {
            final key = _groupLabel(n.createdAt, l10n);
            grouped.putIfAbsent(key, () => []).add(n);
          }

          return ListView(
            children: grouped.entries.expand((e) {
              return [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    e.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                ...e.value.map((n) => _tile(context, ref, uid, n, l10n)),
              ];
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    WidgetRef ref,
    String uid,
    NotificationItem n,
    AppLocalizations l10n,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: n.read ? Colors.transparent : AppColors.primary,
          width: n.read ? 0 : 2,
        ),
      ),
      child: ListTile(
        title: Text(n.subject, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
            TextButton(
              onPressed: () async {
                await ref.read(notificationServiceProvider).markRead(uid, n.id);
                if (n.route.isNotEmpty && context.mounted) {
                  context.push(n.route);
                }
              },
              child: Text(l10n.readMore),
            ),
          ],
        ),
      ),
    );
  }
}
