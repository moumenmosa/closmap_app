import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/seeker_profile.dart';
import '../../core/providers/lookup_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';
import 'profile_sheet_common.dart';

class AddExperienceSheet extends ConsumerStatefulWidget {
  const AddExperienceSheet({super.key, this.initial});

  final ExperienceEntry? initial;

  static Future<ExperienceEntry?> show(
    BuildContext context, {
    ExperienceEntry? initial,
  }) {
    return showProfileSheet<ExperienceEntry>(
      context: context,
      title: 'Add Experience',
      child: AddExperienceSheet(initial: initial),
    );
  }

  @override
  ConsumerState<AddExperienceSheet> createState() => _AddExperienceSheetState();
}

class _AddExperienceSheetState extends ConsumerState<AddExperienceSheet> {
  String _jobTitle = '';
  String _employmentType = '';
  late final TextEditingController _company;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _ongoing = false;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _jobTitle = initial.jobTitle;
      _employmentType = initial.employmentType;
      _startDate = initial.startDate;
      _endDate = initial.endDate;
      _ongoing = initial.ongoing;
    }
    _company = TextEditingController(text: initial?.companyName ?? '');
    _description = TextEditingController(text: initial?.responsibilities ?? '');
  }

  @override
  void dispose() {
    _company.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (_jobTitle.isEmpty ||
        _employmentType.isEmpty ||
        _company.text.trim().isEmpty ||
        _startDate == null ||
        (!_ongoing && _endDate == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).requiredField)),
      );
      return;
    }
    Navigator.pop(
      context,
      ExperienceEntry(
        jobTitle: _jobTitle,
        employmentType: _employmentType,
        companyName: _company.text.trim(),
        startDate: _startDate,
        endDate: _ongoing ? null : _endDate,
        ongoing: _ongoing,
        responsibilities: _description.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesignSelectField(
          label: 'Job title *',
          value: _jobTitle,
          hint: 'Enter title (Business analyst..)',
          onTap: () async {
            final picked = await pickProfileOption(
              context,
              title: l10n.jobTitle,
              options: lookupList(ref, 'jobTitles'),
              selected: _jobTitle.isEmpty ? null : _jobTitle,
            );
            if (picked != null) setState(() => _jobTitle = picked);
          },
        ),
        const SizedBox(height: 16),
        DesignSelectField(
          label: 'Employment type *',
          value: _employmentType,
          hint: 'Select type (Full-time, Part-time...)',
          onTap: () async {
            final picked = await pickProfileOption(
              context,
              title: l10n.jobType,
              options: lookupList(ref, 'employmentTypes'),
              selected: _employmentType.isEmpty ? null : _employmentType,
            );
            if (picked != null) setState(() => _employmentType = picked);
          },
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _company,
          label: 'Company or Organization *',
          hint: 'Enter Company Name',
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: _ongoing,
          activeColor: AppColors.primaryAction,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(l10n.ongoing),
          onChanged: (v) => setState(() {
            _ongoing = v ?? false;
            if (_ongoing) _endDate = null;
          }),
        ),
        const SizedBox(height: 8),
        ProfileDateField(
          label: 'Start date *',
          value: _startDate,
          onTap: () async {
            final picked = await pickProfileDate(context, initial: _startDate);
            if (picked != null) setState(() => _startDate = picked);
          },
        ),
        const SizedBox(height: 16),
        ProfileDateField(
          label: 'End date *',
          value: _ongoing ? null : _endDate,
          hint: _ongoing ? 'Present' : 'Date',
          enabled: !_ongoing,
          onTap: _ongoing
              ? null
              : () async {
                  final picked = await pickProfileDate(
                    context,
                    initial: _endDate ?? _startDate,
                    firstDate: _startDate ?? DateTime(1950),
                  );
                  if (picked != null) setState(() => _endDate = picked);
                },
        ),
        const SizedBox(height: 16),
        ProfileDescriptionField(
          controller: _description,
          label: 'Description *',
        ),
        const SizedBox(height: 24),
        DesignPrimaryButton(label: l10n.add, onPressed: _submit),
      ],
    );
  }
}
