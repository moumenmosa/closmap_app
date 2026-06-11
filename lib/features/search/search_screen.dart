import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/lookups.dart';
import '../../core/models/job_post.dart';
import '../../core/models/job_search_filters.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/design/design_app_bar.dart';
import '../../core/widgets/home_map_chrome.dart';
import '../../core/widgets/job_card.dart';
import '../../l10n/app_localizations.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _query = TextEditingController();
  JobSearchFilters _filters = JobSearchFilters.empty;
  List<JobPost> _results = [];
  bool _loading = false;
  bool _searched = false;
  bool _mapView = false;
  double? _userLat;
  double? _userLng;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied) return;
    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _userLat = pos.latitude;
      _userLng = pos.longitude;
      _filters = _filters.copyWith(lat: pos.latitude, lng: pos.longitude);
    });
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _searched = true;
    });
    final keyword = _query.text.trim();
    final jobs = await ref.read(jobRepositoryProvider).searchJobs(
          keyword: keyword,
          lat: _userLat,
          lng: _userLng,
          filters: _filters.copyWith(keyword: keyword),
        );
    setState(() {
      _results = jobs;
      _loading = false;
    });
  }

  void _clear() {
    _query.clear();
    setState(() {
      _filters = JobSearchFilters.empty.copyWith(lat: _userLat, lng: _userLng);
      _results = [];
      _searched = false;
    });
  }

  Future<void> _openFilters() async {
    final result = await context.push<JobSearchFilters>(
      '/filter',
      extra: _filters.copyWith(
        keyword: _query.text,
        lat: _userLat,
        lng: _userLng,
      ),
    );
    if (result != null) {
      setState(() => _filters = result);
      await _search();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: DesignAppBar(
        title: l10n.search,
        actionLabel: _searched ? l10n.clear : null,
        actionColor: AppColors.accent,
        onAction: _searched ? _clear : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _query,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Badge(
                            isLabelVisible: _filters.hasActiveFilters,
                            child: const Icon(Icons.tune),
                          ),
                          onPressed: _openFilters,
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _search,
                        ),
                      ],
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onSubmitted: (_) => _search(),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: Lookups.searchSuggestions.map((s) {
                    return ActionChip(
                      label: Text(s),
                      onPressed: () {
                        _query.text = s;
                        _search();
                      },
                    );
                  }).toList(),
                ),
                if (_filters.hasActiveFilters) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _filters.jobTitlesLabel.isNotEmpty
                          ? _filters.jobTitlesLabel
                          : l10n.filters,
                      style: const TextStyle(
                        color: AppColors.primaryAction,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_searched && _results.isNotEmpty)
            HomeViewToggle(
              listView: _mapView,
              mapLabel: l10n.mapView,
              listLabel: l10n.listView,
              onChanged: (v) => setState(() => _mapView = v),
            ),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _results.isEmpty && _searched
                    ? EmptyState(message: l10n.noResults)
                    : _mapView
                        ? _resultsMap()
                        : ListView.builder(
                            itemCount: _results.length,
                            itemBuilder: (_, i) {
                              final job = _results[i];
                              return JobCard(
                                job: job,
                                userLat: _userLat,
                                userLng: _userLng,
                                onTap: () => context.push('/job/${job.id}'),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _resultsMap() {
    final center = LatLng(_userLat ?? 24.7136, _userLng ?? 46.6753);
    final markers = _results
        .where((j) => j.lat != null && j.lng != null)
        .map((j) => Marker(
              point: LatLng(j.lat!, j.lng!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => context.push('/job/${j.id}'),
                child: const Icon(Icons.work, color: AppColors.primaryAction),
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
}
