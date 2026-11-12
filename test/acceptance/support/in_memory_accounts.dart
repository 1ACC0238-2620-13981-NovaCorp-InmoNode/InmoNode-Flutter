import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/iam/domain/account.dart';
import 'package:inmonode/features/iam/domain/auth_repository.dart';
import 'package:inmonode/features/iam/domain/session.dart';
import 'package:inmonode/features/iam/domain/session_repository.dart';
import 'package:inmonode/features/iam/domain/user_role.dart';

/// Accounts of the `/auth` Web Services, kept in memory with their rules: a new account starts inactive
/// and gets a single-use verification link, and an email registers only once.
class InMemoryAccounts implements AuthRepository {
  static const String buyerEmail = 'compradora@inmonode.test';
  static const String catalogAdminEmail = 'catalogo@inmonode.test';

  /// Password of the seeded accounts; it only exists in this in-memory backend.
  static const String seededPassword = 'Acceptance-2026';

  final Map<String, StoredAccount> _accounts = {};

  /// Verification links emailed so far, by address.
  final Map<String, List<String>> verificationLinks = {};

  int _nextId = 1;
  int _nextToken = 1;

  InMemoryAccounts() {
    seed(buyerEmail, role: UserRole.buyer, status: AccountStatus.active);
    seed(catalogAdminEmail, role: UserRole.catalogAdmin, status: AccountStatus.active);
  }

  StoredAccount seed(
    String email, {
    String password = seededPassword,
    UserRole role = UserRole.buyer,
    AccountStatus status = AccountStatus.active,
  }) {
    final account = StoredAccount(id: _nextId++, email: email, password: password, role: role, status: status);
    _accounts[_key(email)] = account;
    return account;
  }

  StoredAccount? find(String email) => _accounts[_key(email)];

  int get count => _accounts.length;

  /// A session that has just started, as the sign-in answers it.
  Session sessionOf(String email) {
    final account = find(email)!;
    return Session(
      accessToken: 'access-${_nextToken++}',
      refreshToken: 'refresh-${_nextToken++}',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      userId: account.id,
      email: account.email,
      role: account.role,
    );
  }

  @override
  Future<Account> register(String email, String password) async {
    if (find(email) != null) {
      throw const ApiException(
        statusCode: 409,
        code: 'USER_CONFLICT',
        message: 'El correo ya está registrado; usa la recuperación de contraseña',
      );
    }
    final account = seed(email, password: password, status: AccountStatus.inactive);
    _emailVerificationLink(account);
    return account.toAccount();
  }

  @override
  Future<Account> verifyEmail(String token) async {
    for (final account in _accounts.values) {
      if (verificationLinks[account.email]?.remove(token) ?? false) {
        verificationLinks[account.email]!.clear();
        account.status = AccountStatus.active;
        return account.toAccount();
      }
    }
    throw const ApiException(statusCode: 400, code: 'VALIDATION_ERROR', message: 'El enlace no es válido o ya venció');
  }

  @override
  Future<void> resendVerification(String email) async {
    final account = find(email);
    if (account != null && account.status == AccountStatus.inactive) _emailVerificationLink(account);
  }

  @override
  Future<Session> signIn(String email, String password) async {
    final account = find(email);
    if (account == null || account.password != password) {
      throw const ApiException(statusCode: 401, code: 'INVALID_CREDENTIALS', message: 'Correo o contraseña incorrectos');
    }
    if (account.status != AccountStatus.active) {
      throw const ApiException(statusCode: 403, code: 'ACCOUNT_INACTIVE', message: 'La cuenta aún no está activa');
    }
    return sessionOf(email);
  }

  @override
  Future<Session> refresh(String refreshToken) async {
    throw const ApiException(statusCode: 401, code: 'INVALID_REFRESH_TOKEN', message: 'La sesión venció');
  }

  @override
  Future<void> signOut(String refreshToken) async {}

  @override
  Future<void> requestPasswordReset(String email) async {}

  @override
  Future<void> resetPassword(String token, String newPassword) async {}

  void _emailVerificationLink(StoredAccount account) {
    verificationLinks.putIfAbsent(account.email, () => []).add('verify-${_nextToken++}');
  }

  static String _key(String email) => email.trim().toLowerCase();
}

class StoredAccount {
  final int id;
  final String email;
  final String password;
  final UserRole role;
  AccountStatus status;

  StoredAccount({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.status,
  });

  Account toAccount() => Account(id: id, email: email, role: role, status: status);
}

/// The device storage of the session, which starts empty unless a scenario signs someone in.
class InMemorySessions implements SessionRepository {
  Session? session;

  @override
  Future<Session?> load() async => session;

  @override
  Future<void> save(Session session) async => this.session = session;

  @override
  Future<void> clear() async => session = null;
}
