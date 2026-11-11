class UserDto {
  final int id;
  final String email;
  final String role;
  final String status;

  const UserDto({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
    );
  }
}
