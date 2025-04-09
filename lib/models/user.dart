class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isAdmin;
  final List<String> favoriteProverbs;
  final List<String> bookmarkedProverbs;
  final List<String> readProverbs;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isAdmin = false,
    this.favoriteProverbs = const [],
    this.bookmarkedProverbs = const [],
    this.readProverbs = const [],
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isAdmin: json['isAdmin'] as bool? ?? false,
      favoriteProverbs: List<String>.from(json['favoriteProverbs'] ?? []),
      bookmarkedProverbs: List<String>.from(json['bookmarkedProverbs'] ?? []),
      readProverbs: List<String>.from(json['readProverbs'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isAdmin': isAdmin,
      'favoriteProverbs': favoriteProverbs,
      'bookmarkedProverbs': bookmarkedProverbs,
      'readProverbs': readProverbs,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isAdmin,
    List<String>? favoriteProverbs,
    List<String>? bookmarkedProverbs,
    List<String>? readProverbs,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      favoriteProverbs: favoriteProverbs ?? this.favoriteProverbs,
      bookmarkedProverbs: bookmarkedProverbs ?? this.bookmarkedProverbs,
      readProverbs: readProverbs ?? this.readProverbs,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
