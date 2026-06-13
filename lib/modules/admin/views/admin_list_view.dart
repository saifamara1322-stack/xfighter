import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/modules/admin/controllers/admin_controller.dart';
import 'package:xfighter/data/models/user_model.dart';

class AdminListView extends GetView<AdminController> {
  const AdminListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Admin Management',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadAdmins,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(),
          Expanded(child: _AdminList()),
          _PaginationBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: const Color(0xFFE53935),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('New Admin', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    Get.dialog(
      _CreateAdminDialog(),
      barrierDismissible: false,
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends GetView<AdminController> {
  const _FilterBar();

  static const _statuses = ['', 'ACTIVE', 'PENDING', 'NODOCS', 'REFUSED', 'DISABLED'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('Status:', style: TextStyle(color: Colors.white70)),
          const SizedBox(width: 8),
          Obx(() => DropdownButton<String>(
                value: controller.statusFilter.value,
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                underline: Container(height: 1, color: Colors.white30),
                items: _statuses
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.isEmpty ? 'All' : s),
                        ))
                    .toList(),
                onChanged: (v) {
                  controller.statusFilter.value = v ?? '';
                  controller.applyFilters();
                },
              )),
          const Spacer(),
          Obx(() => Text(
                '${controller.totalElements.value} admins',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              )),
        ],
      ),
    );
  }
}

// ── Admin list ────────────────────────────────────────────────────────────────

class _AdminList extends GetView<AdminController> {
  const _AdminList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE53935)));
      }
      if (controller.admins.isEmpty) {
        return const Center(
            child: Text('No admins found',
                style: TextStyle(color: Colors.white54)));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.admins.length,
        itemBuilder: (_, i) => _AdminCard(user: controller.admins[i]),
      );
    });
  }
}

class _AdminCard extends GetView<AdminController> {
  final User user;
  const _AdminCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A2E),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: user.role.color.withOpacity(0.2),
          child: Text(
            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
            style: TextStyle(color: user.role.color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(user.fullName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email, style: const TextStyle(color: Colors.white60, fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: user.status.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(user.status.displayName,
                  style: TextStyle(color: user.status.color, fontSize: 11)),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: const Color(0xFF1A1A2E),
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          onSelected: (action) => _handleAction(action),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'detail',
                child: Text('View Detail', style: TextStyle(color: Colors.white))),
            if (user.status == UserStatus.DISABLED)
              const PopupMenuItem(value: 'activate',
                  child: Text('Activate', style: TextStyle(color: Colors.green)))
            else
              const PopupMenuItem(value: 'deactivate',
                  child: Text('Deactivate', style: TextStyle(color: Colors.orange))),
          ],
        ),
      ),
    );
  }

  void _handleAction(String action) {
    switch (action) {
      case 'detail':
        Get.toNamed('/admin-detail', arguments: user.id);
        break;
      case 'activate':
        controller.activateAdmin(user.id);
        break;
      case 'deactivate':
        controller.deactivateAdmin(user.id);
        break;
    }
  }
}

// ── Pagination bar ────────────────────────────────────────────────────────────

class _PaginationBar extends GetView<AdminController> {
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
                icon: const Icon(Icons.chevron_left, color: Colors.white),
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
                onPressed: controller.currentPage.value <
                        controller.totalPages.value - 1
                    ? controller.nextPage
                    : null,
              ),
            ],
          ),
        ));
  }
}

// ── Create dialog ─────────────────────────────────────────────────────────────

class _CreateAdminDialog extends GetView<AdminController> {
  const _CreateAdminDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Create Admin',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            _field(controller.phoneController, 'Phone (optional)', Icons.phone),
            const SizedBox(height: 12),
            _field(controller.cityController, 'City (optional)', Icons.location_city),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.countries.isEmpty) {
                return const Text(
                  'Loading countries…',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                );
              }
              return DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Country *',
                  labelStyle: const TextStyle(color: Colors.white60),
                  prefixIcon: const Icon(Icons.flag, color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE53935)),
                  ),
                ),
                value: controller.selectedCountryId.value.isEmpty
                    ? null
                    : controller.selectedCountryId.value,
                items: controller.countries
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (v) => controller.selectedCountryId.value = v ?? '',
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
              onPressed: controller.isLoading.value ? null : controller.createAdmin,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create', style: TextStyle(color: Colors.white)),
            )),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool obscure = false,
    String? hint,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white60),
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
      ),
    );
  }
}
