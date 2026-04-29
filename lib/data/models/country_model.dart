class Country {
  final String id;
  final String name;
  final String code;
  final String? flagUrl;
  final DateTime? createdAt;

  const Country({
    required this.id,
    required this.name,
    required this.code,
    this.flagUrl,
    this.createdAt,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        code: json['code'] ?? '',
        flagUrl: json['flagUrl'],
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'flagUrl': flagUrl,
        'createdAt': createdAt?.toIso8601String(),
      };
}

class CreateCountryRequest {
  final String name;
  final String code;
  final String? flagUrl;

  const CreateCountryRequest({
    required this.name,
    required this.code,
    this.flagUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'flagUrl': flagUrl,
      };
}
