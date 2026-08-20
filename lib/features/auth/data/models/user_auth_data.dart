class UserAuthData {
  const UserAuthData({
    required this.userId,
    required this.name,
    required this.isAuthenticated,
    required this.token,
    required this.roles,
    required this.profilePicture,
    required this.refreshToken,
    required this.tokenExpiry,
    required this.isNewUser,
  });

  final String userId;
  final String name;
  final bool isAuthenticated;
  final String token;
  final List<String> roles;
  final String profilePicture;
  final String refreshToken;
  final String tokenExpiry;
  final bool isNewUser;

  factory UserAuthData.fromJson(Map<String, dynamic> json) {
    return UserAuthData(
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isAuthenticated: json['isAuthenticated'] as bool? ?? false,
      token: json['token']?.toString() ?? '',
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[],
      profilePicture: json['profilePicture']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      tokenExpiry: json['tokenExpiry']?.toString() ?? '',
      isNewUser: json['isNewUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'name': name,
      'isAuthenticated': isAuthenticated,
      'token': token,
      'roles': roles,
      'profilePicture': profilePicture,
      'refreshToken': refreshToken,
      'tokenExpiry': tokenExpiry,
      'isNewUser': isNewUser,
    };
  }
}
