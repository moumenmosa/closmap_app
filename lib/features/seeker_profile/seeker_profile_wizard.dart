import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/lookups.dart';
import '../../core/models/seeker_profile.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';
import 'add_education_sheet.dart';
import 'add_experience_sheet.dart';
import 'add_language_sheet.dart';
import 'add_skill_sheet.dart';
import 'profile_sheet_common.dart';

class SeekerProfileWizard extends ConsumerStatefulWidget {
  const SeekerProfileWizard({
    super.key,
    this.initial,
    this.enforceDailyLimit = false,
  });

  final SeekerProfile? initial;
  final bool enforceDailyLimit;

  @override
  ConsumerState<SeekerProfileWizard> createState() =>
      _SeekerProfileWizardState();
}

class _SeekerProfileWizardState extends ConsumerState<SeekerProfileWizard> {
  static const _stepCount = 7;

  final _pageController = PageController();
  int _step = 0;
  bool _loading = false;

  String _gender = '';
  String _marital = '';
  String _nationality = '';
  String _country = '';
  DateTime? _dob;
  String _photoUrl = '';
  LatLng _location = const LatLng(24.7136, 46.6753);

  final List<EducationEntry> _education = [];
  final List<ExperienceEntry> _experience = [];
  final List<LanguageEntry> _languages = [];
  final List<SkillEntry> _skills = [];
  String _resumeUrl = '';
  String _resumeName = '';
  int _resumeSizeBytes = 0;
  final _linkedIn = TextEditingController();
  final _cityController = TextEditingController();
  final List<TextEditingController> _otherLinks = [];

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    if (p != null) {
      _gender = p.gender;
      _marital = p.maritalStatus;
      _nationality = p.nationality;
      _country = p.countryOfResidence;
      _dob = p.dateOfBirth;
      _photoUrl = p.photoUrl;
      _cityController.text = p.city;
      if (p.lat != null && p.lng != null) {
        _location = LatLng(p.lat!, p.lng!);
      }
      _education.addAll(p.education);
      _experience.addAll(p.experience);
      _languages.addAll(p.languages);
      _skills.addAll(p.skills);
      _resumeUrl = p.resumeUrl;
      _resumeName = p.resumeName;
      _resumeSizeBytes = p.resumeSizeBytes;
      _linkedIn.text = p.linkedInUrl;
      for (final link in p.otherLinks) {
        _otherLinks.add(TextEditingController(text: link));
      }
    }
  }

  @override
  void dispose() {
    _linkedIn.dispose();
    _cityController.dispose();
    for (final c in _otherLinks) {
      c.dispose();
    }
    super.dispose();
  }

  double get _progress => (_step + 1) / _stepCount;

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _loading = true);
    try {
      final url =
          await ref.read(cloudinaryServiceProvider).uploadFile(File(file.path));
      setState(() => _photoUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result == null || result.files.single.path == null) return;
    setState(() => _loading = true);
    try {
      final file = result.files.single;
      final url = await ref.read(cloudinaryServiceProvider).uploadFile(
            File(file.path!),
            resourceType: 'raw',
          );
      setState(() {
        _resumeUrl = url;
        _resumeName = file.name;
        _resumeSizeBytes = file.size;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    setState(() => _loading = true);
    final profile = SeekerProfile(
      uid: uid,
      gender: _gender,
      maritalStatus: _marital,
      nationality: _nationality,
      countryOfResidence: _country,
      city: _cityController.text.trim(),
      lat: _location.latitude,
      lng: _location.longitude,
      photoUrl: _photoUrl,
      dateOfBirth: _dob,
      education: List.of(_education),
      experience: List.of(_experience),
      languages: List.of(_languages),
      skills: List.of(_skills),
      resumeUrl: _resumeUrl,
      resumeName: _resumeName,
      resumeSizeBytes: _resumeSizeBytes,
      linkedInUrl: _linkedIn.text.trim(),
      otherLinks: _otherLinks.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
    );
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(userRepositoryProvider).saveSeekerProfile(
            profile,
            enforceDailyLimit: widget.enforceDailyLimit,
          );
      if (!mounted) return;
      context.go('/seeker/home');
    } catch (e) {
      if (!mounted) return;
      if (e.toString().contains('profile_update_limit')) {
        final userDoc = await ref.read(userRepositoryProvider).getUser(uid);
        final last = userDoc?.lastProfileUpdate;
        final hoursLeft = last == null
            ? 0
            : 24 - DateTime.now().difference(last).inHours;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                hoursLeft > 0
                    ? l10n.hoursLeft(hoursLeft.clamp(1, 24))
                    : l10n.profileUpdateLimit,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _next() {
    if (_step < _stepCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      _save();
    }
  }

  void _back() {
    if (_step > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Navigator.maybePop(context);
    }
  }

  Future<void> _pickSelect({
    required String title,
    required List<String> options,
    required String current,
    required ValueChanged<String> onPicked,
  }) async {
    final picked = await pickProfileOption(
      context,
      title: title,
      options: options,
      selected: current.isEmpty ? null : current,
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLastStep = _step == _stepCount - 1;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: DesignAppBar(
        title: 'Personal profile',
        onBack: _back,
        actionLabel: isLastStep ? l10n.start : l10n.next,
        onAction: _loading ? null : _next,
      ),
      body: Column(
        children: [
          DesignProgressHeader(progress: _progress),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _step = i),
              children: [
                _personalStep(l10n),
                _educationStep(l10n),
                _experienceStep(l10n),
                _languagesStep(l10n),
                _skillsStep(l10n),
                _resumeLinksStep(l10n),
                _locationStep(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _personalStep(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryAction,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: ClipOval(
                    child: _photoUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _photoUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.person, size: 48),
                          )
                        : CustomPaint(
                            painter: _DashedCirclePainter(),
                            child: const Center(
                              child: Icon(
                                Icons.person_outline,
                                size: 48,
                                color: AppColors.textHint,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DesignPrimaryButton(
                label: 'Edit Image',
                minimumHeight: 40,
                onPressed: _pickPhoto,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ProfileDateField(
          label: l10n.dateOfBirth,
          value: _dob,
          hint: 'Enter Date of birth',
          onTap: () async {
            final picked = await pickProfileDate(
              context,
              initial: _dob ?? DateTime(1995),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _dob = picked);
          },
        ),
        const SizedBox(height: 16),
        DesignSelectField(
          label: l10n.gender,
          value: _gender,
          hint: 'Select Gender',
          onTap: () => _pickSelect(
            title: l10n.gender,
            options: Lookups.genders,
            current: _gender,
            onPicked: (v) => setState(() => _gender = v),
          ),
        ),
        const SizedBox(height: 16),
        DesignSelectField(
          label: l10n.maritalStatus,
          value: _marital,
          hint: 'Select Marital status',
          onTap: () => _pickSelect(
            title: l10n.maritalStatus,
            options: Lookups.maritalStatuses,
            current: _marital,
            onPicked: (v) => setState(() => _marital = v),
          ),
        ),
        const SizedBox(height: 16),
        DesignSelectField(
          label: l10n.nationality,
          value: _nationality,
          hint: 'Select Nationality',
          onTap: () => _pickSelect(
            title: l10n.nationality,
            options: Lookups.nationalities,
            current: _nationality,
            onPicked: (v) => setState(() => _nationality = v),
          ),
        ),
        const SizedBox(height: 16),
        DesignSelectField(
          label: l10n.countryOfResidence,
          value: _country,
          hint: 'Select Country of residence',
          onTap: () => _pickSelect(
            title: l10n.countryOfResidence,
            options: Lookups.countries,
            current: _country,
            onPicked: (v) => setState(() => _country = v),
          ),
        ),
      ],
    );
  }

  Widget _listStepScaffold({
    required AppLocalizations l10n,
    required String title,
    required List<Widget> items,
    required VoidCallback onAdd,
    IconData emptyIcon = Icons.school_outlined,
  }) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            if (items.isEmpty)
              Column(
                children: [
                  const SizedBox(height: 48),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(emptyIcon, size: 56, color: AppColors.primaryAction),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'There is no information currently, please add new information.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              )
            else
              ...items,
          ],
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: Material(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  '+ ${l10n.add}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _educationStep(AppLocalizations l10n) {
    return _listStepScaffold(
      l10n: l10n,
      title: l10n.education,
      emptyIcon: Icons.school_outlined,
      onAdd: () async {
        final entry = await AddEducationSheet.show(context);
        if (entry != null) setState(() => _education.add(entry));
      },
      items: _education.asMap().entries.map((e) {
        final edu = e.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _EntryCard(
            title: edu.field,
            subtitle: Formatters.dateRange(edu.startDate, edu.endDate),
            badge: SeekerProfile.educationLevelBadge(edu.level),
            onDelete: () => setState(() => _education.removeAt(e.key)),
            onEdit: () async {
              final updated = await AddEducationSheet.show(context, initial: edu);
              if (updated != null) setState(() => _education[e.key] = updated);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _experienceStep(AppLocalizations l10n) {
    return _listStepScaffold(
      l10n: l10n,
      title: l10n.experience,
      emptyIcon: Icons.work_outline,
      onAdd: () async {
        final entry = await AddExperienceSheet.show(context);
        if (entry != null) setState(() => _experience.add(entry));
      },
      items: _experience.asMap().entries.map((e) {
        final exp = e.value;
        final duration = SeekerProfile.formatDurationMonths(
          SeekerProfile.entryDurationMonths(exp),
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _EntryCard(
            title: exp.jobTitle,
            subtitle:
                '${Formatters.dateRange(exp.startDate, exp.endDate, ongoing: exp.ongoing)} · $duration',
            badge: exp.employmentType.toUpperCase(),
            onDelete: () => setState(() => _experience.removeAt(e.key)),
            onEdit: () async {
              final updated =
                  await AddExperienceSheet.show(context, initial: exp);
              if (updated != null) setState(() => _experience[e.key] = updated);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _languagesStep(AppLocalizations l10n) {
    return _listStepScaffold(
      l10n: l10n,
      title: l10n.languages,
      emptyIcon: Icons.translate,
      onAdd: () async {
        final entry = await AddLanguageSheet.show(context);
        if (entry != null) setState(() => _languages.add(entry));
      },
      items: _languages.asMap().entries.map((e) {
        final lang = e.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _EntryCard(
            title: lang.language,
            subtitle: lang.proficiency,
            onDelete: () => setState(() => _languages.removeAt(e.key)),
            onEdit: () async {
              final updated = await AddLanguageSheet.show(context, initial: lang);
              if (updated != null) setState(() => _languages[e.key] = updated);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _skillsStep(AppLocalizations l10n) {
    return _listStepScaffold(
      l10n: l10n,
      title: l10n.skills,
      emptyIcon: Icons.lightbulb_outline,
      onAdd: () async {
        final entry = await AddSkillSheet.show(
          context,
          education: _education,
          experience: _experience,
        );
        if (entry != null) setState(() => _skills.add(entry));
      },
      items: _skills.asMap().entries.map((e) {
        final skill = e.value;
        final profile = SeekerProfile(
          uid: '',
          education: _education,
          experience: _experience,
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _EntryCard(
            title: skill.name,
            subtitle: profile.skillSourceLabel(skill),
            onDelete: () => setState(() => _skills.removeAt(e.key)),
            onEdit: () async {
              final updated = await AddSkillSheet.show(
                context,
                education: _education,
                experience: _experience,
                initial: skill,
              );
              if (updated != null) setState(() => _skills[e.key] = updated);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _resumeLinksStep(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          l10n.resume,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.inputRadius),
            border: Border.all(
              color: AppColors.primaryAction,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              const Text(
                'Upload your CV or Resume and use it when you apply for jobs',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              if (_resumeName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_resumeName)),
                      if (_resumeSizeBytes > 0)
                        Text(
                          Formatters.fileSize(_resumeSizeBytes),
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                ),
                child: const Text(
                  'Upload a Doc/Docx/PDF',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.primaryAction),
                ),
              ),
              const SizedBox(height: 12),
              DesignPrimaryButton(
                label: 'Upload',
                minimumHeight: 44,
                loading: _loading,
                onPressed: _pickResume,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Links',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _linkedIn,
          label: l10n.linkedIn,
          hint: 'Link',
          keyboardType: TextInputType.url,
        ),
        ..._otherLinks.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: e.value,
                    label: l10n.otherLinks,
                    hint: 'https://www.mywebsite.com',
                    keyboardType: TextInputType.url,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => setState(() {
                    e.value.dispose();
                    _otherLinks.removeAt(e.key);
                  }),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _otherLinks.add(TextEditingController())),
            child: const Text('+Add More'),
          ),
        ),
      ],
    );
  }

  Widget _locationStep(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          l10n.location,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _cityController,
          label: 'City',
          hint: 'Enter your city',
          prefix: const Icon(Icons.location_on, color: AppColors.primaryAction),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.inputRadius),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _location,
                initialZoom: 11,
                onTap: (_, point) => setState(() => _location = point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.closemap.closemap',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _location,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.accent,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.title,
    required this.subtitle,
    this.badge,
    required this.onDelete,
    required this.onEdit,
  });

  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.inputRadius),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(AppTheme.inputRadius),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  title.isNotEmpty ? title.substring(0, 1).toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (v) {
                            if (v == 'delete') onDelete();
                            if (v == 'edit') onEdit();
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAction.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: AppColors.primaryAction,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryAction
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const dash = 6.0;
    const gap = 4.0;
    final radius = size.width / 2 - 2;
    final circumference = 2 * 3.1415926535 * radius;
    final count = (circumference / (dash + gap)).floor();
    for (var i = 0; i < count; i++) {
      final start = i * (dash + gap) / circumference * 2 * 3.1415926535;
      final sweep = dash / circumference * 2 * 3.1415926535;
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: radius,
        ),
        start,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
