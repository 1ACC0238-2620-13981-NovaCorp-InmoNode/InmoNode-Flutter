class TokenDto {
  final String token;
  final String tokenType;
  final int expiresIn;
  final String refreshToken;

  const TokenDto({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
  });

  factory TokenDto.fromJson(Map<String, dynamic> json) {
    return TokenDto(
      token: json['token'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresIn: (json['expiresIn'] as num).toInt(),
      refreshToken: json['refreshToken'] as String,
    );
  }
}
