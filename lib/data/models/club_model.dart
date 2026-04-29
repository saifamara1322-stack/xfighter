import 'package:flutter/material.dart';
import 'package:xfighter/data/models/fighter_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ClubStatus  (matches API status enums)
// ─────────────────────────────────────────────────────────────────────────────

enum ClubStatus {
  NODOCS,
  PENDING,
  ACTIVE,
  REFUSED,
  DISABLED;

  static ClubStatus fromString(String? value) {
    if (value == null) return ClubStatus.PENDING;
    try {
      return ClubStatus.values.firstWhere(
        (e) => e.name == value.toUpperCase(),
        orElse: () => ClubStatus.PENDING,
      );
    } catch (_) {
      return ClubStatus.PENDING;
    }
  }

  String get displayName {
    switch (this) {
      case ClubStatus.NODOCS:
        return 'No Documents';
      case ClubStatus.PENDING:
        return 'Pending';
      case ClubStatus.ACTIVE:
        return 'Active';
      case ClubStatus.REFUSED:
        return 'Refused';
      case ClubStatus.DISABLED:
        return 'Disabled';
    }
  }

  Color get color {
    switch (this) {
      case ClubStatus.NODOCS:
        return Colors.grey;
      case ClubStatus.PENDING:
        return Colors.orange;
      case ClubStatus.ACTIVE:
        return Colors.green;
      case ClubStatus.REFUSED:
        return Colors.red;
      case ClubStatus.DISABLED:
        return Colors.blueGrey;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ClubResponse  (matches API #/components/schemas/ClubResponse)
// ─────────────────────────────────────────────────────────────────────────────

class Club {
  final String id;
  final String email;
  final String name;
  final String? city;
  final String? address;
  final String? description;
  final String? logoUrl;
  final String? country;
  final String? fullName;
  final String? phoneNumber;
  final ClubStatus status;
  final String? adminId;
  final String? organizerId;

  const Club({
    required this.id,
    required this.email,
    required this.name,
    this.city,
    this.address,
    this.description,
    this.logoUrl,
    this.country,
    this.fullName,
    this.phoneNumber,
    required this.status,
    this.adminId,
    this.organizerId,
  });

  factory Club.fromJson(Map<String, dynamic> json) => Club(
        id: json['id']?.toString() ?? '',
        email: json['email'] ?? '',
        name: json['name'] ?? '',
        city: json['city'],
        address: json['address'],
        description: json['description'],
        logoUrl: json['logoUrl'],
        country: json['country'],
        fullName: json['fullName'],
        phoneNumber: json['phoneNumber'],
        status: ClubStatus.fromString(json['status']),
        adminId: json['adminId']?.toString(),
        organizerId: json['organizerId']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'city': city,
        'address': address,
        'description': description,
        'logoUrl': logoUrl,
        'country': country,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'status': status.name,
        'adminId': adminId,
        'organizerId': organizerId,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// CreateClubRequest  (matches API #/components/schemas/CreateClubRequest)
// ─────────────────────────────────────────────────────────────────────────────

class CreateClubRequest {
  final String email;
  final String password;
  final String fullName;
  final String clubName;
  final String? phoneNumber;
  final String? city;
  final String? address;
  final String? description;
  final String? logoUrl;

  const CreateClubRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.clubName,
    this.phoneNumber,
    this.city,
    this.address,
    this.description,
    this.logoUrl,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'fullName': fullName,
        'clubName': clubName,
        'phoneNumber': phoneNumber,
        'city': city,
        'address': address,
        'description': description,
        'logoUrl': logoUrl,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// UpdateClubRequest  (matches API #/components/schemas/UpdateClubRequest)
// ─────────────────────────────────────────────────────────────────────────────

class UpdateClubRequest {
  final String? name;
  final String? city;
  final String? address;
  final String? description;
  final String? phoneNumber;
  final String? adminId;

  const UpdateClubRequest({
    this.name,
    this.city,
    this.address,
    this.description,
    this.phoneNumber,
    this.adminId,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (city != null) 'city': city,
        if (address != null) 'address': address,
        if (description != null) 'description': description,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (adminId != null) 'adminId': adminId,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// MembershipActionRequest
// ─────────────────────────────────────────────────────────────────────────────

class MembershipActionRequest {
  final String action; // 'ACCEPT' | 'REJECT'

  const MembershipActionRequest({required this.action});

  Map<String, dynamic> toJson() => {'action': action};

  static MembershipActionRequest accept() =>
      const MembershipActionRequest(action: 'ACCEPT');

  static MembershipActionRequest reject() =>
      const MembershipActionRequest(action: 'REJECT');
}

// ─────────────────────────────────────────────────────────────────────────────
// PagedResponseClubResponse
// ─────────────────────────────────────────────────────────────────────────────

class PagedClubResponse {
  final List<Club> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;

  const PagedClubResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
  });

  factory PagedClubResponse.fromJson(Map<String, dynamic> json) =>
      PagedClubResponse(
        content: (json['content'] as List<dynamic>? ?? [])
            .map((e) => Club.fromJson(e as Map<String, dynamic>))
            .toList(),
        pageNumber: json['pageNumber'] ?? 0,
        pageSize: json['pageSize'] ?? 0,
        totalElements: json['totalElements'] ?? 0,
        totalPages: json['totalPages'] ?? 0,
        first: json['first'] ?? true,
        last: json['last'] ?? true,
      );
}

// Legacy alias so existing gym_controller references still resolve
@Deprecated('Use Club instead')
typedef Gym = Club;
