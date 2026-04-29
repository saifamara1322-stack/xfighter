import 'package:xfighter/data/models/fighter_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CoachResponse  (matches API #/components/schemas/CoachResponse)
// ─────────────────────────────────────────────────────────────────────────────

class Coach {
  final String id;
  final String email;
  final String fullName;
  final String? specialty;
  final String? licenseNo;
  final String? phoneNumber;
  final String? country;
  final List<ClubSummary> clubs;

  const Coach({
    required this.id,
    required this.email,
    required this.fullName,
    this.specialty,
    this.licenseNo,
    this.phoneNumber,
    this.country,
    this.clubs = const [],
  });

  factory Coach.fromJson(Map<String, dynamic> json) => Coach(
        id: json['id']?.toString() ?? '',
        email: json['email'] ?? '',
        fullName: json['fullName'] ?? '',
        specialty: json['specialty'],
        licenseNo: json['licenseNo'],
        phoneNumber: json['phoneNumber'],
        country: json['country'],
        clubs: (json['clubs'] as List<dynamic>? ?? [])
            .map((e) => ClubSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'specialty': specialty,
        'licenseNo': licenseNo,
        'phoneNumber': phoneNumber,
        'country': country,
        'clubs': clubs.map((c) => c.toJson()).toList(),
      };
}
