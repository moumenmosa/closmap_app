import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/lookups.dart';
import '../../core/models/job_post.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/geo_utils.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';

class _SalaryPreset {
  const _SalaryPreset(this.min, this.max, this.label);

  final int min;
  final int max;
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SalaryPreset && min == other.min && max == other.max;

  @override
  int get hashCode => Object.hash(min, max);
}

const _salaryPresets = [
  _SalaryPreset(8000, 15000, '8,000 - 15,000 SR'),
  _SalaryPreset(15000, 25000, '15,000 - 25,000 SR'),
  _SalaryPreset(20000, 30000, '20,000 - 30,000 SR'),
  _SalaryPreset(30000, 50000, '30,000 - 50,000 SR'),
];

const _yearsLabels = ['0-1', '2-3', '4-5', '6-10', '10+'];
const _yearsValues = [1, 3, 5, 8, 10];

const _skillOptions = [
  'Figma',
  'UI Design',
  'Flutter',
  'Dart',
  'SQL',
  'Project Management',
  'Patient Care',
  'Recruitment',
  'Data Analysis',
  'Marketing',
  'HR Management',
];

class AddJobScreen extends ConsumerStatefulWidget {
  const AddJobScreen({super.key, this.jobId});

  final String? jobId;

  @override
  ConsumerState<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends ConsumerState<AddJobScreen> {
  final _about = TextEditingController();
  final _duties = TextEditingController();
  final _location = TextEditingController();

  String _title = Lookups.jobTitles.first;
  String _experienceLevel = Lookups.experienceLevels.first;
  int _yearsOfExperience = _yearsValues[2];
  Set<String> _requiredSkills = {};
  String _jobType = Lookups.employmentTypes.first;
  String _remote = Lookups.remoteOptions.first;
  String _fieldOfEducation = Lookups.educationFields.first;
  String _levelOfEducation = Lookups.educationLevels.first;
  Set<String> _languages = {Lookups.languages.first};
  _SalaryPreset _salary = _salaryPresets[2];
  String _genderType = Lookups.genderTypes.first;
  DateTime? _joiningDate;
  LatLng _pin = const LatLng(24.7136, 46.6753);
  int _validity = Lookups.validityDaysOptions[1];
  bool _loading = false;
  bool _published = false;
  String? _draftId;
  String _status = 'draft';

  @override
  void initState() {
    super.initState();
    final jobId = widget.jobId;
    if (jobId != null && jobId.isNotEmpty) {
      Future.microtask(() => _loadJob(jobId));
    }
  }

  Future<void> _loadJob(String id) async {
    final job = await ref.read(jobRepositoryProvider).getJob(id);
    if (job == null || !mounted) return;
    setState(() {
      _draftId = job.id;
      _status = job.status.isNotEmpty ? job.status : _status;
      _title = job.title.isNotEmpty ? job.title : _title;
      _experienceLevel =
          job.experienceLevel.isNotEmpty ? job.experienceLevel : _experienceLevel;
      _yearsOfExperience = job.yearsOfExperience > 0
          ? job.yearsOfExperience
          : _yearsOfExperience;
      _requiredSkills = job.requiredSkills.isNotEmpty
          ? job.requiredSkills.toSet()
          : job.skills.toSet();
      _jobType = job.jobType.isNotEmpty ? job.jobType : _jobType;
      _remote = job.remoteOption.isNotEmpty ? job.remoteOption : _remote;
      _fieldOfEducation = job.fieldOfEducation.isNotEmpty
          ? job.fieldOfEducation
          : _fieldOfEducation;
      _levelOfEducation = job.levelOfEducation.isNotEmpty
          ? job.levelOfEducation
          : _levelOfEducation;
      _languages =
          job.languages.isNotEmpty ? job.languages.toSet() : _languages;
      _salary = _salaryPresets.firstWhere(
        (p) => p.min == job.salaryMin.toInt() && p.max == job.salaryMax.toInt(),
        orElse: () => _SalaryPreset(
          job.salaryMin.toInt(),
          job.salaryMax.toInt(),
          job.salaryLabel,
        ),
      );
      _genderType = job.genderType.isNotEmpty ? job.genderType : _genderType;
      _joiningDate = job.joiningDate;
      _about.text = job.about;
      _duties.text = job.duties;
      _location.text = job.locationText;
      _validity = job.validityDays;
      if (job.lat != null && job.lng != null) {
        _pin = LatLng(job.lat!, job.lng!);
      }
    });
  }

  @override
  void dispose() {
    // Saving a draft after publish would overwrite status back to 'draft'
    // and silently unpublish the job.
    if (!_published) _saveDraft();
    _about.dispose();
    _duties.dispose();
    _location.dispose();
    super.dispose();
  }

  List<DesignPickerOption<String>> _stringOptions(List<String> items) =>
      items.map((e) => DesignPickerOption(value: e, label: e)).toList();

  Future<void> _pickSingle({
    required String title,
    required List<String> options,
    required String current,
    required ValueChanged<String> onSelected,
  }) async {
    final result = await DesignPickerSheet.show<String>(
      context: context,
      title: title,
      options: _stringOptions(options),
      selected: current,
    );
    if (result != null) onSelected(result);
  }

  Future<void> _pickMulti({
    required String title,
    required List<String> options,
    required Set<String> current,
    required ValueChanged<Set<String>> onSelected,
  }) async {
    final result = await DesignPickerSheet.showMulti<String>(
      context: context,
      title: title,
      options: _stringOptions(options),
      selectedValues: current,
      confirmLabel: 'Done',
    );
    if (result != null) onSelected(result);
  }

  Future<void> _pickSalary() async {
    final result = await DesignPickerSheet.show<_SalaryPreset>(
      context: context,
      title: AppLocalizations.of(context).salaryRange,
      searchable: false,
      options: _salaryPresets
          .map((p) => DesignPickerOption(value: p, label: p.label))
          .toList(),
      selected: _salary,
    );
    if (result != null) setState(() => _salary = result);
  }

  Future<void> _pickYears() async {
    final currentLabel = _yearsLabels[_yearsValues.indexOf(_yearsOfExperience)
        .clamp(0, _yearsLabels.length - 1)];
    final result = await DesignPickerSheet.show<String>(
      context: context,
      title: 'Years of Experience',
      searchable: false,
      options: _yearsLabels
          .map((e) => DesignPickerOption(value: e, label: e))
          .toList(),
      selected: currentLabel,
    );
    if (result == null) return;
    final idx = _yearsLabels.indexOf(result);
    if (idx >= 0) setState(() => _yearsOfExperience = _yearsValues[idx]);
  }

  Future<void> _pickJoiningDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _joiningDate = picked);
  }

  String get _yearsLabel {
    final idx = _yearsValues.indexOf(_yearsOfExperience);
    if (idx >= 0 && idx < _yearsLabels.length) return _yearsLabels[idx];
    return '$_yearsOfExperience';
  }

  JobPost _buildJob(String employerId, String companyName) => JobPost(
        id: _draftId ?? widget.jobId ?? '',
        employerId: employerId,
        companyName: companyName,
        title: _title,
        experienceLevel: _experienceLevel,
        yearsOfExperience: _yearsOfExperience,
        skills: _requiredSkills.toList(),
        requiredSkills: _requiredSkills.toList(),
        jobType: _jobType,
        remoteOption: _remote,
        fieldOfEducation: _fieldOfEducation,
        levelOfEducation: _levelOfEducation,
        languages: _languages.toList(),
        salaryMin: _salary.min,
        salaryMax: _salary.max,
        genderType: _genderType,
        joiningDate: _joiningDate,
        about: _about.text,
        duties: _duties.text,
        locationText: _location.text,
        lat: _pin.latitude,
        lng: _pin.longitude,
        geohash: GeoUtils.encode(_pin.latitude, _pin.longitude),
        validityDays: _validity,
        status: _status,
        createdAt: DateTime.now(),
      );

  Future<void> _saveDraft() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null || _title.isEmpty) return;
    // Never autosave over a published job: toMap() would null out
    // publishedAt/expiresAt and hide the job from active listings.
    if (_status != 'draft') return;
    final job = _buildJob(user.uid, user.companyName);
    final id = await ref.read(jobRepositoryProvider).saveJob(job);
    _draftId = id;
  }

  Future<void> _publish() async {
    final l10n = AppLocalizations.of(context);
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    if (!user.hasActiveSubscription) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noSubscription)),
      );
      return;
    }

    setState(() => _loading = true);
    final subRepo = ref.read(subscriptionRepositoryProvider);
    try {
      // Save the latest form values directly (bypasses the draft-only guard
      // in _saveDraft); publishJob below sets status/publishedAt/expiresAt.
      _draftId = await ref
          .read(jobRepositoryProvider)
          .saveJob(_buildJob(user.uid, user.companyName));
      final id = _draftId!;
      final ok = await subRepo.deductPoint(user.uid, 'Published job: $_title');
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.insufficientPoints)),
          );
        }
        return;
      }
      try {
        await ref.read(jobRepositoryProvider).publishJob(id, _validity);
      } catch (e) {
        await subRepo.refundPoint(user.uid, 'Refund: failed publish $_title');
        rethrow;
      }
      _published = true;
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _multilineField({
    required String label,
    required TextEditingController controller,
    int maxLines = 5,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.inputRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.inputRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: DesignAppBar(title: l10n.addJobPost),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            DesignSelectField(
              label: l10n.jobTitle,
              value: _title,
              onTap: () => _pickSingle(
                title: l10n.jobTitle,
                options: Lookups.jobTitles,
                current: _title,
                onSelected: (v) => setState(() => _title = v),
              ),
            ),
            const SizedBox(height: 16),
            DesignSelectField(
              label: 'Experience Level',
              value: _experienceLevel,
              onTap: () => _pickSingle(
                title: 'Experience Level',
                options: Lookups.experienceLevels,
                current: _experienceLevel,
                onSelected: (v) => setState(() => _experienceLevel = v),
              ),
            ),
            const SizedBox(height: 16),
            DesignSelectField(
              label: 'Years of Experience',
              value: _yearsLabel,
              onTap: _pickYears,
            ),
            const SizedBox(height: 16),
            DesignSelectField(
              label: l10n.skills,
              value: _requiredSkills.isEmpty ? null : _requiredSkills.join(', '),
              onTap: () => _pickMulti(
                title: l10n.skills,
                options: _skillOptions,
                current: _requiredSkills,
                onSelected: (v) => setState(() => _requiredSkills = v),
              ),
            ),
            const SizedBox(height: 16),
            DesignSelectField(
              label: l10n.jobType,
              value: _jobType,
              onTap: () => _pickSingle(
                title: l10n.jobType,
                options: Lookups.employmentTypes,
                current: _jobType,
                onSelected: (v) => setState(() => _jobType = v),
              ),
            ),
            const SizedBox(height: 16),
            DesignSelectField(
              label: 'Remote',
              value: _remote,
              onTap: () => _pickSingle(
                title: 'Remote',
                options: Lookups.remoteOptions,
                current: _remote,
                onSelected: (v) => setState(() => _remote = v),
              ),
            ),
            const SizedBox(height: 16),
            DesignSelectField(
              label: 'Field of Education',
              value: _fieldOfEducation,
              onTap: () => _pickSingle(
                title: 'Field of Education',
                options: Lookups.educationFields,
                current: _fieldOfEducation,
                onSelected: (v) => setState(() => _fieldOfEducation = v),
              ),
            ),
            const SizedBox(height: 16),
            DesignSelectField(
              label: 'Level of Education',
              value: _levelOfEducation,
              onTap: () => _pickSingle(
                title: 'Level of Education',
                options: Lookups.educationLevels,
                current: _levelOfEducation,
                onSelected: (v) => setState(() => _levelOfEducation = v),
              ),
            ),
            const SizedBox(height: 16),
            DesignSelectField(
              label: l10n.languages,
              value: _languages.isEmpty ? null : _languages.join(', '),
              onTap: () => _pickMulti(
                title: l10n.languages,
                options: Lookups.languages,
                current: _languages,
                onSelected: (v) => setState(() => _languages = v),
              ),
            ),
            const SizedBox(height: 16),
            DesignSelectField(
              label: l10n.salaryRange,
              value: _salary.label,
              onTap: _pickSalary,
            ),
            const SizedBox(height: 16),
            DesignSelectField(
              label: 'Gender Type',
              value: _genderType,
              onTap: () => _pickSingle(
                title: 'Gender Type',
                options: Lookups.genderTypes,
                current: _genderType,
                onSelected: (v) => setState(() => _genderType = v),
              ),
            ),
            const SizedBox(height: 16),
            DesignSelectField(
              label: 'Joining Date',
              value: _joiningDate != null ? Formatters.date(_joiningDate) : null,
              hint: 'Select date',
              onTap: _pickJoiningDate,
            ),
            const SizedBox(height: 16),
            _multilineField(
              label: 'About the job',
              controller: _about,
            ),
            const SizedBox(height: 16),
            _multilineField(
              label: l10n.duties,
              controller: _duties,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.location,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.inputRadius),
              child: SizedBox(
                height: 180,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _pin,
                    initialZoom: 12,
                    onTap: (_, p) => setState(() => _pin = p),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.closemap.closemap',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _pin,
                          width: 40,
                          height: 40,
                          child: const Icon(
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
            AppTextField(
              controller: _location,
              hint: 'Location ...',
            ),
            const SizedBox(height: 24),
            DesignPrimaryButton(
              label: l10n.addJobPost,
              loading: _loading,
              onPressed: _publish,
            ),
          ],
        ),
      ),
    );
  }
}
