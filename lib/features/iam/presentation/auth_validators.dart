/// Field rules of the sign-up and sign-in forms, aligned with the `/auth` Web Services.
class AuthValidators {
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 72;
  static const int maxEmailLength = 255;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Ingresa tu correo electrónico';
    if (email.length > maxEmailLength || !_emailPattern.hasMatch(email)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  /// Sign-in only checks presence: the server decides whether the password is right.
  static String? password(String? value) {
    return (value ?? '').isEmpty ? 'Ingresa tu contraseña' : null;
  }

  static String? newPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Ingresa una contraseña';
    if (password.length < minPasswordLength) {
      return 'La contraseña debe tener al menos $minPasswordLength caracteres';
    }
    if (password.length > maxPasswordLength) {
      return 'La contraseña debe tener como máximo $maxPasswordLength caracteres';
    }
    return null;
  }

  static String? passwordConfirmation(String? value, String password) {
    if ((value ?? '').isEmpty) return 'Confirma tu contraseña';
    return value == password ? null : 'Las contraseñas no coinciden';
  }
}
