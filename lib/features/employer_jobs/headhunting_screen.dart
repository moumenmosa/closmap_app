import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../core/models/seeker_profile.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/geo_utils.dart';
import '../../core/widgets/common_widgets.dart';
import '../../l10n/app_localizations.dart';
import 'seeker_preview_screen.dart';

class HeadhuntingScreen extends ConsumerStatefulWidget {
  const HeadhuntingScreen({super.key});

  @override
  ConsumerState<HeadhuntingScreen> createState() => _HeadhuntingScreenState();
}

class _HeadhuntingScreenState extends ConsumerState<HeadhuntingScreen> {
  LatLng? _employerLocation;
  bool _showMap = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    final profile =
        await ref.read(userRepositoryProvider).getEmployerProfile(user.uid);
    if (profile?.lat != null && profile?.lng != null) {
      setState(() => _employerLocation = LatLng(profile!.lat!, profile.lng!));
      return;
    }
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied) return;
    final pos = await Geolocator.getCurrentPosition();
    setState(() => _employerLocation = LatLng(pos.latitude, pos.longitude));
  }

  List<SeekerProfile> _nearby(List<SeekerProfile> all) {
    final center = _employerLocation;
    if (center == null) return all;
    return all
        .where((p) {
          if (p.lat == null || p.lng == null) return false;
          return GeoUtils.distanceKm(
                center.latitude,
                center.longitude,
                p.lat!,
                p.lng!,
              ) <=
              25;
        })
        .toList()
      ..sort((a, b) {
        final da = GeoUtils.distanceKm(
            center.latitude, center.longitude, a.lat!, a.lng!);
        final db = GeoUtils.distanceKm(
            center.latitude, center.longitude, b.lat!, b.lng!);
        return da.compareTo(db);
      });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.headhunting),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map_outlined),
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
        ],
      ),
      body: StreamBuilder<List<SeekerProfile>>(
        stream: ref.watch(userRepositoryProvider).watchSeekersWithLocation(),
        builder: (context, snap) {
          final seekers = _nearby(snap.data ?? []);
          if (seekers.isEmpty) return EmptyState(message: l10n.noResults);
          if (_showMap && _employerLocation != null) {
            return _mapView(seekers, l10n);
          }
          return ListView.builder(
            itemCount: seekers.length,
            itemBuilder: (_, i) {
              final s = seekers[i];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
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
        },
      ),
    );
  }

  Widget _mapView(List<SeekerProfile> seekers, AppLocalizations l10n) {
    final center = _employerLocation!;
    final markers = seekers
        .where((s) => s.lat != null && s.lng != null)
        .map(
          (s) => Marker(
            point: LatLng(s.lat!, s.lng!),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SeekerPreviewScreen(seekerId: s.uid),
                ),
              ),
              child: const Icon(Icons.person_pin_circle, color: AppColors.accent),
            ),
          ),
        )
        .toList();

    return FlutterMap(
      options: MapOptions(initialCenter: center, initialZoom: 11),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.closemap.closemap',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: center,
              width: 40,
              height: 40,
              child: const Icon(Icons.business, color: AppColors.primary),
            ),
            ...markers,
          ],
        ),
      ],
    );
  }
}
