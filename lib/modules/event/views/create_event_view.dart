import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../../../data/models/event_model.dart';

class CreateEventView extends StatelessWidget {
  final EventController _eventController = Get.find<EventController>();
  
  CreateEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: const Center(child: Text('Create event — coming soon')),
    );
  }
}
