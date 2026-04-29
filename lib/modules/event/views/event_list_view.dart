import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../../../data/models/event_model.dart';
import 'event_detail_view.dart';
import 'create_event_view.dart';

class EventListView extends StatelessWidget {
  final EventController _eventController = Get.put(EventController());

  EventListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: const Center(child: Text('Events — coming soon')),
    );
  }
}
