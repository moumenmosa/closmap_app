import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/lookups.dart';
import '../../core/models/job_search_filters.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/design/design_app_bar.dart';
import '../../core/widgets/design/design_picker_sheet.dart';
import '../../core/widgets/design/design_primary_button.dart';
import '../../core/widgets/design/design_select_field.dart';
import '../../l10n/app_localizations.dart';
import '../home/job_title_filter_sheet.dart';

class FilterScreen extends ConsumerStatefulWidget {
  const FilterScreen({super.key, this.initial = JobSearchFilters.empty});

  final JobSearchFilters initial;

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  late Set<String> _jobTitles;
  late bool _useExploringSpot;
  late String _location;
  late String _company;
  String? _experienceLevel;
  String? _fieldOfEducation;
  String? _levelOfEducation;
  String? _jobType;
  late String? _remoteOption;
  late String? _genderType;
  late Set<String> _languages;
  late RangeValues _salaryRange;
  double? _spotLat;
  double? _spotLng;
  double? _spotRadiusKm;

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _jobTitles = Set<String>.from(f.jobTitles);
    _useExploringSpot = f.useExploringSpot;
    _location = f.location;
    _company = f.company;
    _experienceLevel = f.experienceLevel;
    _fieldOfEducation = f.fieldOfEducation;
    _levelOfEducation = f.levelOfEducation;
    _jobType = f.jobType;
    _remoteOption = f.remoteOption;
    _genderType = f.genderType;
    _languages = Set<String>.from(f.languages);
    _salaryRange = RangeValues(f.salaryMin, f.salaryMax);
    _spotLat = f.spotLat;
    _spotLng = f.spotLng;
    _spotRadiusKm = f.spotRadiusKm;
  }

  JobSearchFilters get _filters => JobSearchFilters(
        jobTitles: _jobTitles,
        useExploringSpot: _useExploringSpot,
        location: _location,
        company: _company,
        experienceLevel: _experienceLevel,
        fieldOfEducation: _fieldOfEducation,
        levelOfEducation: _levelOfEducation,
        jobType: _jobType,
        remoteOption: _remoteOption,
        genderType: _genderType,
        languages: _languages,
        salaryMin: _salaryRange.start,
        salaryMax: _salaryRange.end,
        keyword: widget.initial.keyword,
        city: _location.isNotEmpty ? _location : widget.initial.city,
        lat: widget.initial.lat,
        lng: widget.initial.lng,
        spotLat: _spotLat,
        spotLng: _spotLng,
        spotRadiusKm: _spotRadiusKm,
      );

  void _clear() {
    setState(() {
      _jobTitles = {};
      _useExploringSpot = false;
      _location = '';
      _company = '';
      _experienceLevel = null;
      _fieldOfEducation = null;
      _levelOfEducation = null;
      _jobType = null;
      _remoteOption = null;
      _genderType = null;
      _languages = {};
      _salaryRange = const RangeValues(
        JobSearchFilters.salaryFloor,
        JobSearchFilters.salaryCeiling,
      );
      _spotLat = null;
      _spotLng = null;
      _spotRadiusKm = null;
    });
  }

  Future<void> _pickSingle(
    String title,
    List<String> options,
    String? current,
    void Function(String?) onSelected,
  ) async {
    final picked = await DesignPickerSheet.show<String>(
      context: context,
      title: title,
      options: options.map((o) => DesignPickerOption(value: o, label: o)).toList(),
      selected: current,
    );
    if (picked != null) onSelected(picked);
  }

  Future<void> _pickLanguages() async {
    final picked = await DesignPickerSheet.showMulti<String>(
      context: context,
      title: AppLocalizations.of(context).languages,
      options: Lookups.languages
          .map((l) => DesignPickerOption<String>(value: l, label: l))
          .toList(),
      selectedValues: _languages,
      confirmLabel: AppLocalizations.of(context).done,
    );
    if (picked != null) setState(() => _languages = picked);
  }

  Future<void> _pickJobTitles() async {
    final picked = await JobTitleFilterSheet.show(context, selected: _jobTitles);
    if (picked != null) setState(() => _jobTitles = picked);
  }

  String _anyOr(String? value) =>
      value == null || value.isEmpty ? 'Any' : value;

  String _formatSalary(num value) =>
      '${NumberFormat('#,###').format(value)} SR';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: DesignAppBar(
        title: l10n.filter,
        actionLabel: l10n.clear,
        actionColor: AppColors.accent,
        onAction: _clear,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                DesignSelectField(
                  label: l10n.jobTitle,
                  value: _jobTitles.isEmpty ? null : _jobTitles.join(', '),
                  hint: 'UX/UI Designer, UX, UI, User Interface...',
                  onTap: _pickJobTitles,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.location,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _locationModeChip(
                      label: l10n.location,
                      selected: !_useExploringSpot,
                      onTap: () => setState(() => _useExploringSpot = false),
                    ),
                    const SizedBox(width: 12),
                    _locationModeChip(
                      label: l10n.exploringSpots,
                      selected: _useExploringSpot,
                      onTap: () => setState(() => _useExploringSpot = true),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DesignSelectField(
                  label: l10n.location,
                  value: _location.isEmpty ? null : _location,
                  hint: 'Riyadh, Saudi Arabia',
                  onTap: () async {
                    if (_useExploringSpot) {
                      final user = ref.read(currentUserProvider).valueOrNull;
                      if (user == null) return;
                      final spots = await ref
                          .read(spotRepositoryProvider)
                          .watchSpots(user.uid)
                          .first;
                      if (!mounted || spots.isEmpty) return;
                      final names = spots.map((s) => s.name).toList();
                      await _pickSingle(l10n.exploringSpots, names, null, (v) {
                        if (v == null) return;
                        final spot = spots.firstWhere((s) => s.name == v);
                        setState(() {
                          _location = spot.locationText.isNotEmpty
                              ? spot.locationText
                              : spot.name;
                          _spotLat = spot.lat;
                          _spotLng = spot.lng;
                          _spotRadiusKm = spot.radiusKm;
                        });
                      });
                    } else {
                      await _pickSingle(
                        l10n.location,
                        ['Riyadh, Saudi Arabia', 'Jeddah, Saudi Arabia', 'Dubai, UAE'],
                        _location.isEmpty ? null : _location,
                        (v) => setState(() => _location = v ?? ''),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                DesignSelectField(
                  label: l10n.companyName,
                  value: _company.isEmpty ? null : _company,
                  hint: 'Any',
                  onTap: () => _pickSingle(
                    l10n.companyName,
                    ['Any', ...Lookups.companySectors],
                    _company.isEmpty ? 'Any' : _company,
                    (v) => setState(() => _company = v == 'Any' ? '' : (v ?? '')),
                  ),
                ),
                const SizedBox(height: 16),
                DesignSelectField(
                  label: 'Experience level',
                  value: _anyOr(_experienceLevel) == 'Any' ? null : _experienceLevel,
                  hint: 'Any',
                  onTap: () => _pickSingle(
                    'Experience level',
                    ['Any', ...Lookups.experienceLevels],
                    _experienceLevel ?? 'Any',
                    (v) => setState(
                      () => _experienceLevel = v == 'Any' ? null : v,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DesignSelectField(
                  label: 'Field of Education',
                  value: _anyOr(_fieldOfEducation) == 'Any' ? null : _fieldOfEducation,
                  hint: 'Any',
                  onTap: () => _pickSingle(
                    'Field of Education',
                    ['Any', ...Lookups.educationFields],
                    _fieldOfEducation ?? 'Any',
                    (v) => setState(
                      () => _fieldOfEducation = v == 'Any' ? null : v,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DesignSelectField(
                  label: 'Level of education',
                  value: _anyOr(_levelOfEducation) == 'Any' ? null : _levelOfEducation,
                  hint: 'Any',
                  onTap: () => _pickSingle(
                    'Level of education',
                    ['Any', ...Lookups.educationLevels],
                    _levelOfEducation ?? 'Any',
                    (v) => setState(
                      () => _levelOfEducation = v == 'Any' ? null : v,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DesignSelectField(
                  label: l10n.jobType,
                  value: _anyOr(_jobType) == 'Any' ? null : _jobType,
                  hint: 'Any',
                  onTap: () => _pickSingle(
                    l10n.jobType,
                    ['Any', ...Lookups.employmentTypes],
                    _jobType ?? 'Any',
                    (v) => setState(() => _jobType = v == 'Any' ? null : v),
                  ),
                ),
                const SizedBox(height: 16),
                DesignSelectField(
                  label: l10n.remote,
                  value: _anyOr(_remoteOption) == 'Any' ? null : _remoteOption,
                  hint: 'Any',
                  onTap: () => _pickSingle(
                    l10n.remote,
                    ['Any', ...Lookups.remoteOptions],
                    _remoteOption ?? 'Any',
                    (v) => setState(() => _remoteOption = v == 'Any' ? null : v),
                  ),
                ),
                const SizedBox(height: 16),
                DesignSelectField(
                  label: 'Gender type',
                  value: _anyOr(_genderType) == 'Any' ? null : _genderType,
                  hint: 'Any',
                  onTap: () => _pickSingle(
                    'Gender type',
                    Lookups.genderTypes,
                    _genderType ?? 'All',
                    (v) => setState(() => _genderType = v),
                  ),
                ),
                const SizedBox(height: 16),
                DesignSelectField(
                  label: l10n.languages,
                  value: _languages.isEmpty ? null : _languages.join(', '),
                  hint: 'Any',
                  onTap: _pickLanguages,
                ),
                const SizedBox(height: 20),
                Text(
                  'Monthly Salary',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatSalary(_salaryRange.start),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryAction,
                            ),
                          ),
                          Text(
                            _formatSalary(_salaryRange.end),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryAction,
                            ),
                          ),
                        ],
                      ),
                      RangeSlider(
                        values: _salaryRange,
                        min: JobSearchFilters.salaryFloor,
                        max: JobSearchFilters.salaryCeiling,
                        divisions: 100,
                        activeColor: AppColors.primaryAction,
                        inactiveColor: AppColors.border,
                        onChanged: (v) => setState(() => _salaryRange = v),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatSalary(JobSearchFilters.salaryFloor),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatSalary(JobSearchFilters.salaryCeiling),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: DesignPrimaryButton(
                label: l10n.filter,
                onPressed: () => Navigator.pop(context, _filters),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationModeChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.primaryAction : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  size: 20,
                  color: selected ? AppColors.primaryAction : AppColors.textHint,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.primaryAction : AppColors.textPrimary,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
