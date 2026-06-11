import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/design_assets.dart';
import '../../core/utils/auth_routing.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  int _seconds = 0;
  Timer? _timer;
  bool _loading = false;
  bool _resendLoading = false;
  DateTime? _lastResendAt;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    if (_lastResendAt == null) {
      setState(() => _seconds = 0);
      return;
    }
    final elapsed = DateTime.now().difference(_lastResendAt!).inSeconds;
    final remaining = AppConfig.otpResendSeconds - elapsed;
    setState(() => _seconds = remaining > 0 ? remaining : 0);
    _timer?.cancel();
    if (_seconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_seconds <= 1) {
          setState(() => _seconds = 0);
          t.cancel();
          return;
        }
        setState(() => _seconds--);
      });
    }
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context);
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    setState(() => _loading = true);
    try {
      final verified = await ref.read(authServiceProvider).reloadEmailVerified();
      if (!verified) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.emailNotVerifiedYet)),
        );
        return;
      }
      await ref.read(authServiceProvider).markEmailVerified(user.uid);
      if (!mounted) return;
      final appUser = await ref.read(authServiceProvider).getUser(user.uid);
      if (!mounted || appUser == null) return;
      context.go(homeRouteForUser(appUser));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_seconds > 0 || _resendLoading) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _resendLoading = true);
    try {
      await ref.read(authServiceProvider).sendVerificationEmail();
      _lastResendAt = DateTime.now();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.verificationEmailSent)),
        );
      }
      _startResendTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _resendLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final email = ref.watch(authStateProvider).valueOrNull?.email ?? '';
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: DesignAppBar(title: l10n.verifyEmail),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                DesignAssets.verifyAccount,
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.mark_email_unread_outlined,
                  size: 72,
                  color: AppColors.primaryAction,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.verifyEmailInstructions,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (email.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                l10n.verifyEmailHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const Spacer(),
              DesignPrimaryButton(
                label: l10n.emailVerifiedButton,
                loading: _loading,
                onPressed: _verify,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _seconds > 0 || _resendLoading ? null : _resend,
                child: Text(
                  _resendLoading
                      ? l10n.loading
                      : _seconds > 0
                          ? l10n.resendIn(_seconds)
                          : l10n.resendVerificationEmail,
                  style: TextStyle(
                    color: _seconds > 0
                        ? AppColors.textHint
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
