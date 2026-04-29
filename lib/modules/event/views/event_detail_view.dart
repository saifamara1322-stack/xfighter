import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/event_controller.dart';
import '../../registration/controllers/registration_controller.dart';
import '../../../data/models/event_model.dart';

class EventDetailView extends StatelessWidget {
  final String eventId;
  final EventController _eventController = Get.find<EventController>();
  final AuthController _authController = Get.find<AuthController>();
  final RegistrationController _registrationController = Get.find<RegistrationController>();
  
  EventDetailView({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event $eventId')),
      body: const Center(child: Text('Event detail — coming soon')),
    );
  }
}
