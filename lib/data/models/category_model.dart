// ─────────────────────────────────────────────────────────────────────────────
// Category Models  (matches API /api/categories/* schemas)
// ─────────────────────────────────────────────────────────────────────────────

// ── CategoryResponse ──────────────────────────────────────────────────────────

class Category {
  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        description: json['description'],
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'createdAt': createdAt?.toIso8601String(),
      };
}

// ── CreateCategoryRequest ─────────────────────────────────────────────────────

class CreateCategoryRequest {
  final String name;
  final String? description;

  const CreateCategoryRequest({required this.name, this.description});

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
      };
}
