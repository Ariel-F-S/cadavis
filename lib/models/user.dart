class User {
  final int? id;
  final String username;
  final String password;
  final String role; // admin atau pengguna

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  // Convert object ke Map (untuk insert/update ke database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
    };
  }

  // Convert Map dari database ke object User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
    );
  }

  // CopyWith untuk update sebagian field
  User copyWith({
    int? id,
    String? username,
    String? password,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }
}
