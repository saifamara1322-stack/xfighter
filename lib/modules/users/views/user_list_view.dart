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
              if (value == 'clear') {
                controller.clearFilters();
              }
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
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                  onChanged: (query) => controller.updateSearchQuery(query),
                ),
                const SizedBox(height: 8),
                // Status filter chips
                Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: controller.filterStatus.value == 'all',
                            onSelected: (_) => controller.updateFilterStatus('all'),
                          ),
                          const SizedBox(width: 8),
                          ...UserStatus.values.map((status) {
                            final statusString = UserStatus.statusToString(status);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(statusString.toUpperCase()),
                                selected: controller.filterStatus.value == statusString,
                                onSelected: (_) => controller.updateFilterStatus(statusString),
                                backgroundColor: _getStatusColor(status).withOpacity(0.1),
                                selectedColor: _getStatusColor(status).withOpacity(0.3),
                                checkmarkColor: _getStatusColor(status),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 8),
                // Role filter chips
                Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Role:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: controller.filterRole.value == 'all',
                            onSelected: (_) => controller.updateFilterRole('all'),
                          ),
                          const SizedBox(width: 8),
                          ...UserRole.values.map((role) {
                            final roleString = UserRole.roleToString(role);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(roleString.toUpperCase()),
                                selected: controller.filterRole.value == roleString,
                                onSelected: (_) => controller.updateFilterRole(roleString),
                                backgroundColor: _getRoleColor(role).withOpacity(0.1),
                                selectedColor: _getRoleColor(role).withOpacity(0.3),
                                checkmarkColor: _getRoleColor(role),
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        final filteredUsers = controller.filteredUsers;
        
        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No users found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
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
              return UserCard(user: user, controller: controller);
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
  
  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.pending:
        return Colors.orange;
      case UserStatus.suspended:
        return Colors.red;
    }
  }
  
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.fighter:
        return Colors.blue;
      case UserRole.coach:
        return Colors.purple;
      case UserRole.organizer:
        return Colors.teal;
      case UserRole.referee:
        return Colors.amber;
      case UserRole.admin:
        return Colors.red;
    }
  }
  
  void _showAddUserDialog(BuildContext context, UserController controller) {
    final emailController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    UserRole selectedRole = UserRole.fighter;
    UserStatus selectedStatus = UserStatus.pending;
    bool isVerified = false;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Add New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<UserRole>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.name),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedRole = value!;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<UserStatus>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: UserStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(UserStatus.statusToString(status).toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedStatus = value!;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: isVerified,
                    onChanged: (value) {
                      isVerified = value ?? false;
                      // Rebuild dialog with new value
                      Get.back();
                      _showAddUserDialog(context, controller);
                    },
                  ),
                  const Text('Verified User'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newUser = User(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                email: emailController.text,
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                role: selectedRole,
                status: selectedStatus,
                verified: isVerified,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              controller.addUser(newUser);
              Get.back();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final User user;
  final UserController controller;
  
  const UserCard({
    super.key,
    required this.user,
    required this.controller,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role),
          child: Text(
            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(user.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getStatusColor(user.status),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        UserStatus.statusToString(user.status).toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(user.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.roleDisplayName.toUpperCase(),
                    style: TextStyle(
                      color: _getRoleColor(user.role),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (user.verified)
                  const SizedBox(width: 8),
                if (user.verified)
                  const Icon(
                    Icons.verified,
                    size: 16,
                    color: Colors.blue,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditDialog(context, user, controller);
            } else if (value == 'delete') {
              _showDeleteConfirmDialog(context, user, controller);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showUserDetailsDialog(context, user),
      ),
    );
  }
  
  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.pending:
        return Colors.orange;
      case UserStatus.suspended:
        return Colors.red;
    }
  }
  
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.fighter:
        return Colors.blue;
      case UserRole.coach:
        return Colors.purple;
      case UserRole.organizer:
        return Colors.teal;
      case UserRole.referee:
        return Colors.amber;
      case UserRole.admin:
        return Colors.red;
    }
  }
  
  void _showEditDialog(BuildContext context, User user, UserController controller) {
    final emailController = TextEditingController(text: user.email);
    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    UserRole selectedRole = user.role;
    UserStatus selectedStatus = user.status;
    bool isVerified = user.verified;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<UserRole>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.name),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedRole = value!;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<UserStatus>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: UserStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(UserStatus.statusToString(status).toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedStatus = value!;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: isVerified,
                    onChanged: (value) {
                      isVerified = value ?? false;
                      Get.back();
                      _showEditDialog(context, user, controller);
                    },
                  ),
                  const Text('Verified User'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedUser = User(
                id: user.id,
                email: emailController.text,
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                role: selectedRole,
                status: selectedStatus,
                verified: isVerified,
                createdAt: user.createdAt,
                updatedAt: DateTime.now(),
              );
              controller.updateUser(updatedUser);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmDialog(BuildContext context, User user, UserController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteUser(user.id);
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _showUserDetailsDialog(BuildContext context, User user) {
    Get.dialog(
      AlertDialog(
        title: Text(user.fullName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Email:', user.email),
              const SizedBox(height: 8),
              _buildDetailRow('First Name:', user.firstName),
              const SizedBox(height: 8),
              _buildDetailRow('Last Name:', user.lastName),
              const SizedBox(height: 8),
              _buildDetailRow('Role:', user.roleDisplayName),
              const SizedBox(height: 8),
              _buildDetailRow('Status:', UserStatus.statusToString(user.status).toUpperCase()),
              const SizedBox(height: 8),
              _buildDetailRow('Verified:', user.verified ? 'Yes' : 'No'),
              const SizedBox(height: 8),
              _buildDetailRow('Created:', _formatDate(user.createdAt)),
              const SizedBox(height: 8),
              _buildDetailRow('Updated:', _formatDate(user.updatedAt)),
              const SizedBox(height: 8),
              _buildDetailRow('ID:', user.id),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}