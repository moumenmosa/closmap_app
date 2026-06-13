import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/lookups.dart';
import '../../core/providers/lookup_providers.dart';
import '../../core/widgets/design/design_picker_sheet.dart';
import '../../l10n/app_localizations.dart';

/// Multi-select job title sheet matching Map.png — wired to home job filtering.
class JobTitleFilterSheet {
  JobTitleFilterSheet._();

  static Future<Set<String>?> show(
    BuildContext context, {
    required Set<String> selected,
  }) {
    final l10n = AppLocalizations.of(context);
    final jobTitles = ProviderScope.containerOf(context)
            .read(lookupValuesProvider('jobTitles'))
            .valueOrNull ??
        Lookups.jobTitles;
    final options = jobTitles
        .map((t) => DesignPickerOption<String>(value: t, label: t))
        .toList();

    return DesignPickerSheet.showMulti<String>(
      context: context,
      title: l10n.jobTitle,
      options: options,
      selectedValues: selected,
      confirmLabel: 'View',
    );
  }

  /// Parses [latestJobTitle] from user profile into initial selection.
  static Set<String> initialFromUser(String latestJobTitle) {
    if (latestJobTitle.isEmpty) return {};
    final parts =
        latestJobTitle.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
    final known = parts.where((p) => Lookups.jobTitles.contains(p)).toSet();
    if (known.isNotEmpty) return known;
    return {latestJobTitle};
  }
}
