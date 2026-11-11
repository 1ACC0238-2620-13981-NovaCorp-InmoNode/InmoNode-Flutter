import 'package:inmonode/features/iam/domain/session.dart';
import 'package:inmonode/features/iam/domain/user_role.dart';

/// JSON form of a [Session] kept in secure storage.
class StoredSession {
  static Map<String, dynamic> toJson(Session session) {
    return {
      'accessToken': session.accessToken,
      'refreshToken': session.refreshToken,
      'expiresAt': session.expiresAt.toUtc().toIso8601String(),
      'userId': session.userId,
      'email': session.email,
      'role': session.role.apiName,
    };
  }

  static Session fromJson(Map<String, dynamic> json) {
    return Session(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      userId: (json['userId'] as num).toInt(),
      email: json['email'] as String,
      role: UserRole.fromApiName(json['role'] as String),
    );
  }
}
