import 'package:requra/widgets/password_rules_checklist.dart';

/// Centralised field-validation helpers.
///
/// Both the Cubit and the UI screens reference these so validation
/// logic is never duplicated.
class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

  /// Validates an email address.
  /// Returns an error string, or `null` if valid.
  static String? email(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Use format like: name@example.com';
    }
    return null;
  }

  /// Validates that [value] is non-empty.
  /// [fieldName] is used in the error message (e.g. 'Full name').
  static String? required(String value, String fieldName) {
    if (value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  /// Validates a signup password against the shared [PasswordRules].
  static String? password(String value) {
    if (value.isEmpty) return 'Password is required';
    if (!PasswordRules.isValid(value)) {
      return 'Password must meet all requirements below';
    }
    return null;
  }

  /// Validates that a login password field is non-empty (no strength rules).
  static String? loginPassword(String value) {
    if (value.isEmpty) return 'Password is required';
    return null;
  }

  /// Validates that [value] matches [other] (confirm-password).
  static String? confirmPassword(String value, String other) {
    if (value.isEmpty) return 'Confirm password is required';
    if (value != other) return 'Passwords do not match';
    return null;
  }
}
