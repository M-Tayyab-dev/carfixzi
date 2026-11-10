/// Form input validators adhering to CARFIXZI security specifications
class Validators {
  /// Firebase-enforced strong password policy:
  /// - Min 12 characters
  /// - At least 1 uppercase letter
  /// - At least 1 lowercase letter
  /// - At least 1 number
  /// - At least 1 symbol
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 12) {
      return 'Password must be at least 12 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Must include at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Must include at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Must include at least one number';
    }
    if (!RegExp(r'[!@#\$&*~%^()_\-+=\[\]{}|;:,.<>?]').hasMatch(value)) {
      return 'Must include at least one special character';
    }
    return null;
  }

  /// Calculates password strength score from 0 to 4
  static int getPasswordStrength(String password) {
    int score = 0;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$&*~%^()_\-+=\[\]{}|;:,.<>?]').hasMatch(password)) score++;
    return score;
  }

  /// Validates standard email address
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates Pakistani phone number (+92 / 03xx)
  static String? validatePakistaniPhone(String? value, {bool isOptional = true}) {
    if (value == null || value.trim().isEmpty) {
      return isOptional ? null : 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    final pakPhoneRegex = RegExp(r'^(\+92|0092|92|0)?3[0-9]{9}$');
    if (!pakPhoneRegex.hasMatch(cleaned)) {
      return 'Enter a valid Pakistani mobile number (+923xxxxxxxxx)';
    }
    return null;
  }

  /// General required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
