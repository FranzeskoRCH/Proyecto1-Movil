class UserSession {
  final String userId;
  final String email;
  final String name;
  final String? role;

  UserSession({
    required this.userId,
    required this.email,
    required this.name,
    this.role,
  });

  factory UserSession.fromRobleMap(Map<String, dynamic> map) {
    // user_system devuelve user_id (snake_case), ademas de userId, _id e id
    return UserSession(
      userId: (map['userId'] ?? map['user_id'] ?? map['_id'] ?? map['id'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      role: map['role']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'role': role,
    };
  }
}
