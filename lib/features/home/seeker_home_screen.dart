import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/config/app_config.dart';
import '../../core/models/employer_profile.dart';
import '../../core/models/job_post.dart';
import '../../core/models/seeker_profile.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/home_map_chrome.dart';
import '../../core/widgets/job_card.dart';
import '../../l10n/app_localizations.dart';
import '../shared/side_drawer.dart';
import 'job_title_filter_sheet.dart';

class SeekerHomeScreen extends ConsumerStatefulWidget {
  const SeekerHomeScreen({super.key});

  @override
  ConsumerState<SeekerHomeScreen> createState() => _SeekerHomeScreenState();
}

class _SeekerHomeScreenState extends ConsumerState<SeekerHomeScreen> {
  bool _listView = false;
  String _category = 'jobs';
  LatLng? _userLocation;
  final _mapController = MapController();
  Set<String> _selectedJobTitles = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStalePendingRequests();
      _initJobTitleFilter();
    });
  }

  void _initJobTitleFilter() {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      setState(() {
        _selectedJobTitles = JobTitleFilterSheet.initialFromUser(user.latestJobTitle);
      });
    }
  }

  Future<void> _checkStalePendingRequests() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null || !mounted) return;
    final prefs = ref.read(sharedPrefsProvider);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = 'pendingReminder_${user.uid}';
    if (prefs.getString(key) == today) return;

    final stale = await ref
        .read(applicationRepositoryProvider)
        .hasStalePendingRequests(user.uid);
    if (!stale || !mounted) return;

    await prefs.setString(key, today);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    await ref.read(notificationServiceProvider).send(
          userId: user.uid,
          subject: l10n.requests,
          body: l10n.pendingRequestReminder,
          route: '/applications?tab=requests',
        );
  }

  Future<void> _initLocation() async {
    try {
      final perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || !mounted) return;
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _userLocation = LatLng(pos.latitude, pos.longitude));
    } catch (_) {}
  }

  Future<void> _openJobTitleFilter() async {
    final picked = await JobTitleFilterSheet.show(
      context,
      selected: _selectedJobTitles,
    );
    if (picked == null) return;

    setState(() => _selectedJobTitles = picked);

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null || picked.isEmpty) return;
    final primary = picked.first;
    if (primary != user.latestJobTitle) {
      await ref.read(userRepositoryProvider).updateUser(user.uid, {
        'latestJobTitle': picked.join(', '),
      });
    }
  }

  Widget? _alertBanner(AppLocalizations l10n, dynamic user) {
    if (user.points <= AppConfig.lowPointsThreshold) {
      return MaterialBanner(
        content: Text(l10n.lowPointsWarning),
        actions: [
          TextButton(
            onPressed: () => context.push('/subscriptions'),
            child: Text(l10n.subscriptions),
          ),
        ],
      );
    }
    if (user.hasActiveSubscription && user.subscriptionExpiry != null) {
      final days = user.subscriptionExpiry!.difference(DateTime.now()).inDays;
      if (days <= AppConfig.expiryReminderDays && days >= 0) {
        return MaterialBanner(
          content: Text(l10n.subscriptionExpiring(days)),
          actions: [
            TextButton(
              onPressed: () => context.push('/plans'),
              child: Text(l10n.selectPlan),
            ),
          ],
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final titleFilters = _category == 'jobs' && _selectedJobTitles.isNotEmpty
        ? _selectedJobTitles.toList()
        : null;

    final jobsStream = ref.watch(jobRepositoryProvider).watchActiveJobs(
          titleFilters: titleFilters,
        );
    final employersStream =
        ref.watch(userRepositoryProvider).watchEmployersWithLocation();
    final seekersStream =
        ref.watch(userRepositoryProvider).watchSeekersWithLocation();
    final banner = _alertBanner(l10n, user);

    return Scaffold(
      drawer: SideDrawer(user: user),
      body: Builder(
        builder: (scaffoldContext) => Stack(
        children: [
          Positioned.fill(
            child: _category == 'jobs'
                ? StreamBuilder<List<JobPost>>(
                    stream: jobsStream,
                    builder: (context, snap) {
                      final jobs = snap.data ?? [];
                      if (_listView) {
                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 140, bottom: 140),
                          itemCount: jobs.length,
                          itemBuilder: (_, i) => JobCard(
                            job: jobs[i],
                            userLat: _userLocation?.latitude,
                            userLng: _userLocation?.longitude,
                            onTap: () => context.push('/job/${jobs[i].id}', extra: jobs[i]),
                          ),
                        );
                      }
                      return _jobMap(jobs);
                    },
                  )
                : _category == 'hq'
                    ? StreamBuilder<List<EmployerProfile>>(
                        stream: employersStream,
                        builder: (context, snap) {
                          final employers = snap.data ?? [];
                          if (_listView) {
                            return ListView.builder(
                              padding: const EdgeInsets.only(top: 140, bottom: 140),
                              itemCount: employers.length,
                              itemBuilder: (_, i) {
                                final e = employers[i];
                                return ListTile(
                                  leading: const Icon(Icons.business),
                                  title: Text(e.companyName),
                                  subtitle: Text(e.city),
                                  onTap: () => context.push('/company/${e.uid}'),
                                );
                              },
                            );
                          }
                          return _employerMap(employers);
                        },
                      )
                    : StreamBuilder<List<SeekerProfile>>(
                        stream: seekersStream,
                        builder: (context, snap) {
                          final seekers = (snap.data ?? [])
                              .where((s) => s.uid != user.uid)
                              .toList();
                          if (_listView) {
                            return ListView.builder(
                              padding: const EdgeInsets.only(top: 140, bottom: 140),
                              itemCount: seekers.length,
                              itemBuilder: (_, i) {
                                final s = seekers[i];
                                return ListTile(
                                  leading: const Icon(Icons.person_outline),
                                  title: Text(s.latestJobTitle),
                                  subtitle: Text(s.city),
                                );
                              },
                            );
                          }
                          return _peopleMap(seekers);
                        },
                      ),
          ),
          if (banner != null)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 48,
              left: 0,
              right: 0,
              child: banner,
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
                      StreamBuilder(
                        stream: ref
                            .watch(applicationRepositoryProvider)
                            .watchPendingRequests(user.uid),
                        builder: (context, snap) {
                          final count = snap.data?.length ?? 0;
                          return Badge(
                            isLabelVisible: count > 0,
                            label: Text('$count'),
                            child: IconButton(
                              icon: const Icon(Icons.work_history_outlined),
                              onPressed: () =>
                                  context.push('/applications?tab=requests'),
                            ),
                          );
                        },
                      ),
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
                          label: l10n.jobs,
                          selected: _category == 'jobs',
                          icon: Icons.work_outline,
                          onTap: () => setState(() => _category = 'jobs'),
                        ),
                        HomeCategoryChip(
                          label: l10n.headquarters,
                          selected: _category == 'hq',
                          icon: Icons.business_outlined,
                          onTap: () => setState(() => _category = 'hq'),
                        ),
                        HomeCategoryChip(
                          label: l10n.people,
                          selected: _category == 'people',
                          icon: Icons.people_outline,
                          onTap: () => setState(() => _category = 'people'),
                        ),
                        if (_category == 'jobs')
                          HomeCategoryChip(
                            label: _selectedJobTitles.isEmpty
                                ? l10n.jobTitle
                                : '${_selectedJobTitles.length} ${l10n.jobTitle}',
                            selected: _selectedJobTitles.isNotEmpty,
                            icon: Icons.filter_list,
                            onTap: _openJobTitleFilter,
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
    );
  }

  Widget _jobMap(List<JobPost> jobs) {
    final center = _userLocation ?? const LatLng(24.7136, 46.6753);
    final markers = jobs
        .where((j) => j.lat != null && j.lng != null)
        .map((j) => Marker(
              point: LatLng(j.lat!, j.lng!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => context.push('/job/${j.id}', extra: j),
                child: const Icon(Icons.work, color: AppColors.primaryAction),
              ),
            ))
        .toList();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: center, initialZoom: 11),
      children: [
        lightMapTileLayer(),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 60,
            size: const Size(40, 40),
            markers: markers,
            builder: (context, markers) => Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryAction,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${markers.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _employerMap(List<EmployerProfile> employers) {
    final center = _userLocation ?? const LatLng(24.7136, 46.6753);
    final markers = employers
        .map((e) => Marker(
              point: LatLng(e.lat!, e.lng!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => context.push('/company/${e.uid}'),
                child: const Icon(Icons.business, color: AppColors.secondary),
              ),
            ))
        .toList();

    return FlutterMap(
      options: MapOptions(initialCenter: center, initialZoom: 11),
      children: [
        lightMapTileLayer(),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _peopleMap(List<SeekerProfile> seekers) {
    final center = _userLocation ?? const LatLng(24.7136, 46.6753);
    final markers = seekers
        .where((s) => s.lat != null && s.lng != null)
        .map((s) => Marker(
              point: LatLng(s.lat!, s.lng!),
              width: 36,
              height: 36,
              child: const Icon(Icons.person_pin, color: AppColors.accent),
            ))
        .toList();

    return FlutterMap(
      options: MapOptions(initialCenter: center, initialZoom: 11),
      children: [
        lightMapTileLayer(),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
