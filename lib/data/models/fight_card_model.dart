import 'package:flutter/material.dart';

enum FightStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

class FightCard {
  final String id;
  final String eventId;
  final String fighter1Id;
  final String fighter2Id;
  final String weightClass;
  final int? round;
  final String? winnerId;
  final String? method;
  final String? methodDetails;
  final FightStatus status;
  final int? order;
  final DateTime? scheduledTime;
  final DateTime? actualTime;
  final String? refereeId;
  final Map<String, dynamic>? fighter1Stats;
  final Map<String, dynamic>? fighter2Stats;
  
  FightCard({
    required this.id,
    required this.eventId,
    required this.fighter1Id,
    required this.fighter2Id,
    required this.weightClass,
    this.round,
    this.winnerId,
    this.method,
    this.methodDetails,
    required this.status,
    this.order,
    this.scheduledTime,
    this.actualTime,
    this.refereeId,
    this.fighter1Stats,
    this.fighter2Stats,
  });
  
  factory FightCard.fromJson(Map<String, dynamic> json) {
    return FightCard(
      id: json['id'].toString(),
      eventId: json['eventId'].toString(),
      fighter1Id: json['fighter1Id'].toString(),
      fighter2Id: json['fighter2Id'].toString(),
      weightClass: json['weightClass'],
      round: json['round'],
      winnerId: json['winnerId']?.toString(),
      method: json['method'],
      methodDetails: json['methodDetails'],
      status: _stringToStatus(json['status'] ?? 'scheduled'),
      order: json['order'],
      scheduledTime: json['scheduledTime'] != null ? DateTime.parse(json['scheduledTime']) : null,
      actualTime: json['actualTime'] != null ? DateTime.parse(json['actualTime']) : null,
      refereeId: json['refereeId'],
      fighter1Stats: json['fighter1Stats'],
      fighter2Stats: json['fighter2Stats'],
    );
  }
}
FightStatus _stringToStatus(String status) {
  switch (status) {
    case 'confirmed':
      return FightStatus.confirmed;
    case 'inProgress':
      return FightStatus.inProgress;
    case 'completed':
      return FightStatus.completed;
    case 'cancelled':
      return FightStatus.cancelled;
    default:
      return FightStatus.scheduled;
  }
}
