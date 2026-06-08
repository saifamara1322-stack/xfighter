// ─────────────────────────────────────────────────────────────────────────────
// Tournament Models  (matches API /api/tournaments/* schemas)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// ── TournamentStatus ──────────────────────────────────────────────────────────

enum TournamentStatus {
  DRAFT,
  OPEN,
  CLOSED,
  CANCELLED,
  COMPLETED;

  static TournamentStatus fromString(String? value) {
    if (value == null) return TournamentStatus.DRAFT;
    try {
      return TournamentStatus.values.firstWhere(
        (e) => e.name == value.toUpperCase(),
        orElse: () => TournamentStatus.DRAFT,
      );
    } catch (_) {
      return TournamentStatus.DRAFT;
    }
  }

  String get displayName {
    switch (this) {
      case TournamentStatus.DRAFT:
        return 'Draft';
      case TournamentStatus.OPEN:
        return 'Open';
      case TournamentStatus.CLOSED:
        return 'Closed';
      case TournamentStatus.CANCELLED:
        return 'Cancelled';
      case TournamentStatus.COMPLETED:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case TournamentStatus.DRAFT:
        return Colors.grey;
      case TournamentStatus.OPEN:
        return Colors.green;
      case TournamentStatus.CLOSED:
        return Colors.orange;
      case TournamentStatus.CANCELLED:
        return Colors.red;
      case TournamentStatus.COMPLETED:
        return Colors.blue;
    }
  }

  List<TournamentStatus> get nextStatuses {
    switch (this) {
      case TournamentStatus.DRAFT:
        return [TournamentStatus.OPEN, TournamentStatus.CANCELLED];
      case TournamentStatus.OPEN:
        return [TournamentStatus.CLOSED, TournamentStatus.CANCELLED];
      case TournamentStatus.CLOSED:
        return [TournamentStatus.COMPLETED, TournamentStatus.CANCELLED];
      case TournamentStatus.CANCELLED:
      case TournamentStatus.COMPLETED:
        return [];
    }
  }
}

// ── TournamentResponse (matches the API response) ────────────────────────────

class Tournament {
  final String id;
  final String name;
  final String? description;
  final String level;               // "LOCAL", "REGIONAL", "NATIONAL", "INTERNATIONAL"
  final String countryId;
  final String organizerId;
  final String city;
  final String venue;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime registrationOpenAt;
  final DateTime registrationCloseAt;
  final TournamentStatus status;
  final DateTime? createdAt;

  const Tournament({
    required this.id,
    required this.name,
    this.description,
    required this.level,
    required this.countryId,
    required this.organizerId,
    required this.city,
    required this.venue,
    required this.startDate,
    required this.endDate,
    required this.registrationOpenAt,
    required this.registrationCloseAt,
    required this.status,
    this.createdAt,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) => Tournament(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        description: json['description'],
        level: json['level'] ?? 'LOCAL',
        countryId: json['countryId']?.toString() ?? '',
        organizerId: json['organizerId']?.toString() ?? '',
        city: json['city'] ?? '',
        venue: json['venue'] ?? '',
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        registrationOpenAt: DateTime.parse(json['registrationOpenAt']),
        registrationCloseAt: DateTime.parse(json['registrationCloseAt']),
        status: TournamentStatus.fromString(json['status']),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'level': level,
        'countryId': countryId,
        'organizerId': organizerId,
        'city': city,
        'venue': venue,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'registrationOpenAt': registrationOpenAt.toIso8601String(),
        'registrationCloseAt': registrationCloseAt.toIso8601String(),
        'status': status.name,
        'createdAt': createdAt?.toIso8601String(),
      };
}

// ── CreateTournamentRequest (matches the JSON you provided) ──────────────────

class CreateTournamentRequest {
  final String name;
  final String? description;
  final String level;
  final String countryId;
  final String organizerId;
  final String city;
  final String venue;
  final String startDate;           // ISO date string (YYYY-MM-DD)
  final String endDate;             // ISO date string (YYYY-MM-DD)
  final String registrationOpenAt;  // ISO datetime string
  final String registrationCloseAt; // ISO datetime string

  const CreateTournamentRequest({
    required this.name,
    this.description,
    required this.level,
    required this.countryId,
    required this.organizerId,
    required this.city,
    required this.venue,
    required this.startDate,
    required this.endDate,
    required this.registrationOpenAt,
    required this.registrationCloseAt,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
        'level': level,
        'countryId': countryId,
        'organizerId': organizerId,
        'city': city,
        'venue': venue,
        'startDate': startDate,
        'endDate': endDate,
        'registrationOpenAt': registrationOpenAt,
        'registrationCloseAt': registrationCloseAt,
      };
}

// ── UpdateTournamentRequest ───────────────────────────────────────────────────

class UpdateTournamentRequest {
  final String? name;
  final String? description;
  final String? level;
  final String? countryId;
  final String? city;
  final String? venue;
  final String? startDate;
  final String? endDate;
  final String? registrationOpenAt;
  final String? registrationCloseAt;
  final String? status;

  const UpdateTournamentRequest({
    this.name,
    this.description,
    this.level,
    this.countryId,
    this.city,
    this.venue,
    this.startDate,
    this.endDate,
    this.registrationOpenAt,
    this.registrationCloseAt,
    this.status,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (level != null) 'level': level,
        if (countryId != null) 'countryId': countryId,
        if (city != null) 'city': city,
        if (venue != null) 'venue': venue,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        if (registrationOpenAt != null) 'registrationOpenAt': registrationOpenAt,
        if (registrationCloseAt != null) 'registrationCloseAt': registrationCloseAt,
        if (status != null) 'status': status,
      };
}

// ── TournamentRuleResponse ────────────────────────────────────────────────────

class TournamentRule {
  final String id;
  final String tournamentId;
  final String ruleType;
  final String description;

  const TournamentRule({
    required this.id,
    required this.tournamentId,
    required this.ruleType,
    required this.description,
  });

  factory TournamentRule.fromJson(Map<String, dynamic> json) => TournamentRule(
        id: json['id']?.toString() ?? '',
        tournamentId: json['tournamentId']?.toString() ?? '',
        ruleType: json['ruleType'] ?? '',
        description: json['description'] ?? '',
      );
}

class CreateTournamentRuleRequest {
  final String ruleType;
  final String description;

  const CreateTournamentRuleRequest({
    required this.ruleType,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'ruleType': ruleType,
        'description': description,
      };
}

// ── TournamentCategoryResponse (Division) ─────────────────────────────────────

class TournamentDivision {
  final String id;
  final String tournamentId;
  final String? categoryId;
  final String? categoryName;
  final String? sportId;
  final String? gender;
  final double? weightMin;
  final double? weightMax;
  final int? ageMin;
  final int? ageMax;
  final int? maxParticipants;

  const TournamentDivision({
    required this.id,
    required this.tournamentId,
    this.categoryId,
    this.categoryName,
    this.sportId,
    this.gender,
    this.weightMin,
    this.weightMax,
    this.ageMin,
    this.ageMax,
    this.maxParticipants,
  });

  factory TournamentDivision.fromJson(Map<String, dynamic> json) =>
      TournamentDivision(
        id: json['id']?.toString() ?? '',
        tournamentId: json['tournamentId']?.toString() ?? '',
        categoryId: json['categoryId']?.toString(),
        categoryName: json['categoryName'],
        sportId: json['sportId']?.toString(),
        gender: json['gender'],
        weightMin: (json['weightMin'] as num?)?.toDouble(),
        weightMax: (json['weightMax'] as num?)?.toDouble(),
        ageMin: json['ageMin'] as int?,
        ageMax: json['ageMax'] as int?,
        maxParticipants: json['maxParticipants'] as int?,
      );
}

class CreateTournamentDivisionRequest {
  final String? categoryId;
  final String? gender;
  final double? weightMin;
  final double? weightMax;
  final int? ageMin;
  final int? ageMax;
  final int? maxParticipants;

  const CreateTournamentDivisionRequest({
    this.categoryId,
    this.gender,
    this.weightMin,
    this.weightMax,
    this.ageMin,
    this.ageMax,
    this.maxParticipants,
  });

  Map<String, dynamic> toJson() => {
        if (categoryId != null) 'categoryId': categoryId,
        if (gender != null) 'gender': gender,
        if (weightMin != null) 'weightMin': weightMin,
        if (weightMax != null) 'weightMax': weightMax,
        if (ageMin != null) 'ageMin': ageMin,
        if (ageMax != null) 'ageMax': ageMax,
        if (maxParticipants != null) 'maxParticipants': maxParticipants,
      };
}

// ── TournamentRegistrationResponse ───────────────────────────────────────────

class TournamentRegistration {
  final String id;
  final String tournamentId;
  final String fighterId;
  final String? fighterName;
  final String? divisionId;
  final String? divisionName;
  final String? status;
  final DateTime? registeredAt;

  const TournamentRegistration({
    required this.id,
    required this.tournamentId,
    required this.fighterId,
    this.fighterName,
    this.divisionId,
    this.divisionName,
    this.status,
    this.registeredAt,
  });

  factory TournamentRegistration.fromJson(Map<String, dynamic> json) =>
      TournamentRegistration(
        id: json['id']?.toString() ?? '',
        tournamentId: json['tournamentId']?.toString() ?? '',
        fighterId: json['fighterId']?.toString() ?? '',
        fighterName: json['fighterName'],
        divisionId: json['divisionId']?.toString(),
        divisionName: json['divisionName'],
        status: json['status'],
        registeredAt: json['registeredAt'] != null
            ? DateTime.tryParse(json['registeredAt'])
            : null,
      );
}

class CreateTournamentRegistrationRequest {
  final String fighterId;
  final String? divisionId;

  const CreateTournamentRegistrationRequest({
    required this.fighterId,
    this.divisionId,
  });

  Map<String, dynamic> toJson() => {
        'fighterUserId': fighterId,
        if (divisionId != null) 'tournamentCategoryId': divisionId,
      };
}