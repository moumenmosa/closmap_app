import 'package:flutter/material.dart';
import '../../core/models/seeker_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';
import 'profile_sheet_common.dart';

class AddSkillSheet extends StatefulWidget {
  const AddSkillSheet({
    super.key,
    required this.education,
    required this.experience,
    this.initial,
  });

  final List<EducationEntry> education;
  final List<ExperienceEntry> experience;
  final SkillEntry? initial;

  static Future<SkillEntry?> show(
    BuildContext context, {
    required List<EducationEntry> education,
    required List<ExperienceEntry> experience,
    SkillEntry? initial,
  }) {
    return showProfileSheet<SkillEntry>(
      context: context,
      title: 'Add Skills',
      child: AddSkillSheet(
        education: education,
        experience: experience,
        initial: initial,
      ),
    );
  }

  @override
  State<AddSkillSheet> createState() => _AddSkillSheetState();
}

class _AddSkillSheetState extends State<AddSkillSheet> {
  String _name = '';
  String _source = 'experience';
  int _sourceIndex = 0;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _name = initial.name;
      _source = initial.source;
      _sourceIndex = initial.sourceIndex;
    }
  }

  void _selectSource(String source, int index) {
    setState(() {
      _source = source;
      _sourceIndex = index;
    });
  }

  void _submit() {
    if (_name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).requiredField)),
      );
      return;
    }
    if (widget.education.isEmpty && widget.experience.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add education or experience before adding skills'),
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      SkillEntry(name: _name, source: _source, sourceIndex: _sourceIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesignSelectField(
          label: 'Skill *',
          value: _name,
          hint: 'Skill (ex: Project Management)',
          onTap: () async {
            final picked = await pickProfileOption(
              context,
              title: l10n.skills,
              options: const [
                'Communication',
                'Figma',
                'UX Case Study',
                'Project Management',
                'Leadership',
                'Problem Solving',
              ],
              selected: _name.isEmpty ? null : _name,
            );
            if (picked != null) setState(() => _name = picked);
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Show us where you used this skill',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        if (widget.experience.isNotEmpty) ...[
          Text(
            l10n.experience,
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ...List.generate(widget.experience.length, (i) {
            final exp = widget.experience[i];
            final selected = _source == 'experience' && _sourceIndex == i;
            return CheckboxListTile(
              value: selected,
              activeColor: AppColors.primaryAction,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text('${exp.jobTitle} - ${exp.companyName}'),
              onChanged: (_) => _selectSource('experience', i),
            );
          }),
        ],
        if (widget.education.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.education,
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ...List.generate(widget.education.length, (i) {
            final edu = widget.education[i];
            final selected = _source == 'education' && _sourceIndex == i;
            return CheckboxListTile(
              value: selected,
              activeColor: AppColors.primaryAction,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text('${edu.field} - Education'),
              onChanged: (_) => _selectSource('education', i),
            );
          }),
        ],
        const SizedBox(height: 24),
        DesignPrimaryButton(label: l10n.add, onPressed: _submit),
      ],
    );
  }
}
