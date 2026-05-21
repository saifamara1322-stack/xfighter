import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/modules/admin/controllers/admin_controller.dart';

class AdminDetailView extends GetView<AdminController> {
  final String adminId;
  const AdminDetailView({super.key, required this.adminId});

  @override
  Widget build(BuildContext context) {
    // Load detail when view is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAdminDetail(adminId);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Admin Detail',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)));
        }
        final admin = controller.selectedAdmin.value;
        final audit = controller.audit.value;
        if (admin == null) {
          return const Center(
              child: Text('Admin not found', style: TextStyle(color: Colors.white54)));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile card ───────────────────────────────────────────────
              _SectionCard(
                title: 'Profile',
                child: Column(
                  children: [
                    _InfoRow(Icons.person, 'Name', admin.fullName),
                    _InfoRow(Icons.email, 'Email', admin.email),
                    _InfoRow(Icons.phone, 'Phone', admin.phoneNumber ?? '—'),
                    _InfoRow(Icons.badge, 'Role', admin.role.displayName),
                    _InfoRow(Icons.circle, 'Status', admin.status.displayName,
                        valueColor: admin.status.color),
                    if (admin.createdAt != null)
                      _InfoRow(Icons.calendar_today, 'Created',
                          _formatDate(admin.createdAt!)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Actions ────────────────────────────────────────────────────
              _SectionCard(
                title: 'Actions',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ActionButton(
                      label: 'Activate',
                      icon: Icons.check_circle,
                      color: Colors.green,
                      onTap: () => controller.activateAdmin(adminId),
                    ),
                    _ActionButton(
                      label: 'Deactivate',
                      icon: Icons.block,
                      color: Colors.orange,
                      onTap: () => controller.deactivateAdmin(adminId),
                    ),
                    _ActionButton(
                      label: 'Change Password',
                      icon: Icons.lock_reset,
                      color: Colors.blue,
                      onTap: () => _showPasswordDialog(context),
                    ),
                    _ActionButton(
                      label: 'Change Email',
                      icon: Icons.alternate_email,
                      color: Colors.teal,
                      onTap: () => _showEmailDialog(context),
                    ),
                  ],
                ),
              ),

              if (audit != null) ...[
                const SizedBox(height: 16),
                // ── Audit ──────────────────────────────────────────────────
                _SectionCard(
                  title: 'Audit Trail',
                  child: Column(
                    children: [
                      if (audit.createdByEmail != null)
                        _InfoRow(Icons.add_circle, 'Created by', audit.createdByEmail!),
                      if (audit.verifiedByEmail != null)
                        _InfoRow(Icons.verified, 'Verified by', audit.verifiedByEmail!),
                      if (audit.updatedByEmail != null)
                        _InfoRow(Icons.edit, 'Updated by', audit.updatedByEmail!),
                      if (audit.createdAt != null)
                        _InfoRow(Icons.access_time, 'Created',
                            _formatDate(audit.createdAt!)),
                      if (audit.updatedAt != null)
                        _InfoRow(Icons.update, 'Updated',
                            _formatDate(audit.updatedAt!)),
                      if (audit.verifiedAt != null)
                        _InfoRow(Icons.done_all, 'Verified',
                            _formatDate(audit.verifiedAt!)),
                      if (audit.lastLoginAt != null)
                        _InfoRow(Icons.login, 'Last Login',
                            _formatDate(audit.lastLoginAt!)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Set New Password',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: TextField(
        controller: controller.newPasswordController,
        obscureText: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'New Password',
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: const Icon(Icons.lock, color: Colors.white54),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white24)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE53935))),
        ),
      ),
      actions: [
        TextButton(
            onPressed: Get.back,
            child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
          onPressed: () {
            controller.changeAdminPassword(adminId);
            Get.back();
          },
          child: const Text('Change', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _showEmailDialog(BuildContext context) {
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Change Email',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: TextField(
        controller: controller.newEmailController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'New Email',
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: const Icon(Icons.email, color: Colors.white54),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white24)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE53935))),
        ),
      ),
      actions: [
        TextButton(
            onPressed: Get.back,
            child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
          onPressed: () {
            controller.changeAdminEmail(adminId);
            Get.back();
          },
          child: const Text('Change', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow(this.icon, this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 18),
          const SizedBox(width: 8),
          Text('$label:', style: const TextStyle(color: Colors.white54)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
    );
  }
}
