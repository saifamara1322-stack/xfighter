import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/modules/organizer/controllers/organizer_controller.dart';
import 'package:xfighter/data/models/user_model.dart';

class OrganizerListView extends GetView<OrganizerController> {
  const OrganizerListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Organizer Management',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadOrganizers,
          ),
        ],
      ),
      body: Column(
        children: [
          _StatsBar(),
          Expanded(child: _OrganizerList()),
          _PaginationBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: const Color(0xFF009688),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('New Organizer', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    Get.dialog(_CreateOrganizerDialog(), barrierDismissible: false);
  }
}

class _StatsBar extends GetView<OrganizerController> {
  const _StatsBar();
  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          color: const Color(0xFF1A1A2E),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.people, color: Color(0xFF009688), size: 16),
              const SizedBox(width: 6),
              Text(
                '${controller.totalElements.value} organizers total',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ));
  }
}

class _OrganizerList extends GetView<OrganizerController> {
  const _OrganizerList();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF009688)));
      }
      if (controller.organizers.isEmpty) {
        return const Center(
            child: Text('No organizers found',
                style: TextStyle(color: Colors.white54)));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.organizers.length,
        itemBuilder: (_, i) => _OrganizerCard(user: controller.organizers[i]),
      );
    });
  }
}

class _OrganizerCard extends GetView<OrganizerController> {
  final User user;
  const _OrganizerCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A2E),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF009688).withOpacity(0.2),
          child: Text(
            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
            style: const TextStyle(
                color: Color(0xFF009688), fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(user.fullName,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email,
                style: const TextStyle(color: Colors.white60, fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: user.status.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(user.status.displayName,
                  style:
                      TextStyle(color: user.status.color, fontSize: 11)),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: const Color(0xFF1A1A2E),
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          onSelected: (action) => _handleAction(action),
          itemBuilder: (_) => [
            const PopupMenuItem(
                value: 'detail',
                child: Text('View Detail',
                    style: TextStyle(color: Colors.white))),
            if (user.status == UserStatus.DISABLED)
              const PopupMenuItem(
                  value: 'unblock',
                  child: Text('Unblock',
                      style: TextStyle(color: Colors.green)))
            else
              const PopupMenuItem(
                  value: 'block',
                  child: Text('Block',
                      style: TextStyle(color: Colors.orange))),
          ],
        ),
      ),
    );
  }

  void _handleAction(String action) {
    switch (action) {
      case 'detail':
        Get.toNamed('/organizer-detail', arguments: user.id);
        break;
      case 'block':
        controller.blockOrganizer(user.id);
        break;
      case 'unblock':
        controller.unblockOrganizer(user.id);
        break;
    }
  }
}

class _PaginationBar extends GetView<OrganizerController> {
  const _PaginationBar();
  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          color: const Color(0xFF1A1A2E),
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon:
                    const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: controller.currentPage.value > 0
                    ? controller.previousPage
                    : null,
              ),
              Text(
                'Page ${controller.currentPage.value + 1} / ${controller.totalPages.value}',
                style: const TextStyle(color: Colors.white70),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed:
                    controller.currentPage.value <
                            controller.totalPages.value - 1
                        ? controller.nextPage
                        : null,
              ),
            ],
          ),
        ));
  }
}

class _CreateOrganizerDialog extends GetView<OrganizerController> {
  const _CreateOrganizerDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Create Organizer',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(controller.emailController, 'Email', Icons.email),
            const SizedBox(height: 12),
            _field(controller.passwordController, 'Password', Icons.lock,
                obscure: true),
            const SizedBox(height: 12),
            _field(controller.fullNameController, 'Full Name', Icons.person),
            const SizedBox(height: 12),
            _field(controller.phoneController, 'Phone (optional)',
                Icons.phone),
            const SizedBox(height: 12),
            _field(controller.cityController, 'City (optional)',
                Icons.location_city),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: Get.back,
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54))),
        Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009688)),
              onPressed: controller.isLoading.value
                  ? null
                  : controller.createOrganizer,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Create',
                      style: TextStyle(color: Colors.white)),
            )),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white54),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFF009688))),
      ),
    );
  }
}
