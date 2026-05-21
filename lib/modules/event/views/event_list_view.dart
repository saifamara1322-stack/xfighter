import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/core/routes/app_router.dart';
import '../controllers/event_controller.dart';
import '../../../data/models/event_model.dart';

class EventListView extends StatelessWidget {
  final EventController _eventController = Get.find<EventController>();

  EventListView({super.key});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRouter.createEvent),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (_eventController.isLoading.value &&
            _eventController.events.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = _eventController.events;
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.event, size: 72, color: Colors.grey),
                SizedBox(height: 16),
                Text('No events available yet.'),
                SizedBox(height: 8),
                Text('Pull to refresh or add a new event.'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _eventController.loadEvents,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                  title: Text(event.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(event.description ?? 'No description provided.'),
                      const SizedBox(height: 6),
                      Text('${event.location} · ${event.venue}'),
                      Text(_formatDate(event.date)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Get.toNamed(
                    AppRouter.eventDetail.replaceAll(':id', event.id),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
