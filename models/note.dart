class Note {
  final int? id;
  final String title;
  final String content;
  final int? folderId;
  final String? password;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.folderId,
    this.password,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  bool get isLocked => password != null && password!.isNotEmpty;

  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? folderId,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearFolder = false,
    bool clearPassword = false,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      folderId: clearFolder ? null : (folderId ?? this.folderId),
      password: clearPassword ? null : (password ?? this.password),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'folderId': folderId,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      folderId: map['folderId'] as int?,
      password: map['password'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
