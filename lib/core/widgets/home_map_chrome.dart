import 'package:flutter/material.dart';
import '../constants/map_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'package:flutter_map/flutter_map.dart';

/// CartoDB light tile layer used across home and search maps.
TileLayer lightMapTileLayer() {
  return TileLayer(
    urlTemplate: MapConstants.lightTileUrl,
    subdomains: MapConstants.lightTileSubdomains,
    userAgentPackageName: MapConstants.userAgentPackageName,
  );
}

class HomeCategoryChip extends StatelessWidget {
  const HomeCategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? AppColors.primaryAction : AppColors.surface,
        elevation: selected ? 0 : 1,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected ? AppColors.primaryAction : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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

class HomeBottomSearchBar extends StatelessWidget {
  const HomeBottomSearchBar({
    super.key,
    required this.hint,
    required this.onTap,
    this.onFilterTap,
    this.showFilter = false,
  });

  final String hint;
  final VoidCallback onTap;
  final VoidCallback? onFilterTap;
  final bool showFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: AppColors.surface,
        elevation: 6,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(AppTheme.inputRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.inputRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hint,
                    style: const TextStyle(color: AppColors.textHint, fontSize: 15),
                  ),
                ),
                if (showFilter && onFilterTap != null)
                  IconButton(
                    icon: const Icon(Icons.tune, color: AppColors.primaryAction),
                    onPressed: onFilterTap,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeViewToggle extends StatelessWidget {
  const HomeViewToggle({
    super.key,
    required this.listView,
    required this.onChanged,
    required this.mapLabel,
    required this.listLabel,
  });

  final bool listView;
  final ValueChanged<bool> onChanged;
  final String mapLabel;
  final String listLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _segment(
              label: mapLabel,
              icon: Icons.map_outlined,
              selected: !listView,
              onTap: () => onChanged(false),
            ),
            _segment(
              label: listLabel,
              icon: Icons.view_list_outlined,
              selected: listView,
              onTap: () => onChanged(true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segment({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.primaryAction : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.onMenu,
    this.actions = const [],
  });

  final VoidCallback onMenu;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: onMenu,
            color: AppColors.textPrimary,
          ),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}
