import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/design/design_widgets.dart';

Future<T?> showProfileSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: ProfileSheetScaffold(title: title, child: child),
    ),
  );
}

class ProfileSheetScaffold extends StatelessWidget {
  const ProfileSheetScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class ProfileDateField extends StatelessWidget {
  const ProfileDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.enabled = true,
    this.hint = 'Date',
  });

  final String label;
  final DateTime? value;
  final VoidCallback? onTap;
  final bool enabled;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return DesignSelectField(
      label: label,
      value: value != null ? Formatters.date(value) : null,
      hint: hint,
      enabled: enabled,
      onTap: enabled ? onTap : null,
    );
  }
}

class ProfileDescriptionField extends StatelessWidget {
  const ProfileDescriptionField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLength = 200,
  });

  final TextEditingController controller;
  final String label;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, __) => Text(
                '${value.text.length}/$maxLength',
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 4,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: 'Enter Description',
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.inputRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.inputRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.inputRadius),
              borderSide: const BorderSide(color: AppColors.primaryAction, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

Future<DateTime?> pickProfileDate(
  BuildContext context, {
  DateTime? initial,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return showDatePicker(
    context: context,
    initialDate: initial ?? DateTime(2015),
    firstDate: firstDate ?? DateTime(1950),
    lastDate: lastDate ?? DateTime.now(),
  );
}

Future<String?> pickProfileOption(
  BuildContext context, {
  required String title,
  required List<String> options,
  String? selected,
}) {
  return DesignPickerSheet.show<String>(
    context: context,
    title: title,
    selected: selected,
    options: options
        .map((o) => DesignPickerOption<String>(value: o, label: o))
        .toList(),
  );
}
