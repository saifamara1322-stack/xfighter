import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/event_model.dart';
import 'event_detail_view.dart';
import 'create_event_view.dart';

class EventListView extends StatelessWidget {
  final EventController _eventController = Get.put(EventController());
  final AuthController _authController = Get.find<AuthController>();
  
  EventListView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _authController.isOrganizer() ? 3 : 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          title: const Text(
            'EVENTS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: const Color(0xFFE31837),
            labelColor: const Color(0xFFE31837),
            unselectedLabelColor: Colors.white54,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            tabs: [
              const Tab(text: 'UPCOMING'),
              const Tab(text: 'ALL'),
              if (_authController.isOrganizer()) const Tab(text: 'MY EVENTS'),
            ],
          ),
          actions: [
            if (_authController.isOrganizer())
              Container(
                margin: const EdgeInsets.only(right: 12),
                child: FloatingActionButton(
                  mini: true,
                  onPressed: () => _showCreateEventDialog(),
                  backgroundColor: const Color(0xFFE31837),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
          ],
        ),
        body: Obx(() {
          if (_eventController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE31837)),
              ),
            );
          }
          
          return TabBarView(
            children: [
              _buildUpcomingEventsTab(),
              _buildAllEventsTab(),
              if (_authController.isOrganizer()) _buildOrganizerEventsTab(),
            ],
          );
        }),
      ),
    );
  }
  
  Widget _buildUpcomingEventsTab() {
    if (_eventController.upcomingEvents.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_busy,
        title: 'NO UPCOMING EVENTS',
        subtitle: 'Check back later for new fight nights',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _eventController.upcomingEvents.length,
      itemBuilder: (context, index) {
        final event = _eventController.upcomingEvents[index];
        return _buildEventCard(event);
      },
    );
  }
  
  Widget _buildAllEventsTab() {
    if (_eventController.events.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_note,
        title: 'NO EVENTS',
        subtitle: 'Events will appear here once created',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _eventController.events.length,
      itemBuilder: (context, index) {
        final event = _eventController.events[index];
        return _buildEventCard(event);
      },
    );
  }
  
  Widget _buildOrganizerEventsTab() {
    if (_eventController.organizerEvents.isEmpty) {
      return _buildEmptyState(
        icon: Icons.add_circle_outline,
        title: 'NO EVENTS CREATED',
        subtitle: 'Create your first event to get started',
        showButton: true,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _eventController.organizerEvents.length,
      itemBuilder: (context, index) {
        final event = _eventController.organizerEvents[index];
        return _buildEventCard(event, showStatus: true);
      },
    );
  }
  
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showButton = false,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFE31837).withOpacity(0.1),
                  const Color(0xFFB8102E).withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE31837).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 60,
              color: const Color(0xFFE31837),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: const Color(0xFFE31837).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE31837).withOpacity(0.3),
              ),
            ),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white54,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (showButton) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateEventDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'CREATE EVENT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31837),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildEventCard(Event event, {bool showStatus = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.to(() => EventDetailView(eventId: event.id)),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Event Icon - Octagon style
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE31837), Color(0xFFB8102E)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE31837).withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.sports_mma,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Event Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Date row
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: const Color(0xFFE31837),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          event.formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Location and price row
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          event.city,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.attach_money,
                          size: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${event.ticketPrice} TND',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    
                    if (showStatus) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: event.statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: event.statusColor.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(event.statusDisplay),
                              size: 10,
                              color: event.statusColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              event.statusDisplay.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: event.statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // VS Arrow
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE31837).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFE31837),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
  
  void _showCreateEventDialog() {
    Get.dialog(
      CreateEventView(),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
    );
  }
}