// ─────────────────────────────────────────────────────────────────────────────
// Summary sub-objects (used inside FighterProfileResponse)
// ─────────────────────────────────────────────────────────────────────────────

class ClubSummary {
  final String id;
  final String name;
  final String city;

  const ClubSummary({
    required this.id,
    required this.name,
    required this.city,
  });

  factory ClubSummary.fromJson(Map<String, dynamic> json) => ClubSummary(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        city: json['city'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'city': city,
      };
}

class CoachSummary {
  final String id;
  final String fullName;
  final String? specialty;

  const CoachSummary({
    required this.id,
    required this.fullName,
    this.specialty,
  });

  factory CoachSummary.fromJson(Map<String, dynamic> json) => CoachSummary(
        id: json['id']?.toString() ?? '',
        fullName: json['fullName'] ?? '',
        specialty: json['specialty'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'specialty': specialty,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// FighterProfileResponse  (matches API #/components/schemas/FighterProfileResponse)
// ─────────────────────────────────────────────────────────────────────────────

class Fighter {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? category;
  final double? weight;
  final ClubSummary? club;
  final CoachSummary? coach;

  const Fighter({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.category,
    this.weight,
    this.club,
    this.coach,
  });

  factory Fighter.fromJson(Map<String, dynamic> json) => Fighter(
        id: json['id']?.toString() ?? '',
        email: json['email'] ?? '',
        fullName: json['fullName'] ?? '',
        phoneNumber: json['phoneNumber'],
        category: json['category'],
        weight: (json['weight'] as num?)?.toDouble(),
        club: json['club'] != null
            ? ClubSummary.fromJson(json['club'] as Map<String, dynamic>)
            : null,
        coach: json['coach'] != null
            ? CoachSummary.fromJson(json['coach'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'category': category,
        'weight': weight,
        'club': club?.toJson(),
        'coach': coach?.toJson(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// CreateFighterRequest  (matches API #/components/schemas/CreateFighterRequest)
// ─────────────────────────────────────────────────────────────────────────────

class CreateFighterRequest {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;
  final String countryId;
  final String? category;
  final double? weight;
  final String? clubId;
  final String? coachId;

  const CreateFighterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.countryId,
    this.phoneNumber,
    this.category,
    this.weight,
    this.clubId,
    this.coachId,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'countryId': countryId,
        'category': category,
        'weight': weight,
        'clubId': clubId,
        'coachId': coachId,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Utility: Weight categories & fight disciplines
// ─────────────────────────────────────────────────────────────────────────────

class WeightClass {
  static const List<String> classes = [
    'Flyweight',
    'Bantamweight',
    'Featherweight',
    'Lightweight',
    'Welterweight',
    'Middleweight',
    'Light Heavyweight',
    'Heavyweight',
    'Catchweight',
  ];
}

class FightStyle {
  static const List<String> styles = [
    'Boxe',
    'Kickboxing',
    'MMA',
    'Judo',
    'Jujitsu',
    'Karaté',
    'Taekwondo',
    'Wrestling',
    'Sambo',
    'Autre',
  ];
}