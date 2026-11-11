import 'package:inmonode/features/iam/domain/user_role.dart';

class Session {
  /// Margin so a token that is about to expire is renewed before it is sent.
  static const Duration expiryMargin = Duration(seconds: 30);

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final int userId;
  final String email;
  final UserRole role;

  const Session({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.userId,
    required this.email,
    required this.role,
  });

  bool isExpired(DateTime now) => !now.isBefore(expiresAt.subtract(expiryMargin));
}
