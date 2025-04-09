class Category {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final int order;
  final bool isActive;
  
  Category({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.order = 0,
    this.isActive = true,
  });
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
      order: json['order'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'order': order,
      'isActive': isActive,
    };
  }
  
  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    int? order,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }
}