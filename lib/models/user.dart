class User {
  final int? id;
  final String email;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  User({
    this.id,
    required this.email,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    this.role = 'user',
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      passwordHash: map['password_hash'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      role: map['role'],
      createdAt: DateTime.parse(map['created_at']),
      lastLoginAt: map['last_login_at'] != null 
          ? DateTime.parse(map['last_login_at']) 
          : null,
      isActive: map['is_active'] == 1,
    );
  }

  User copyWith({
    int? id,
    String? email,
    String? passwordHash,
    String? firstName,
    String? lastName,
    String? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }

  String get fullName => '$firstName $lastName';
} 