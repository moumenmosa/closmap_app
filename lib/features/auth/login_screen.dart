import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _savedEmailKey = 'saved_login_email';

  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final saved = ref.read(sharedPrefsProvider).getString(_savedEmailKey);
      if (saved != null && saved.isNotEmpty && mounted) {
        setState(() => _email.text = saved);
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _msg(String? key, AppLocalizations l10n) {
    switch (key) {
      case 'required':
        return l10n.requiredField;
      case 'invalid_email':
        return l10n.invalidEmail;
      default:
        return l10n.errorGeneric;
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(authServiceProvider).signIn(
            _email.text.trim(),
            _password.text,
          );
      await ref.read(sharedPrefsProvider).setString(
            _savedEmailKey,
            _email.text.trim(),
          );
      if (!mounted) return;
      context.go('/');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? l10n.errorGeneric)),
      );
    } catch (e) {
      if (!mounted) return;
      if (e.toString().contains('email_not_verified')) {
        context.go('/otp');
        return;
      }
      final msg = e.toString().contains('account_locked')
          ? l10n.accountLocked
          : e.toString().contains('email_not_verified')
              ? l10n.verifyEmail
              : l10n.errorGeneric;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: LanguageToggle(),
                ),
                const SizedBox(height: 16),
                const AppLogoHeader(showTitle: false),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.login,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: _email,
                        label: l10n.email,
                        hint: l10n.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final r = Validators.email(v);
                          return r == null ? null : _msg(r, l10n);
                        },
                      ),
                      const SizedBox(height: 16),
                      PasswordField(
                        controller: _password,
                        label: l10n.password,
                        validator: (v) =>
                            v == null || v.isEmpty ? l10n.requiredField : null,
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: Text(
                            l10n.forgotPassword,
                            style: const TextStyle(color: AppColors.accent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DesignPrimaryButton(
                        label: l10n.login,
                        loading: _loading,
                        leading: const Icon(Icons.fingerprint, color: Colors.white),
                        onPressed: _login,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: l10n.createAccount,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
