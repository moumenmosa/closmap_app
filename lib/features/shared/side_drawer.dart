import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/app_user.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/profile_image.dart';
import '../../l10n/app_localizations.dart';

class SideDrawer extends ConsumerWidget {
  const SideDrawer({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user.displayName),
              accountEmail: Text(user.email),
              currentAccountPicture: _DrawerAvatar(user: user, ref: ref),
            ),
            if (!user.isAdmin)
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(l10n.profile),
                onTap: () {
                  Navigator.pop(context);
                  context.push(user.role == UserRole.employer
                      ? '/employer/profile'
                      : '/seeker/profile');
                },
              ),
            if (user.role == UserRole.seeker)
              ListTile(
                leading: const Icon(Icons.work_history_outlined),
                title: Text(l10n.applied),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/applications?tab=applied');
                },
              ),
            if (user.role == UserRole.seeker)
              ListTile(
                leading: const Icon(Icons.explore_outlined),
                title: Text(l10n.exploringSpots),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/spots');
                },
              ),
            if (user.role == UserRole.employer)
              ListTile(
                leading: const Icon(Icons.work_outline),
                title: Text(l10n.jobPosts),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/employer/jobs');
                },
              ),
            if (user.role == UserRole.employer)
              ListTile(
                leading: const Icon(Icons.person_search_outlined),
                title: Text(l10n.headhunting),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/employer/headhunting');
                },
              ),
            ListTile(
              leading: const Icon(Icons.card_membership_outlined),
              title: Text(l10n.subscriptions),
              onTap: () {
                Navigator.pop(context);
                context.push('/subscriptions');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: Text(l10n.notifications),
              onTap: () {
                Navigator.pop(context);
                context.push('/notifications');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.settings),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard_outlined),
              title: Text(l10n.leaderBoard),
              onTap: () {
                Navigator.pop(context);
                context.push('/leaderboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.aboutApp),
              onTap: () {
                Navigator.pop(context);
                context.push('/about');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.logout),
              onTap: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerAvatar extends StatelessWidget {
  const _DrawerAvatar({required this.user, required this.ref});

  final AppUser user;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    if (user.role == UserRole.seeker) {
      return StreamBuilder(
        stream: ref.watch(userRepositoryProvider).watchSeekerProfile(user.uid),
        builder: (context, snap) {
          final photoUrl = snap.data?.photoUrl ?? '';
          return CircleAvatar(
            backgroundImage: ProfileImage.provider(photoUrl),
            child: photoUrl.isEmpty ? const Icon(Icons.person) : null,
          );
        },
      );
    }
    if (user.role == UserRole.employer) {
      return StreamBuilder(
        stream:
            ref.watch(userRepositoryProvider).watchEmployerProfile(user.uid),
        builder: (context, snap) {
          final logoUrl = snap.data?.logoUrl ?? '';
          return CircleAvatar(
            backgroundImage: ProfileImage.provider(logoUrl),
            child: logoUrl.isEmpty ? const Icon(Icons.business) : null,
          );
        },
      );
    }
    return const CircleAvatar(child: Icon(Icons.person));
  }
}
