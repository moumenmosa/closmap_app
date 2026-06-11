import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/lookups.dart';
import '../../core/models/employer_profile.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/geo_utils.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';

class EmployerProfileScreen extends ConsumerStatefulWidget {
  const EmployerProfileScreen({super.key});

  @override
  ConsumerState<EmployerProfileScreen> createState() =>
      _EmployerProfileScreenState();
}

class _EmployerProfileScreenState extends ConsumerState<EmployerProfileScreen> {
  final _pageController = PageController();
  int _step = 0;
  bool _loading = false;

  final _about = TextEditingController();
  final _activity = TextEditingController();
  final _hq = TextEditingController();
  final _hours = TextEditingController();
  final _services = TextEditingController();
  final _website = TextEditingController();
  final _regNumber = TextEditingController();
  String _sector = '';
  String _nationality = '';
  String _size = '';
  DateTime? _established;
  String _logoUrl = '';
  String _coverUrl = '';
  String _certificateUrl = '';
  LatLng _location = const LatLng(24.7136, 46.6753);

  static const _stepTitles = [
    'Company Logo',
    'Company Info',
    'Legal',
    'Location',
    'Links',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    final p = await ref.read(userRepositoryProvider).getEmployerProfile(uid);
    if (p == null) return;
    _about.text = p.about;
    _activity.text = p.activity;
    _hq.text = p.hqAddress;
    _hours.text = p.operatingHours;
    _services.text = p.servicesOffered;
    _website.text = p.website;
    _regNumber.text = p.registrationNumber;
    setState(() {
      _sector = p.sector;
      _nationality = p.nationality;
      _size = p.size;
      _established = p.established;
      _logoUrl = p.logoUrl;
      _coverUrl = p.coverUrl;
      _certificateUrl = p.certificateUrl;
      if (p.lat != null && p.lng != null) {
        _location = LatLng(p.lat!, p.lng!);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _about.dispose();
    _activity.dispose();
    _hq.dispose();
    _hours.dispose();
    _services.dispose();
    _website.dispose();
    _regNumber.dispose();
    super.dispose();
  }

  Future<void> _uploadLogo() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _loading = true);
    try {
      final url = await ref
          .read(cloudinaryServiceProvider)
          .uploadFile(File(file.path));
      setState(() => _logoUrl = url);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _uploadCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );
    if (result?.files.single.path == null) return;
    setState(() => _loading = true);
    try {
      final url = await ref.read(cloudinaryServiceProvider).uploadFile(
            File(result!.files.single.path!),
            resourceType: 'raw',
          );
      setState(() => _certificateUrl = url);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (uid == null) return;
    setState(() => _loading = true);
    final profile = EmployerProfile(
      uid: uid,
      companyName: user?.companyName ?? '',
      about: _about.text,
      sector: _sector,
      activity: _activity.text,
      nationality: _nationality,
      size: _size,
      established: _established,
      logoUrl: _logoUrl,
      coverUrl: _coverUrl,
      registrationNumber: _regNumber.text,
      certificateUrl: _certificateUrl,
      hqAddress: _hq.text,
      operatingHours: _hours.text,
      servicesOffered: _services.text,
      website: _website.text,
      lat: _location.latitude,
      lng: _location.longitude,
      geohash: GeoUtils.encode(_location.latitude, _location.longitude),
    );
    await ref.read(userRepositoryProvider).saveEmployerProfile(profile);
    if (mounted) {
      setState(() => _loading = false);
      context.go('/employer/home');
    }
  }

  void _next() {
    if (_step < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: DesignAppBar(
        title: l10n.profile,
        actionLabel: _step == 4 ? l10n.save : l10n.next,
        onAction: _loading ? null : _next,
      ),
      body: Column(
        children: [
          DesignProgressHeader(progress: (_step + 1) / 5),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _stepTitles[_step],
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _step = i),
              children: [
                _logoStep(l10n),
                _infoStep(l10n),
                _legalStep(l10n),
                _locationStep(l10n),
                _linksStep(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoStep(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Supported formats: .jpg, .png\nImage size: 500×500 px',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryAction,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: CircleAvatar(
              radius: 64,
              backgroundColor: AppColors.surfaceMuted,
              backgroundImage:
                  _logoUrl.isNotEmpty ? NetworkImage(_logoUrl) : null,
              child: _logoUrl.isEmpty
                  ? const Icon(Icons.business, size: 48)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        DesignPrimaryButton(
          label: l10n.uploadPhoto,
          onPressed: _uploadLogo,
          loading: _loading,
        ),
      ],
    );
  }

  Widget _infoStep(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppTextField(
          controller: _about,
          label: l10n.aboutCompany,
          maxLines: 4,
        ),
        const SizedBox(height: 12),
        DesignSelectField(
          label: l10n.companySector,
          value: _sector,
          hint: l10n.companySector,
          onTap: () => _pick(l10n.companySector, Lookups.companySectors, (v) {
            setState(() => _sector = v);
          }),
        ),
        const SizedBox(height: 12),
        AppTextField(controller: _activity, label: l10n.companyActivity),
        const SizedBox(height: 12),
        DesignSelectField(
          label: l10n.companySize,
          value: _size,
          hint: l10n.companySize,
          onTap: () => _pick(l10n.companySize, Lookups.companySizes, (v) {
            setState(() => _size = v);
          }),
        ),
        const SizedBox(height: 12),
        DesignSelectField(
          label: l10n.nationality,
          value: _nationality,
          hint: l10n.nationality,
          onTap: () => _pick(l10n.nationality, Lookups.nationalities, (v) {
            setState(() => _nationality = v);
          }),
        ),
        ListTile(
          title: const Text('Established'),
          subtitle: Text(_established != null
              ? '${_established!.day}/${_established!.month}/${_established!.year}'
              : '-'),
          trailing: Icon(Icons.calendar_today, color: AppColors.primaryAction),
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: DateTime(2010),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (d != null) setState(() => _established = d);
          },
        ),
      ],
    );
  }

  Widget _legalStep(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppTextField(
          controller: _regNumber,
          label: 'Registration Number',
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(_certificateUrl.isEmpty
              ? 'Upload certificate'
              : 'Certificate uploaded'),
          trailing: TextButton(
            onPressed: _uploadCertificate,
            child: Text(l10n.uploadPhoto),
          ),
        ),
        AppTextField(controller: _hours, label: l10n.operatingHours),
        const SizedBox(height: 12),
        AppTextField(controller: _services, label: l10n.servicesOffered),
      ],
    );
  }

  Widget _locationStep(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _location,
                initialZoom: 12,
                onTap: (_, p) => setState(() => _location = p),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.closemap.closemap',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _location,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(controller: _hq, label: l10n.headquartersLocation),
      ],
    );
  }

  Widget _linksStep(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppTextField(
          controller: _website,
          label: 'Website',
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 24),
        DesignPrimaryButton(
          label: l10n.save,
          loading: _loading,
          onPressed: _save,
        ),
      ],
    );
  }

  Future<void> _pick(
    String title,
    List<String> options,
    ValueChanged<String> onSelected,
  ) async {
    final result = await DesignPickerSheet.show<String>(
      context: context,
      title: title,
      options: options
          .map((o) => DesignPickerOption(value: o, label: o))
          .toList(),
    );
    if (result != null) onSelected(result);
  }
}
