class NoteFolder {
  final int? id;
  final String name;
  final String? password;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteFolder({
    this.id,
    required this.name,
    this.password,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  bool get isLocked => password != null && password!.isNotEmpty;

  NoteFolder copyWith({
    int? id,
    String? name,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearPassword = false,
  }) {
    return NoteFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      password: clearPassword ? null : (password ?? this.password),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NoteFolder.fromMap(Map<String, dynamic> map) {
    return NoteFolder(
      id: map['id'] as int?,
      name: map['name'] as String,
      password: map['password'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
