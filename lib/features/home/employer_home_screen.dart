import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/models/job_post.dart';
import '../../core/models/seeker_profile.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/home_map_chrome.dart';
import '../../core/widgets/profile_image.dart';
import '../../l10n/app_localizations.dart';
import '../employer_jobs/seeker_preview_screen.dart';
import '../shared/side_drawer.dart';

class EmployerHomeScreen extends ConsumerStatefulWidget {
  const EmployerHomeScreen({super.key});

  @override
  ConsumerState<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends ConsumerState<EmployerHomeScreen> {
  bool _listView = false;
  String _category = 'jobs';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final jobsStream = ref.watch(jobRepositoryProvider).watchEmployerJobs(user.uid);
    final seekersStream =
        ref.watch(userRepositoryProvider).watchSeekersWithLocation();

    return Scaffold(
      drawer: SideDrawer(user: user),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/employer/job/add'),
        backgroundColor: AppColors.primaryAction,
        icon: const Icon(Icons.add),
        label: Text(l10n.addJobPost),
      ),
      body: Builder(
        builder: (scaffoldContext) => Stack(
          children: [
            Positioned.fill(
              child: StreamBuilder<List<JobPost>>(
                stream: jobsStream,
                builder: (context, jobSnap) {
                  final jobs = jobSnap.data ?? [];
                  if (_category == 'people') {
                    return StreamBuilder<List<SeekerProfile>>(
                      stream: seekersStream,
                      builder: (context, seekerSnap) {
                        final seekers = seekerSnap.data ?? [];
                        if (_listView) {
                          return _seekersList(seekers);
                        }
                        return _mapView(jobs, seekers);
                      },
                    );
                  }
                  if (_listView) {
                    return _jobsDashboard(l10n, jobs);
                  }
                  return StreamBuilder<List<SeekerProfile>>(
                    stream: seekersStream,
                    builder: (context, seekerSnap) =>
                        _mapView(jobs, seekerSnap.data ?? []),
                  );
                },
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeTopBar(
                      onMenu: () => Scaffold.of(scaffoldContext).openDrawer(),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () => context.push('/notifications'),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Row(
                        children: [
                          HomeCategoryChip(
                            label: l10n.jobPosts,
                            selected: _category == 'jobs',
                            icon: Icons.work_outline,
                            onTap: () => setState(() => _category = 'jobs'),
                          ),
                          HomeCategoryChip(
                            label: l10n.people,
                            selected: _category == 'people',
                            icon: Icons.people_outline,
                            onTap: () => setState(() => _category = 'people'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HomeBottomSearchBar(
                      hint: l10n.searchHint,
                      onTap: () => context.push('/search'),
                    ),
                    HomeViewToggle(
                      listView: _listView,
                      mapLabel: l10n.mapView,
                      listLabel: l10n.listView,
                      onChanged: (v) => setState(() => _listView = v),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), label: l10n.home),
          NavigationDestination(icon: const Icon(Icons.work_outline), label: l10n.jobPosts),
        ],
        onDestinationSelected: (i) {
          if (i == 1) context.push('/employer/jobs');
        },
      ),
    );
  }

  Widget _jobsDashboard(AppLocalizations l10n, List<JobPost> jobs) {
    final totalApplicants =
        jobs.fold<int>(0, (s, j) => s + j.applicantsCount);
    final user = ref.watch(currentUserProvider).valueOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 140, 16, 140),
      children: [
        Text(l10n.dashboard, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _statCard(l10n.totalJobPosts, '${jobs.length}', AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                l10n.totalApplicants,
                '$totalApplicants',
                AppColors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _statCard(l10n.points, '${user?.points ?? 0}', AppColors.gold),
      ],
    );
  }

  Widget _seekersList(List<SeekerProfile> seekers) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 140, 0, 140),
      itemCount: seekers.length,
      itemBuilder: (_, i) {
        final s = seekers[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            backgroundImage: ProfileImage.provider(s.photoUrl),
            child: s.photoUrl.isEmpty
                ? const Icon(Icons.person_outline)
                : null,
          ),
          title: Text(s.latestJobTitle),
          subtitle: Text(s.city),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SeekerPreviewScreen(seekerId: s.uid),
            ),
          ),
        );
      },
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapView(List<JobPost> jobs, List<SeekerProfile> seekers) {
    final jobMarkers = jobs
        .where((j) => j.lat != null && j.lng != null)
        .map((j) => Marker(
              point: LatLng(j.lat!, j.lng!),
              width: 40,
              height: 40,
              child: const Icon(Icons.business, color: AppColors.orange),
            ));
    final peopleMarkers = seekers
        .where((s) => s.lat != null && s.lng != null)
        .map((s) => Marker(
              point: LatLng(s.lat!, s.lng!),
              width: 36,
              height: 36,
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SeekerPreviewScreen(seekerId: s.uid),
                  ),
                ),
                child: const Icon(Icons.person_pin, color: AppColors.accent),
              ),
            ));
    final markers = [...jobMarkers, ...peopleMarkers];
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(24.7136, 46.6753),
        initialZoom: 10,
      ),
      children: [
        lightMapTileLayer(),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
