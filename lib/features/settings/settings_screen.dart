import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/notification_prefs.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  NotificationPrefs? _prefs;
  bool _deleting = false;

  Future<void> _savePrefs(NotificationPrefs prefs) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    setState(() => _prefs = prefs);
    await ref.read(userRepositoryProvider).updateNotificationPrefs(uid, prefs);
  }

  Future<void> _pickLanguage(AppLocalizations l10n) async {
    final locale = ref.read(localeProvider);
    final picked = await DesignPickerSheet.show<String>(
      context: context,
      title: l10n.language,
      searchable: false,
      selected: locale,
      options: [
        DesignPickerOption(value: 'en', label: l10n.english),
        DesignPickerOption(value: 'ar', label: l10n.arabic),
      ],
    );
    if (picked == null || !mounted) return;
    ref.read(localeProvider.notifier).setLocale(picked);
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid != null) {
      await ref.read(authServiceProvider).updateLanguage(uid, picked);
    }
    setState(() {});
  }

  Future<void> _deleteAccount(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(message: l10n.confirmDeleteAccount),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ref.read(authServiceProvider).deleteAccount();
      if (mounted) context.go('/login');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric)),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) return const SizedBox.shrink();

    final prefs = _prefs ?? user.notificationPrefs;
    final locale = ref.watch(localeProvider);
    final languageLabel = locale == 'ar' ? l10n.arabic : l10n.english;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: DesignAppBar(title: l10n.settings),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SettingsCard(
            onTap: () => _pickLanguage(l10n),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.language,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        languageLabel,
                        style: const TextStyle(
                          color: AppColors.primaryAction,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.primaryAction),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.pushNotification,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            child: _ToggleRow(
              label: l10n.notificationsType1,
              value: prefs.pushType1,
              onChanged: (v) => _savePrefs(prefs.copyWith(pushType1: v)),
            ),
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            child: _ToggleRow(
              label: l10n.notificationsType2,
              value: prefs.pushType2,
              onChanged: (v) => _savePrefs(prefs.copyWith(pushType2: v)),
            ),
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            child: _ToggleRow(
              label: l10n.notificationsType3,
              value: prefs.pushType3,
              onChanged: (v) => _savePrefs(prefs.copyWith(pushType3: v)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.emailNotification,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            child: _ToggleRow(
              label: l10n.emailOnNewMatch,
              value: prefs.emailOnMatch,
              onChanged: (v) => _savePrefs(prefs.copyWith(emailOnMatch: v)),
            ),
          ),
          const SizedBox(height: 24),
          _SettingsCard(
            onTap: _deleting ? null : () => _deleteAccount(l10n),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.deleteMyAccount,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (_deleting)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.chevron_right, color: AppColors.accent),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => context.push('/about'),
              child: Text(l10n.aboutApp),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.inputRadius),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.inputRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: child,
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: AppColors.primaryAction,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
