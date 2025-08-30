class TokenResponse {
  final String accessToken;
  final String tokenType;

  const TokenResponse({required this.accessToken, required this.tokenType});

  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
        accessToken: json['access_token'] ?? '',
        tokenType: json['token_type'] ?? '',
      );
}
