import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/seeker_profile.dart';
import '../../core/providers/lookup_providers.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';
import 'profile_sheet_common.dart';

class AddLanguageSheet extends ConsumerStatefulWidget {
  const AddLanguageSheet({super.key, this.initial});

  final LanguageEntry? initial;

  static Future<LanguageEntry?> show(
    BuildContext context, {
    LanguageEntry? initial,
  }) {
    return showProfileSheet<LanguageEntry>(
      context: context,
      title: 'Add Languages',
      child: AddLanguageSheet(initial: initial),
    );
  }

  @override
  ConsumerState<AddLanguageSheet> createState() => _AddLanguageSheetState();
}

class _AddLanguageSheetState extends ConsumerState<AddLanguageSheet> {
  String _language = '';
  String _proficiency = '';

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _language = initial.language;
      _proficiency = initial.proficiency;
    }
  }

  void _submit() {
    if (_language.isEmpty || _proficiency.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).requiredField)),
      );
      return;
    }
    Navigator.pop(
      context,
      LanguageEntry(language: _language, proficiency: _proficiency),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesignSelectField(
          label: 'Language *',
          value: _language,
          hint: 'Select Language',
          onTap: () async {
            final picked = await pickProfileOption(
              context,
              title: l10n.languages,
              options: lookupList(ref, 'languages'),
              selected: _language.isEmpty ? null : _language,
            );
            if (picked != null) setState(() => _language = picked);
          },
        ),
        const SizedBox(height: 16),
        DesignSelectField(
          label: '${l10n.proficiency} *',
          value: _proficiency,
          hint: 'Select Proficiency',
          onTap: () async {
            final picked = await pickProfileOption(
              context,
              title: l10n.proficiency,
              options: lookupList(ref, 'proficiencyLevels'),
              selected: _proficiency.isEmpty ? null : _proficiency,
            );
            if (picked != null) setState(() => _proficiency = picked);
          },
        ),
        const SizedBox(height: 24),
        DesignPrimaryButton(label: l10n.add, onPressed: _submit),
      ],
    );
  }
}
