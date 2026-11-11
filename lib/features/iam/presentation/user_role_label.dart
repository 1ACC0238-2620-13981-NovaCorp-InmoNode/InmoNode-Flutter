import 'package:inmonode/features/iam/domain/user_role.dart';

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
    UserRole.buyer => 'Comprador e Inversionista',
    UserRole.fieldAgent => 'Agente Comercial de Campo',
    UserRole.catalogAdmin => 'Administrador de Catálogo',
    UserRole.financeAdmin => 'Administrador de Finanzas',
  };
}
