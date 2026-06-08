// ─────────────────────────────────────────────────────────────────────────────
// Sport Models  (matches API /api/sports/* schemas)
// ─────────────────────────────────────────────────────────────────────────────

// ── SportResponse ─────────────────────────────────────────────────────────────

class Sport {
  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;

  const Sport({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  factory Sport.fromJson(Map<String, dynamic> json) => Sport(
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

// ── CreateSportRequest ────────────────────────────────────────────────────────

class CreateSportRequest {
  final String name;
  final String? description;

  const CreateSportRequest({required this.name, this.description});

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
      };
}

// ── SportCategoryResponse ─────────────────────────────────────────────────────

class SportCategory {
  final String id;
  final String sportId;
  final String? sportName;
  final String categoryId;
  final String? categoryName;
  final int? minAge;
  final int? maxAge;

  const SportCategory({
    required this.id,
    required this.sportId,
    this.sportName,
    required this.categoryId,
    this.categoryName,
    this.minAge,
    this.maxAge,
  });

  factory SportCategory.fromJson(Map<String, dynamic> json) => SportCategory(
        id: json['id']?.toString() ?? '',
        sportId: json['sportId']?.toString() ?? '',
        sportName: json['sportName'],
        categoryId: json['categoryId']?.toString() ?? '',
        categoryName: json['categoryName'],
        minAge: json['minAge'] as int?,
        maxAge: json['maxAge'] as int?,
      );
}

// ── CreateSportCategoryRuleRequest ────────────────────────────────────────────

class CreateSportCategoryRuleRequest {
  final String categoryId;
  final int? minAge;
  final int? maxAge;

  const CreateSportCategoryRuleRequest({
    required this.categoryId,
    this.minAge,
    this.maxAge,
  });

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        if (minAge != null) 'minAge': minAge,
        if (maxAge != null) 'maxAge': maxAge,
      };
}
