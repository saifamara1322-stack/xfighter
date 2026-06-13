import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/event_controller.dart';
import '../../../data/models/tournament_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/fighter_model.dart';
import '../../../data/models/category_model.dart';

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
              const SizedBox(height: 16),

              if (!canManage && _eventController.isParticipant) ...[
                _buildParticipantRegistrationBanner(event),
                const SizedBox(height: 16),
              ],
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
              if (!canManage &&
                  _eventController.isParticipant &&
                  _eventController.isRegistrationWindowOpen(event))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _participantRegistrationHint(
                        _authController.currentUser.value?.role),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              _buildDivisionsList(event, canManage),
              const SizedBox(height: 24),

              if (!canManage && _eventController.canRegisterOthers)
                _buildClubCoachRegistrationSection(event),

              if (!canManage &&
                  _authController.currentUser.value?.role == UserRole.FIGHTER)
                _buildMyRegistrationsSection(),

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
    final actions = <({String label, String status})>[];

    switch (event.status) {
      case TournamentStatus.DRAFT:
        actions.add((label: 'Open Registrations', status: 'OPEN'));
        actions.add((label: 'Cancel', status: 'CANCELLED'));
        break;
      case TournamentStatus.OPEN:
        actions.add((label: 'Close Registrations', status: 'CLOSED'));
        actions.add((label: 'Cancel', status: 'CANCELLED'));
        break;
      case TournamentStatus.CLOSED:
        actions.add((label: 'Start Tournament', status: 'IN_PROGRESS'));
        actions.add((label: 'Reopen Registrations', status: 'OPEN'));
        actions.add((label: 'Cancel', status: 'CANCELLED'));
        break;
      case TournamentStatus.IN_PROGRESS:
        actions.add((label: 'Complete Tournament', status: 'COMPLETED'));
        break;
      case TournamentStatus.CANCELLED:
      case TournamentStatus.COMPLETED:
        break;
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Manage Status',
            style: TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: actions.map((action) {
            final color = TournamentStatus.fromString(action.status).color;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withOpacity(0.2),
                foregroundColor: color,
                side: BorderSide(color: color),
                elevation: 0,
              ),
              onPressed: () {
                _eventController.changeStatus(event.id, action.status);
              },
              child: Text(action.label),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _participantRegistrationHint(UserRole? role) {
    switch (role) {
      case UserRole.FIGHTER:
        return 'Tap Register on a division below to enter this tournament.';
      case UserRole.COACH:
        return 'Register your athletes for open divisions using the button on each row.';
      case UserRole.CLUB:
        return 'Register club fighters for open divisions using the button on each row.';
      default:
        return 'Select a division to register.';
    }
  }

  Widget _buildParticipantRegistrationBanner(Tournament event) {
    final open = _eventController.isRegistrationWindowOpen(event);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: open
            ? Colors.green.withOpacity(0.12)
            : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: open ? Colors.green.withOpacity(0.4) : Colors.orange.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            open ? Icons.lock_open : Icons.lock_clock,
            color: open ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  open ? 'Registrations Open' : 'Registrations Closed',
                  style: TextStyle(
                    color: open ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  open
                      ? 'Closes ${_formatDate(event.registrationCloseAt)}'
                      : event.status == TournamentStatus.OPEN
                          ? 'Opens ${_formatDate(event.registrationOpenAt)}'
                          : 'Status: ${event.status.displayName}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivisionsList(Tournament event, bool canManage) {
    if (_eventController.eventDivisions.isEmpty) {
      return const Text('No divisions configured yet.',
          style: TextStyle(color: Colors.white54));
    }
    final role = _authController.currentUser.value?.role;
    final isFighter = role == UserRole.FIGHTER;
    final canRegisterClubCoach = _eventController.canRegisterOthers;
    final isRegistrationOpen = _eventController.isRegistrationWindowOpen(event);
    final currentUserId = _authController.currentUser.value?.id;

    return Column(
      children: _eventController.eventDivisions.map((d) {
        Widget? trailingWidget;

        if (isFighter && isRegistrationOpen) {
          final existing = currentUserId != null
              ? _eventController.registrationForFighter(currentUserId, d.id)
              : null;
          if (existing != null) {
            trailingWidget = Chip(
              label: Text(existing.status ?? 'REGISTERED',
                  style: const TextStyle(fontSize: 11)),
              backgroundColor: Colors.orange.withOpacity(0.2),
            );
          } else {
            trailingWidget = ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE31837)),
              onPressed: () =>
                  _eventController.registerForTournament(event.id, d.id),
              child: const Text('Register',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            );
          }
        } else if (canRegisterClubCoach && isRegistrationOpen) {
          trailingWidget = ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31837)),
            onPressed: () => _showRegisterFighterDialog(event.id, d),
            child: Text(
              role == UserRole.CLUB ? 'Register Fighter' : 'Register Athlete',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
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

  Widget _buildClubCoachRegistrationSection(Tournament event) {
    if (!_eventController.isRegistrationWindowOpen(event)) {
      return const SizedBox.shrink();
    }
    return Obx(() {
      final fighters = _eventController.registerableFighters;
      if (fighters.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF141424),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'No fighters available to register. Add fighters to your club first.',
            style: TextStyle(color: Colors.white54),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Your Registrations'),
          ...fighters.expand((f) {
            final regs = _eventController.eventRegistrations
                .where((r) => r.fighterId == f.id)
                .toList();
            if (regs.isEmpty) return <Widget>[];
            return regs.map((r) => Card(
                  color: const Color(0xFF141424),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(f.fullName,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      'Division: ${r.divisionName ?? '—'}',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: Text(
                      r.status ?? 'PENDING',
                      style: const TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                ));
          }),
        ],
      );
    });
  }

  Widget _buildMyRegistrationsSection() {
    final userId = _authController.currentUser.value?.id;
    if (userId == null) return const SizedBox.shrink();

    final myRegs = _eventController.eventRegistrations
        .where((r) => r.fighterId == userId)
        .toList();
    if (myRegs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('My Registration'),
        ...myRegs.map((r) => Card(
              color: const Color(0xFF141424),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(r.divisionName ?? 'Division',
                    style: const TextStyle(color: Colors.white)),
                trailing: Text(
                  r.status ?? 'PENDING',
                  style: TextStyle(
                    color: (r.status ?? '').toUpperCase() == 'APPROVED'
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showRegisterFighterDialog(String eventId, TournamentDivision division) {
    final fighters = _eventController.registerableFighters;
    final emailCtrl = TextEditingController();
    var useEmail = fighters.isEmpty;
    Fighter? selected = fighters.isNotEmpty ? fighters.first : null;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Register Fighter',
            style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Division: ${division.categoryName ?? division.id}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  if (fighters.isNotEmpty) ...[
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('My list'),
                          selected: !useEmail,
                          onSelected: (_) => setState(() => useEmail = false),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('By email'),
                          selected: useEmail,
                          onSelected: (_) => setState(() => useEmail = true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (!useEmail && fighters.isNotEmpty)
                    DropdownButtonFormField<Fighter>(
                      dropdownColor: const Color(0xFF1A1A2E),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Select fighter',
                        labelStyle: TextStyle(color: Colors.white54),
                      ),
                      value: selected,
                      items: fighters.map((f) {
                        final reg = _eventController.registrationForFighter(
                            f.id, division.id);
                        return DropdownMenuItem(
                          value: f,
                          enabled: reg == null,
                          child: Text(
                            reg != null
                                ? '${f.fullName} (${reg.status})'
                                : '${f.fullName} — ${f.email}',
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => selected = v),
                    )
                  else
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Fighter email',
                        hintText: 'fighter@example.com',
                        labelStyle: TextStyle(color: Colors.white54),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31837)),
            onPressed: () {
              if (useEmail || fighters.isEmpty) {
                final email = emailCtrl.text.trim();
                if (email.isEmpty) {
                  Get.snackbar('Required', 'Enter fighter email',
                      backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }
                Get.back();
                _eventController.registerFighterByEmailForTournament(
                  eventId,
                  division.id,
                  email,
                );
                return;
              }
              if (selected == null) return;
              final reg = _eventController.registrationForFighter(
                  selected!.id, division.id);
              if (reg != null) {
                Get.snackbar(
                  'Already registered',
                  '${selected!.fullName} is already registered',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }
              Get.back();
              _eventController.registerForTournament(
                eventId,
                division.id,
                fighterUserId: selected!.id,
              );
            },
            child: const Text('Register', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
        final isPending = (r.status ?? '').toUpperCase() == 'PENDING';
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
            trailing: isPending
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () =>
                            _eventController.approveRegistration(r.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _showRejectDialog(r.id),
                      ),
                    ],
                  )
                : Text(r.status ?? 'PENDING',
                    style: const TextStyle(color: Colors.orange, fontSize: 12)),
          ),
        );
      }).toList(),
    );
  }

  void _showRejectDialog(String registrationId) {
    final reasonController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Reject Registration',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: reasonController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Reason',
            labelStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31837)),
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              Get.back();
              _eventController.rejectRegistration(
                  registrationId, reasonController.text.trim());
            },
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
    final maxPController = TextEditingController(text: '16');
    final selectedCategory = Rx<Category?>(null);

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Add Division', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                final cats = _eventController.categories;
                if (cats.isEmpty) {
                  return const Text(
                    'No categories loaded. Create categories in Admin first.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  );
                }
                return DropdownButtonFormField<Category>(
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Sport Category *',
                    labelStyle: TextStyle(color: Colors.white54),
                  ),
                  value: selectedCategory.value,
                  items: cats
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: (v) => selectedCategory.value = v,
                );
              }),
              const SizedBox(height: 12),
              TextField(
                  controller: genderController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Gender (MALE/FEMALE)',
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
              TextField(
                  controller: maxPController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Max Participants',
                      labelStyle: TextStyle(color: Colors.white54))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31837)),
            onPressed: () {
              if (selectedCategory.value == null) {
                Get.snackbar('Required', 'Select a sport category',
                    backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }
              _eventController.createDivision(
                eventId,
                sportCategoryId: selectedCategory.value!.id,
                gender: genderController.text.trim().isNotEmpty
                    ? genderController.text.trim().toUpperCase()
                    : null,
                minW: double.tryParse(minWController.text),
                maxW: double.tryParse(maxWController.text),
                maxParticipants: int.tryParse(maxPController.text),
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