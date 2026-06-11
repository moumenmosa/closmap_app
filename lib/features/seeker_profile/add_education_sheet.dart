import 'package:flutter/material.dart';
import '../../core/constants/lookups.dart';
import '../../core/models/seeker_profile.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';
import 'profile_sheet_common.dart';

class AddEducationSheet extends StatefulWidget {
  const AddEducationSheet({super.key, this.initial});

  final EducationEntry? initial;

  static Future<EducationEntry?> show(
    BuildContext context, {
    EducationEntry? initial,
  }) {
    return showProfileSheet<EducationEntry>(
      context: context,
      title: 'Add Education',
      child: AddEducationSheet(initial: initial),
    );
  }

  @override
  State<AddEducationSheet> createState() => _AddEducationSheetState();
}

class _AddEducationSheetState extends State<AddEducationSheet> {
  String _level = '';
  String _field = '';
  DateTime? _startDate;
  DateTime? _endDate;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _level = initial.level;
      _field = initial.field;
      _startDate = initial.startDate;
      _endDate = initial.endDate;
    }
    _description = TextEditingController(text: initial?.description ?? '');
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (_level.isEmpty || _field.isEmpty || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).requiredField)),
      );
      return;
    }
    Navigator.pop(
      context,
      EducationEntry(
        level: _level,
        field: _field,
        startDate: _startDate,
        endDate: _endDate,
        description: _description.text.trim(),
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
          label: 'Level of education *',
          value: _level,
          hint: 'Select Level (High school, bachelors...)',
          onTap: () async {
            final picked = await pickProfileOption(
              context,
              title: 'Level of education',
              options: Lookups.educationLevels,
              selected: _level.isEmpty ? null : _level,
            );
            if (picked != null) setState(() => _level = picked);
          },
        ),
        const SizedBox(height: 16),
        DesignSelectField(
          label: 'Field of education *',
          value: _field,
          hint: 'Enter Field (civil engineering..)',
          onTap: () async {
            final picked = await pickProfileOption(
              context,
              title: 'Field of education',
              options: Lookups.educationFields,
              selected: _field.isEmpty ? null : _field,
            );
            if (picked != null) setState(() => _field = picked);
          },
        ),
        const SizedBox(height: 16),
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
          value: _endDate,
          onTap: () async {
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
