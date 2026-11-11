import 'package:inmonode/features/iam/domain/user_role.dart';

/// New accounts stay inactive until the email is verified.
enum AccountStatus { inactive, active }

class Account {
  final int id;
  final String email;
  final UserRole role;
  final AccountStatus status;

  const Account({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
  });
}
