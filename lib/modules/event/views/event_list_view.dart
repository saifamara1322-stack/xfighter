import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/core/routes/app_router.dart';
import '../controllers/event_controller.dart';
import '../../../data/models/tournament_model.dart';
import '../../../data/models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';

class EventListView extends StatelessWidget {
  final EventController _eventController = Get.put(EventController());
  final AuthController _authController = Get.put(AuthController());

  EventListView({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final role = _authController.currentUser.value?.role;
      final showTabs = role == UserRole.FIGHTER || role == UserRole.ORGANIZER;
      final isOrganizer = role == UserRole.ORGANIZER || role == UserRole.ADMIN || role == UserRole.SUPER_ADMIN;

      Widget content = Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D0D1A),
          elevation: 0,
          title: showTabs
              ? const TabBar(
                  indicatorColor: Color(0xFFE31837),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: 'All Tournaments'),
                    Tab(text: 'My Tournaments'),
                  ],
                )
              : null,
        ),
        floatingActionButton: isOrganizer
            ? FloatingActionButton(
                onPressed: () => Get.toNamed(AppRouter.createEvent),
                backgroundColor: const Color(0xFFE31837),
                child: const Icon(Icons.add, color: Colors.white),
              )
            : const SizedBox.shrink(),
        body: Obx(() {
          if (_eventController.isLoading.value && _eventController.events.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE31837)));
          }

          if (showTabs) {
            final myEvents = role == UserRole.FIGHTER
                ? _eventController.myRegisteredEvents
                : _eventController.organizerEvents;
            return TabBarView(
              children: [
                _buildEventList(_eventController.events),
                _buildEventList(myEvents),
              ],
            );
          } else {
            return _buildEventList(_eventController.events);
          }
        }),
      );

      if (showTabs) {
        return DefaultTabController(length: 2, child: content);
      }
      return content;
    });
  }

  Widget _buildEventList(List<Tournament> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.emoji_events, size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Text('No tournaments available yet.', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text('Pull to refresh.', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFE31837),
      backgroundColor: const Color(0xFF14213D),
      onRefresh: _eventController.loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final isRegistered =
              _eventController.myRegisteredEvents.any((e) => e.id == event.id);

          return Card(
            color: const Color(0xFF1A1A2E),
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isRegistered
                  ? BorderSide(color: Colors.green.withOpacity(0.5), width: 2)
                  : BorderSide.none,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
            onTap: () {
  final role = Get.find<AuthController>().currentUser.value?.role;
  if (role == null) return;
  Get.toNamed(
    AppRouter.eventDetail.replaceAll(':id', event.id),
  );
},
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (isRegistered)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(Icons.check_circle,
                                      color: Colors.green, size: 16),
                                ),
                              Expanded(
                                child: Text(
                                  event.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: event.status.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: event.status.color),
                          ),
                          child: Text(
                            event.status.displayName,
                            style: TextStyle(
                                color: event.status.color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.white54),
                        const SizedBox(width: 6),
                        Text(event.city ?? 'Unknown location',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.white54),
                        const SizedBox(width: 6),
                        Text(_formatDate(event.startDate),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    if (event.level != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.sports_mma,
                              size: 14, color: Colors.white54),
                          const SizedBox(width: 6),
                          Text(event.level!,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
