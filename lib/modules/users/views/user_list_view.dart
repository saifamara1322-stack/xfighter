import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../../../data/models/user_model.dart';

class UserListView extends StatelessWidget {
  final UserController controller = Get.put(UserController());

  UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchUsers(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              if (value == 'clear') controller.clearFilters();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear All Filters'),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                  onChanged: (query) => controller.updateSearchQuery(query),
                ),
                const SizedBox(height: 8),
                Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status:',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected:
                                    controller.filterStatus.value == 'all',
                                onSelected: (_) =>
                                    controller.updateFilterStatus('all'),
                              ),
                              const SizedBox(width: 8),
                              ...UserStatus.values.map((status) {
                                final s = status.name;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(s),
                                    selected:
                                        controller.filterStatus.value == s,
                                    onSelected: (_) =>
                                        controller.updateFilterStatus(s),
                                    backgroundColor:
                                        status.color.withAlpha(26),
                                    selectedColor: status.color.withAlpha(77),
                                    checkmarkColor: status.color,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    )),
                const SizedBox(height: 8),
                Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Role:',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: controller.filterRole.value == 'all',
                                onSelected: (_) =>
                                    controller.updateFilterRole('all'),
                              ),
                              const SizedBox(width: 8),
                              ...UserRole.values.map((role) {
                                final r = role.name;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(r),
                                    selected: controller.filterRole.value == r,
                                    onSelected: (_) =>
                                        controller.updateFilterRole(r),
                                    backgroundColor: role.color.withAlpha(26),
                                    selectedColor: role.color.withAlpha(77),
                                    checkmarkColor: role.color,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredUsers = controller.filteredUsers;

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('No users found',
                    style:
                        TextStyle(fontSize: 18, color: Colors.grey[600])),
                if (controller.searchQuery.value.isNotEmpty ||
                    controller.filterStatus.value != 'all' ||
                    controller.filterRole.value != 'all')
                  TextButton(
                    onPressed: () => controller.clearFilters(),
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchUsers(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return _UserCard(user: user, controller: controller);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context, controller),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, UserController controller) {
    final emailController = TextEditingController();
    final fullNameController = TextEditingController();
    UserRole selectedRole = UserRole.FIGHTER;
    UserStatus selectedStatus = UserStatus.PENDING;

    Get.dialog(
      StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add New User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                      labelText: 'Full Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                      labelText: 'Role', border: OutlineInputBorder()),
                  items: UserRole.values
                      .map((r) => DropdownMenuItem(
                          value: r, child: Text(r.displayName)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedRole = v!),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<UserStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                      labelText: 'Status', border: OutlineInputBorder()),
                  items: UserStatus.values
                      .map((s) => DropdownMenuItem(
                          value: s, child: Text(s.displayName)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedStatus = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                // User creation is not supported by API directly — stub
                Get.back();
                Get.snackbar('Info',
                    'User creation is handled via registration endpoints',
                    snackPosition: SnackPosition.BOTTOM);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UserCard
// ─────────────────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final User user;
  final UserController controller;

  const _UserCard({required this.user, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.role.color,
          child: Text(
            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(user.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                _StatusBadge(status: user.status),
                const SizedBox(width: 8),
                _RoleBadge(role: user.role),
                if (user.verifiedAt != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.verified, size: 16, color: Colors.blue),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'view') _showUserDetails(context, user);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(children: [
                Icon(Icons.info_outline, size: 20),
                SizedBox(width: 8),
                Text('View Details'),
              ]),
            ),
          ],
        ),
        onTap: () => _showUserDetails(context, user),
      ),
    );
  }

  void _showUserDetails(BuildContext context, User user) {
    Get.dialog(
      AlertDialog(
        title: Text(user.fullName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow('Email:', user.email),
              _DetailRow('Full Name:', user.fullName),
              _DetailRow('Role:', user.role.displayName),
              _DetailRow('Status:', user.status.displayName),
              _DetailRow('Country ID:', user.countryId ?? '—'),
              _DetailRow('Created:', _fmt(user.createdAt)),
              _DetailRow('Verified:', _fmt(user.verifiedAt)),
              _DetailRow('ID:', user.id),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final UserStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: status.color.withAlpha(51),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: status.color),
          ),
          const SizedBox(width: 4),
          Text(status.displayName,
              style: TextStyle(
                  color: status.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ]),
      );
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: role.color.withAlpha(51),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(role.displayName,
            style: TextStyle(
                color: role.color,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );
}