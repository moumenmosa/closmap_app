class Validators {
  Validators._();

  static final _email = RegExp(r'^[\w.+-]+@[\w.-]+\.\w{2,}$');

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'required';
    if (!_email.hasMatch(v.trim())) return 'invalid_email';
    return null;
  }

  static String? required(String? v, {int? maxLen}) {
    if (v == null || v.trim().isEmpty) return 'required';
    if (maxLen != null && v.trim().length > maxLen) return 'too_long';
    return null;
  }

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'required';
    if (!RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(v.trim())) {
      return 'invalid';
    }
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'required';
    if (!RegExp(r'^\+?\d{8,15}$').hasMatch(v.replaceAll(' ', ''))) {
      return 'invalid';
    }
    return null;
  }

  static String? url(String? v, {bool required = false}) {
    if (v == null || v.trim().isEmpty) return required ? 'required' : null;
    final uri = Uri.tryParse(v.trim());
    if (uri == null || !uri.hasScheme) return 'invalid';
    return null;
  }

  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'\d').hasMatch(password)) return false;
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;
    return true;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'required';
    if (!isStrongPassword(v)) return 'weak';
    return null;
  }

  static String? confirmPassword(String? v, String password) {
    if (v != password) return 'mismatch';
    return null;
  }
}
