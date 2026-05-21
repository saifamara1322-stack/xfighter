import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/event_controller.dart';
import '../../registration/controllers/registration_controller.dart';

class EventDetailView extends StatelessWidget {
  final String eventId;
  final EventController _eventController = Get.find<EventController>();
  final AuthController _authController = Get.find<AuthController>();
  final RegistrationController _registrationController =
      Get.find<RegistrationController>();

  EventDetailView({super.key, required this.eventId});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventController.loadEventDetails(eventId);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Event details')),
      body: Obx(() {
        if (_eventController.isLoading.value &&
            _eventController.selectedEvent.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final event = _eventController.selectedEvent.value;
        if (event == null) {
          return const Center(child: Text('Event not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(_formatDate(event.date),
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text('${event.location} · ${event.venue}')),
                ],
              ),
              const SizedBox(height: 16),
              if (event.description != null && event.description!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Description',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(event.description!),
                    const SizedBox(height: 16),
                  ],
                ),
              if (event.organizerId != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Organizer ID',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(event.organizerId!),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }
}
