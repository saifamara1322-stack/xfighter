import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/modules/organizer/controllers/organizer_controller.dart';

class OrganizerDetailView extends GetView<OrganizerController> {
  final String organizerId;
  const OrganizerDetailView({super.key, required this.organizerId});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadOrganizerDetail(organizerId);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Organizer Detail',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF009688)));
        }
        final org = controller.selectedOrganizer.value;
        if (org == null) {
          return const Center(
              child: Text('Organizer not found',
                  style: TextStyle(color: Colors.white54)));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _card(
                title: 'Profile',
                accentColor: const Color(0xFF009688),
                child: Column(children: [
                  _row(Icons.person, 'Name', org.fullName),
                  _row(Icons.email, 'Email', org.email),
                  _row(Icons.phone, 'Phone', org.phoneNumber ?? '—'),
                  _row(Icons.badge, 'Role', org.role.displayName),
                  _row(Icons.circle, 'Status', org.status.displayName,
                      valueColor: org.status.color),
                  if (org.createdAt != null)
                    _row(Icons.calendar_today, 'Created',
                        _fmt(org.createdAt!)),
                ]),
              ),
              const SizedBox(height: 16),
              _card(
                title: 'Actions',
                accentColor: const Color(0xFF009688),
                child: Wrap(spacing: 8, runSpacing: 8, children: [
                  _btn('Block', Icons.block, Colors.orange,
                      () => controller.blockOrganizer(organizerId)),
                  _btn('Unblock', Icons.check_circle, Colors.green,
                      () => controller.unblockOrganizer(organizerId)),
                ]),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _card(
      {required String title,
      required Widget child,
      required Color accentColor}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }

  Widget _row(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, color: Colors.white38, size: 18),
        const SizedBox(width: 8),
        Text('$label:', style: const TextStyle(color: Colors.white54)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(value,
                style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Widget _btn(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.15),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10))),
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}
