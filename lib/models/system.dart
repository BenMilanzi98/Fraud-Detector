class System {
  final int? id;
  final String name;
  final String description;
  final String apiEndpoint;
  final String apiKey;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastSyncAt;

  System({
    this.id,
    required this.name,
    required this.description,
    required this.apiEndpoint,
    required this.apiKey,
    this.isActive = true,
    required this.createdAt,
    this.lastSyncAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'api_endpoint': apiEndpoint,
      'api_key': apiKey,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'last_sync_at': lastSyncAt?.toIso8601String(),
    };
  }

  factory System.fromMap(Map<String, dynamic> map) {
    return System(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      apiEndpoint: map['api_endpoint'],
      apiKey: map['api_key'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      lastSyncAt: map['last_sync_at'] != null 
          ? DateTime.parse(map['last_sync_at']) 
          : null,
    );
  }

  System copyWith({
    int? id,
    String? name,
    String? description,
    String? apiEndpoint,
    String? apiKey,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastSyncAt,
  }) {
    return System(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      apiKey: apiKey ?? this.apiKey,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
} 