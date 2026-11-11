enum UserRole {
  buyer('BUYER'),
  fieldAgent('FIELD_AGENT'),
  catalogAdmin('CATALOG_ADMIN'),
  financeAdmin('FINANCE_ADMIN');

  /// The role name used by the Web Services and the JWT `role` claim.
  final String apiName;

  const UserRole(this.apiName);

  static UserRole fromApiName(String value) {
    return values.firstWhere(
      (role) => role.apiName == value,
      orElse: () => throw FormatException('Unknown role: $value'),
    );
  }
}
