import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/lookups.dart';
import '../../core/models/exploring_spot.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../l10n/app_localizations.dart';

class AddSpotScreen extends ConsumerStatefulWidget {
  const AddSpotScreen({super.key});

  @override
  ConsumerState<AddSpotScreen> createState() => _AddSpotScreenState();
}

class _AddSpotScreenState extends ConsumerState<AddSpotScreen> {
  final _name = TextEditingController();
  final _location = TextEditingController();
  double _radius = AppConfig.defaultSpotRadiusKm;
  LatLng _center = const LatLng(24.7136, 46.6753);
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final pos = await Geolocator.getCurrentPosition();
    setState(() => _center = LatLng(pos.latitude, pos.longitude));
  }

  Future<void> _save() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null || _name.text.isEmpty) return;
    setState(() => _loading = true);

    final spot = ExploringSpot(
      id: '',
      seekerId: uid,
      name: _name.text,
      locationText: _location.text,
      lat: _center.latitude,
      lng: _center.longitude,
      radiusKm: _radius,
      createdAt: DateTime.now(),
    );
    await ref.read(spotRepositoryProvider).addSpot(spot);
    await _runMatching(uid, spot);

    if (mounted) {
      setState(() => _loading = false);
      context.pop();
    }
  }

  Future<void> _runMatching(String uid, ExploringSpot spot) async {
    final profile = await ref.read(userRepositoryProvider).getSeekerProfile(uid);
    if (profile == null) return;
    final jobs = await ref.read(jobRepositoryProvider).watchActiveJobs().first;
    final matcher = ref.read(matchingServiceProvider);
    final notifier = ref.read(notificationServiceProvider);

    for (final job in jobs) {
      if (matcher.isMatchInSpot(spot, job, profile)) {
        final score = matcher.scoreJob(profile, job);
        await ref.read(applicationRepositoryProvider).addMatchedJob(
              seekerId: uid,
              jobId: job.id,
              spotId: spot.id,
              score: score,
            );
        await notifier.send(
          userId: uid,
          subject: 'Matched job',
          body: '${job.title} at ${job.companyName}',
          route: '/job/${job.id}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addSpot)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppTextField(controller: _name, label: l10n.spotName),
          const SizedBox(height: 12),
          AppTextField(controller: _location, label: l10n.location),
          const SizedBox(height: 12),
          DropdownButtonFormField<double>(
            decoration: InputDecoration(labelText: l10n.distance),
            value: _radius,
            items: Lookups.spotRadiusOptions
                .map((r) => DropdownMenuItem(value: r, child: Text('${r.toInt()} KM')))
                .toList(),
            onChanged: (v) => setState(() => _radius = v ?? _radius),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 12,
                onTap: (_, p) => setState(() => _center = p),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.closemap.closemap',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _center,
                      radius: _radius * 1000,
                      useRadiusInMeter: true,
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _center,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.place, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(label: l10n.add, loading: _loading, onPressed: _save),
        ],
      ),
    );
  }
}
