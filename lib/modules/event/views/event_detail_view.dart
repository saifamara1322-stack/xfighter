import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/event_controller.dart';
import '../../../data/models/tournament_model.dart';
import '../../../data/models/user_model.dart';

class EventDetailView extends StatelessWidget {
  final String eventId;
  final EventController _eventController = Get.find<EventController>();
  final AuthController _authController = Get.find<AuthController>();

  EventDetailView({super.key, required this.eventId});

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getLevelDisplay(String level) {
    switch (level.toUpperCase()) {
      case 'LOCAL':
        return 'Local';
      case 'REGIONAL':
        return 'Regional';
      case 'NATIONAL':
        return 'National';
      case 'INTERNATIONAL':
        return 'International';
      default:
        return level;
    }
  }

  String _getCountryName(String countryId) {
    final country = _eventController.countries.firstWhereOrNull((c) => c.id == countryId);
    return country?.name ?? countryId;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventController.loadEventDetails(eventId);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Tournament Details'),
        backgroundColor: const Color(0xFF0D0D1A),
        elevation: 0,
        actions: [
          Obx(() {
            final currentUser = _authController.currentUser.value;
            final bool canManage = currentUser?.role == UserRole.ORGANIZER ||
                currentUser?.role == UserRole.SUPER_ADMIN ||
                currentUser?.role == UserRole.ADMIN;
            if (canManage && _eventController.selectedEvent.value != null) {
              return IconButton(
                icon: const Icon(Icons.delete, color: Color(0xFFE31837)),
                onPressed: () {
                  Get.dialog(AlertDialog(
                    backgroundColor: const Color(0xFF1A1A2E),
                    title: const Text('Delete Tournament',
                        style: TextStyle(color: Colors.white)),
                    content: const Text(
                        'Are you sure you want to delete this tournament?',
                        style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE31837)),
                        onPressed: () {
                          Get.back();
                          _eventController.deleteEvent(eventId);
                        },
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ));
                },
              );
            }
            return const SizedBox.shrink();
          })
        ],
      ),
      body: Obx(() {
        if (_eventController.isDetailLoading.value &&
            _eventController.selectedEvent.value == null) {
          return const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFFE31837)));
        }

        final event = _eventController.selectedEvent.value;
        if (event == null) {
          return const Center(
              child: Text('Tournament not found',
                  style: TextStyle(color: Colors.white70)));
        }

        final currentUser = _authController.currentUser.value;
        final bool canManage = currentUser?.role == UserRole.ORGANIZER ||
            currentUser?.role == UserRole.SUPER_ADMIN ||
            currentUser?.role == UserRole.ADMIN;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(event),
              const SizedBox(height: 24),

              if (canManage) _buildLifecycleButtons(event),
              if (canManage) const SizedBox(height: 24),

              _buildSectionTitle('Description'),
              Text(event.description ?? 'No description provided.',
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),

              _buildSectionTitle(
                  'Divisions (${_eventController.eventDivisions.length})',
                  onAdd: canManage
                      ? () => _showAddDivisionDialog(context, event.id)
                      : null),
              _buildDivisionsList(event, canManage),
              const SizedBox(height: 24),

              _buildSectionTitle('Rules (${_eventController.eventRules.length})',
                  onAdd: canManage
                      ? () => _showAddRuleDialog(context, event.id)
                      : null),
              _buildRulesList(canManage),
              const SizedBox(height: 24),

              if (canManage) ...[
                _buildSectionTitle(
                    'Registrations (${_eventController.eventRegistrations.length})'),
                _buildRegistrationsList(),
              ]
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(Tournament event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.name,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: event.status.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: event.status.color),
                ),
                child: Text(
                  event.status.displayName,
                  style: TextStyle(
                      color: event.status.color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.location_city, 'City: ${event.city}'),
          const SizedBox(height: 8),
          _infoRow(Icons.location_on, 'Venue: ${event.venue}'),
          const SizedBox(height: 8),
          _infoRow(Icons.trending_up, 'Level: ${_getLevelDisplay(event.level)}'),
          const SizedBox(height: 8),
          _infoRow(Icons.flag, 'Country: ${_getCountryName(event.countryId)}'),
          const SizedBox(height: 8),
          _infoRow(Icons.calendar_today,
              'Start: ${_formatDate(event.startDate)}'),
          const SizedBox(height: 8),
          _infoRow(Icons.event_busy, 'End: ${_formatDate(event.endDate)}'),
          const SizedBox(height: 8),
          _infoRow(Icons.lock_open,
              'Registration Opens: ${_formatDate(event.registrationOpenAt)}'),
          const SizedBox(height: 8),
          _infoRow(Icons.lock,
              'Registration Closes: ${_formatDate(event.registrationCloseAt)}'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onAdd}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          if (onAdd != null)
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFFE31837)),
              onPressed: onAdd,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildLifecycleButtons(Tournament event) {
    final nextStatuses = event.status.nextStatuses;
    if (nextStatuses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Manage Status',
            style: TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: nextStatuses.map((status) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: status.color.withOpacity(0.2),
                foregroundColor: status.color,
                side: BorderSide(color: status.color),
                elevation: 0,
              ),
              onPressed: () {
                _eventController.changeStatus(event.id, status.name);
              },
              child: Text('Set to ${status.displayName}'),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDivisionsList(Tournament event, bool canManage) {
    if (_eventController.eventDivisions.isEmpty) {
      return const Text('No divisions configured yet.',
          style: TextStyle(color: Colors.white54));
    }
    final isFighter = _authController.currentUser.value?.role == UserRole.FIGHTER;
    final now = DateTime.now();
    final isRegistrationOpen =
        now.isAfter(event.registrationOpenAt) && now.isBefore(event.registrationCloseAt);

    return Column(
      children: _eventController.eventDivisions.map((d) {
        Widget? trailingWidget;
        if (isFighter && event.status == TournamentStatus.OPEN && isRegistrationOpen) {
          trailingWidget = ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31837)),
            onPressed: () => _eventController.registerForTournament(event.id, d.id),
            child: const Text('Register',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          );
        } else if (canManage) {
          trailingWidget = IconButton(
            icon: const Icon(Icons.delete, color: Colors.white38),
            onPressed: () => _eventController.deleteDivision(d.id),
          );
        }

        return Card(
          color: const Color(0xFF141424),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(d.categoryName ?? 'Unknown Category',
                style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              'Gender: ${d.gender ?? 'Any'} | Age: ${d.ageMin ?? 0}-${d.ageMax ?? 99} | Weight: ${d.weightMin ?? 0}kg-${d.weightMax ?? 999}kg',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: trailingWidget,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRulesList(bool canManage) {
    if (_eventController.eventRules.isEmpty) {
      return const Text('No rules configured yet.',
          style: TextStyle(color: Colors.white54));
    }
    return Column(
      children: _eventController.eventRules.map((r) {
        return Card(
          color: const Color(0xFF141424),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(r.ruleType, style: const TextStyle(color: Colors.white)),
            subtitle: Text(r.description, style: const TextStyle(color: Colors.white70)),
            trailing: canManage
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white38),
                    onPressed: () => _eventController.deleteRule(r.id),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRegistrationsList() {
    if (_eventController.eventRegistrations.isEmpty) {
      return const Text('No fighters registered yet.',
          style: TextStyle(color: Colors.white54));
    }
    return Column(
      children: _eventController.eventRegistrations.map((r) {
        return Card(
          color: const Color(0xFF141424),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
                backgroundColor: Color(0xFFE31837),
                child: Icon(Icons.person, color: Colors.white)),
            title: Text(r.fighterName ?? 'Unknown Fighter',
                style: const TextStyle(color: Colors.white)),
            subtitle: Text('Division: ${r.divisionName ?? 'Unassigned'}',
                style: const TextStyle(color: Colors.white54)),
            trailing: Text(r.status ?? 'PENDING',
                style: const TextStyle(color: Colors.orange, fontSize: 12)),
          ),
        );
      }).toList(),
    );
  }

  void _showAddRuleDialog(BuildContext context, String eventId) {
    final typeController = TextEditingController();
    final descController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Add Rule', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: typeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Rule Type',
                    labelStyle: TextStyle(color: Colors.white54))),
            TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.white54))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31837)),
            onPressed: () {
              _eventController.createRule(
                  eventId, typeController.text, descController.text);
              Get.back();
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showAddDivisionDialog(BuildContext context, String eventId) {
    final genderController = TextEditingController();
    final minWController = TextEditingController();
    final maxWController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Add Division', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: genderController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Gender (M/F)',
                    labelStyle: TextStyle(color: Colors.white54))),
            TextField(
                controller: minWController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Min Weight (kg)',
                    labelStyle: TextStyle(color: Colors.white54))),
            TextField(
                controller: maxWController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Max Weight (kg)',
                    labelStyle: TextStyle(color: Colors.white54))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31837)),
            onPressed: () {
              _eventController.createDivision(
                eventId,
                'New Category',
                genderController.text.isNotEmpty ? genderController.text : null,
                double.tryParse(minWController.text),
                double.tryParse(maxWController.text),
              );
              Get.back();
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}