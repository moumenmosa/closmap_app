import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'design_primary_button.dart';

class DesignPickerOption<T> {
  const DesignPickerOption({
    required this.value,
    required this.label,
    this.subtitle,
  });

  final T value;
  final String label;
  final String? subtitle;
}

class DesignPickerSheet<T> extends StatefulWidget {
  const DesignPickerSheet({
    super.key,
    required this.title,
    required this.options,
    required this.onConfirm,
    this.selected,
    this.selectedValues,
    this.multiSelect = false,
    this.searchable = true,
    this.confirmLabel = 'Done',
  });

  final String title;
  final List<DesignPickerOption<T>> options;
  final void Function(T value) onConfirm;
  final T? selected;
  final Set<T>? selectedValues;
  final bool multiSelect;
  final bool searchable;
  final String confirmLabel;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<DesignPickerOption<T>> options,
    T? selected,
    bool searchable = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DesignPickerSheet<T>(
        title: title,
        options: options,
        selected: selected,
        searchable: searchable,
        onConfirm: (value) => Navigator.pop(context, value),
      ),
    );
  }

  static Future<Set<T>?> showMulti<T>({
    required BuildContext context,
    required String title,
    required List<DesignPickerOption<T>> options,
    Set<T>? selectedValues,
    bool searchable = true,
    String confirmLabel = 'View',
  }) {
    return showModalBottomSheet<Set<T>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DesignPickerSheet<T>(
        title: title,
        options: options,
        selectedValues: selectedValues ?? {},
        multiSelect: true,
        searchable: searchable,
        confirmLabel: confirmLabel,
        onConfirm: (_) {},
      ),
    );
  }

  @override
  State<DesignPickerSheet<T>> createState() => _DesignPickerSheetState<T>();
}

class _DesignPickerSheetState<T> extends State<DesignPickerSheet<T>> {
  late final TextEditingController _searchController;
  late Set<T> _selected;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selected = widget.selectedValues?.toSet() ??
        (widget.selected != null ? {widget.selected as T} : <T>{});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DesignPickerOption<T>> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (!widget.searchable || query.isEmpty) return widget.options;
    return widget.options
        .where((option) => option.label.toLowerCase().contains(query))
        .toList();
  }

  void _toggle(T value) {
    setState(() {
      if (widget.multiSelect) {
        if (_selected.contains(value)) {
          _selected.remove(value);
        } else {
          _selected.add(value);
        }
      } else {
        _selected = {value};
        widget.onConfirm(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
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
              ),
              if (widget.searchable)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.scaffoldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final option = _filtered[index];
                    final isSelected = _selected.contains(option.value);

                    return ListTile(
                      title: Text(option.label),
                      subtitle: option.subtitle != null
                          ? Text(
                              option.subtitle!,
                              style: const TextStyle(color: AppColors.textSecondary),
                            )
                          : null,
                      trailing: widget.multiSelect
                          ? Checkbox(
                              value: isSelected,
                              activeColor: AppColors.primaryAction,
                              onChanged: (_) => _toggle(option.value),
                            )
                          : (isSelected
                              ? const Icon(Icons.check, color: AppColors.primaryAction)
                              : null),
                      onTap: () => _toggle(option.value),
                    );
                  },
                ),
              ),
              if (widget.multiSelect)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: DesignPrimaryButton(
                    label: widget.confirmLabel,
                    onPressed: _selected.isEmpty
                        ? null
                        : () => Navigator.pop(context, _selected),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
