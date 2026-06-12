import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/lookups.dart';
import '../../core/models/app_user.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/validators.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  UserRole _role = UserRole.seeker;
  bool _agree = false;
  bool _loading = false;

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _companyName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController(text: Lookups.defaultCountryCode);
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  String? _validate(String? key, AppLocalizations l10n) {
    if (key == null) return null;
    switch (key) {
      case 'required':
        return l10n.requiredField;
      case 'invalid_email':
        return l10n.invalidEmail;
      case 'weak':
        return l10n.passwordWeak;
      case 'mismatch':
        return l10n.passwordMismatch;
      case 'invalid':
      case 'too_long':
        return l10n.requiredField;
      default:
        return l10n.errorGeneric;
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || !_agree) return;
    setState(() => _loading = true);
    final l10n = AppLocalizations.of(context);
    final auth = ref.read(authServiceProvider);
    try {
      if (_role == UserRole.seeker) {
        await auth.registerSeeker(
          email: _email.text,
          password: _password.text,
          firstName: _firstName.text,
          lastName: _lastName.text,
          phone: _phone.text,
        );
      } else {
        await auth.registerEmployer(
          email: _email.text,
          password: _password.text,
          companyName: _companyName.text,
          phone: _phone.text,
        );
      }

      await auth.sendVerificationEmail();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.verificationEmailSent)),
      );
      context.go('/otp');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? l10n.errorGeneric)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: DesignAppBar(title: l10n.register),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: LanguageToggle(),
                ),
                const SizedBox(height: 8),
                SegmentedButton<UserRole>(
                  segments: [
                    ButtonSegment(value: UserRole.seeker, label: Text(l10n.jobSeeker)),
                    ButtonSegment(value: UserRole.employer, label: Text(l10n.employer)),
                  ],
                  selected: {_role},
                  onSelectionChanged: (s) => setState(() => _role = s.first),
                ),
                const SizedBox(height: 24),
                if (_role == UserRole.seeker) ...[
                  AppTextField(
                    controller: _firstName,
                    label: l10n.firstName,
                    validator: (v) => Validators.name(v) != null ? l10n.requiredField : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _lastName,
                    label: l10n.lastName,
                    validator: (v) => Validators.name(v) != null ? l10n.requiredField : null,
                  ),
                ] else
                  AppTextField(
                    controller: _companyName,
                    label: l10n.companyName,
                    validator: (v) => Validators.required(v) != null ? l10n.requiredField : null,
                  ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _email,
                  label: l10n.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => _validate(Validators.email(v), l10n),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _phone,
                  label: l10n.phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) => Validators.phone(v) != null ? l10n.requiredField : null,
                ),
                const SizedBox(height: 12),
                PasswordField(
                  controller: _password,
                  label: l10n.password,
                  validator: (v) => _validate(Validators.password(v), l10n),
                ),
                const SizedBox(height: 12),
                PasswordField(
                  controller: _confirmPassword,
                  label: l10n.confirmPassword,
                  validator: (v) =>
                      _validate(Validators.confirmPassword(v, _password.text), l10n),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _agree,
                  onChanged: (v) => setState(() => _agree = v ?? false),
                  title: Text(l10n.agreeTerms),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                DesignPrimaryButton(
                  label: l10n.register,
                  loading: _loading,
                  onPressed: _agree ? _register : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
