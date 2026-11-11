import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/iam/presentation/auth_validators.dart';

void main() {
  group('email', () {
    test('accepts a well-formed email, ignoring surrounding spaces', () {
      expect(AuthValidators.email(' ana@mail.com '), isNull);
    });

    test('asks for the email when it is missing', () {
      expect(AuthValidators.email(''), 'Ingresa tu correo electrónico');
      expect(AuthValidators.email(null), 'Ingresa tu correo electrónico');
    });

    test('rejects a malformed email', () {
      expect(AuthValidators.email('ana@mail'), 'Ingresa un correo electrónico válido');
      expect(AuthValidators.email('ana mail.com'), 'Ingresa un correo electrónico válido');
    });
  });

  group('newPassword', () {
    test('requires at least 8 characters', () {
      expect(AuthValidators.newPassword('1234567'), 'La contraseña debe tener al menos 8 caracteres');
      expect(AuthValidators.newPassword('12345678'), isNull);
    });

    test('allows at most 72 characters', () {
      expect(AuthValidators.newPassword('a' * 72), isNull);
      expect(AuthValidators.newPassword('a' * 73), 'La contraseña debe tener como máximo 72 caracteres');
    });
  });

  test('the confirmation must match the password', () {
    expect(AuthValidators.passwordConfirmation('secret123', 'secret123'), isNull);
    expect(AuthValidators.passwordConfirmation('secret124', 'secret123'), 'Las contraseñas no coinciden');
    expect(AuthValidators.passwordConfirmation('', 'secret123'), 'Confirma tu contraseña');
  });

  test('sign-in only checks that a password was typed', () {
    expect(AuthValidators.password(''), 'Ingresa tu contraseña');
    expect(AuthValidators.password('short'), isNull);
  });
}
