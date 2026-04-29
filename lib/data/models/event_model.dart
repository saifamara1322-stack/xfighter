import 'package:flutter/material.dart';

// Re-export the canonical registration model so existing imports of event_model.dart
// that reference EnhancedEventRegistration / RegistrationStatus / EventStatus still work.
export 'package:xfighter/data/models/enhanced_event_registration.dart'
    show EnhancedEventRegistration, RegistrationStatus, EventStatus;

class Event {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String venue;
  final String? description;
  final String? organizerId;

  const Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.venue,
    this.description,
    this.organizerId,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        date: json['date'] != null
            ? DateTime.tryParse(json['date']) ?? DateTime.now()
            : DateTime.now(),
        location: json['location'] ?? '',
        venue: json['venue'] ?? '',
        description: json['description'],
        organizerId: json['organizerId']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
        'location': location,
        'venue': venue,
        'description': description,
        'organizerId': organizerId,
      };
}
