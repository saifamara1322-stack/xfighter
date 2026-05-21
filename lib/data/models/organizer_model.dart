// ─────────────────────────────────────────────────────────────────────────────
// Organizer Models  (matches API /api/organizers/* schemas)
// ─────────────────────────────────────────────────────────────────────────────

// ── CreateOrganizerRequest ────────────────────────────────────────────────────

class CreateOrganizerRequest {
  final String email;
  final String password;
  final String? fullName;
  final String? phoneNumber;
  final String? city;

  const CreateOrganizerRequest({
    required this.email,
    required this.password,
    this.fullName,
    this.phoneNumber,
    this.city,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        if (fullName != null) 'fullName': fullName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (city != null) 'city': city,
      };
}

// ── UpdateOrganizerRequest ────────────────────────────────────────────────────

class UpdateOrganizerRequest {
  final String? email;
  final String? password;
  final String? fullName;
  final String? phoneNumber;
  final String? city;
  final String? countryId;

  const UpdateOrganizerRequest({
    this.email,
    this.password,
    this.fullName,
    this.phoneNumber,
    this.city,
    this.countryId,
  });

  Map<String, dynamic> toJson() => {
        if (email != null) 'email': email,
        if (password != null) 'password': password,
        if (fullName != null) 'fullName': fullName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (city != null) 'city': city,
        if (countryId != null) 'countryId': countryId,
      };
}
