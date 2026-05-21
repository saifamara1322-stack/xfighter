import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../core/routes/app_router.dart';

class UserListView extends StatelessWidget {
  final UserController controller = Get.put(UserController());

  UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'USER MANAGEMENT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => controller.fetchUsers(),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt, color: Colors.white70),
            onSelected: (value) {
              if (value == 'clear') controller.clearFilters();
            },
            color: const Color(0xFF1A1A1A),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20, color: Color(0xFFE31837)),
                    SizedBox(width: 12),
                    Text('Clear All Filters', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.users.isEmpty) {
                return const Center(child: _LoadingAnimation());
              }

              final filteredUsers = controller.filteredUsers;

              if (filteredUsers.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchUsers(),
                color: const Color(0xFFE31837),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _AnimatedUserCard(
                      user: user,
                      controller: controller,
                      index: index,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context, controller),
        backgroundColor: const Color(0xFFE31837),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

Widget _buildFilters() {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF0A0A0A),
      border: Border(
        bottom: BorderSide(color: Colors.white.withAlpha(26)),
      ),
    ),
    child: Column(
      children: [
        // Search Bar
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: Colors.red, // Updated to red
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color.fromARGB(255, 43, 40, 40).withAlpha(26)),
          ),
          child: TextField(
            style: const TextStyle(color: Color.fromARGB(255, 21, 21, 21)),
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              hintStyle: TextStyle(color: const Color.fromARGB(255, 40, 39, 39).withAlpha(153)),
              prefixIcon: const Icon(Icons.search, color: Color.fromARGB(137, 21, 21, 21)),
              suffixIcon: Obx(() {
                if (controller.searchQuery.value.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Color.fromARGB(0, 255, 255, 255)),
                    onPressed: () => controller.updateSearchQuery(''),
                  );
                }
                return const SizedBox.shrink();
              }),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (query) => controller.updateSearchQuery(query),
          ),
        ),

        // Status Filter
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 12, color: Color(0xFFE31837)),
              const SizedBox(width: 8),
              const Text(
                'STATUS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE31837),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Obx(
                  () => Text(
                    '${controller.filteredUsers.length}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'ALL',
                  isSelected: controller.filterStatus.value == 'all',
                  onSelected: () => controller.updateFilterStatus('all'),
                  backgroundColor: Colors.red, // Added red background
                  foregroundColor: Colors.white, // Added white foreground
                ),
                const SizedBox(width: 8),
                ...UserStatus.values.map((status) {
                  return _FilterChip(
                    label: status.displayName.toUpperCase(),
                    isSelected: controller.filterStatus.value == status.name,
                    onSelected: () => controller.updateFilterStatus(status.name),
                    color: status.color,
                    backgroundColor: Colors.red, // Added red background
                    foregroundColor: Colors.white, // Added white foreground
                  );
                }),
              ],
            ),
          ),
        ),

        // Role Filter
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings, size: 12, color: Color(0xFFE31837)),
              SizedBox(width: 8),
              Text(
                'ROLE',
                style: TextStyle(
                  color: Color.fromARGB(179, 86, 80, 80),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'ALL',
                  isSelected: controller.filterRole.value == 'all',
                  onSelected: () => controller.updateFilterRole('all'),
                  backgroundColor: Colors.red, // Added red background
                  foregroundColor: Colors.white, // Added white foreground
                ),
                const SizedBox(width: 8),
                ...UserRole.values.map((role) {
                  return _FilterChip(
                    label: role.displayName.toUpperCase(),
                    isSelected: controller.filterRole.value == role.name,
                    onSelected: () => controller.updateFilterRole(role.name),
                    color: role.color,
                    backgroundColor: Colors.red, // Added red background
                    foregroundColor: Colors.white, // Added white foreground
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(26)),
            ),
            child: Icon(Icons.person_off, size: 50, color: Colors.white.withAlpha(102)),
          ),
          const SizedBox(height: 24),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(179),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search query',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withAlpha(102),
            ),
          ),
          const SizedBox(height: 24),
          if (controller.searchQuery.value.isNotEmpty ||
              controller.filterStatus.value != 'all' ||
              controller.filterRole.value != 'all')
            OutlinedButton.icon(
              onPressed: () => controller.clearFilters(),
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Clear All Filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE31837),
                side: const BorderSide(color: Color(0xFFE31837)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, UserController controller) {
    final emailController = TextEditingController();
    final fullNameController = TextEditingController();
    UserRole selectedRole = UserRole.FIGHTER;
    UserStatus selectedStatus = UserStatus.PENDING;

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withAlpha(26)),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE31837).withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_add, color: Color(0xFFE31837), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add New User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white.withAlpha(153)),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFFE31837)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withAlpha(51)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE31837)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fullNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.white.withAlpha(153)),
                  prefixIcon: const Icon(Icons.person, color: Color(0xFFE31837)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withAlpha(51)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE31837)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                initialValue: selectedRole,
                dropdownColor: const Color(0xFF1A1A1A),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(color: Colors.white.withAlpha(153)),
                  prefixIcon: const Icon(Icons.admin_panel_settings, color: Color(0xFFE31837)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withAlpha(51)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE31837)),
                  ),
                ),
                items: UserRole.values.map((r) => DropdownMenuItem(
                  value: r,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: r.color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(r.displayName),
                    ],
                  ),
                )).toList(),
                onChanged: (v) => selectedRole = v!,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserStatus>(
                initialValue: selectedStatus,
                dropdownColor: const Color(0xFF1A1A1A),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Status',
                  labelStyle: TextStyle(color: Colors.white.withAlpha(153)),
                  prefixIcon: const Icon(Icons.circle, color: Color(0xFFE31837)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withAlpha(51)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE31837)),
                  ),
                ),
                items: UserStatus.values.map((s) => DropdownMenuItem(
                  value: s,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: s.color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(s.displayName),
                    ],
                  ),
                )).toList(),
                onChanged: (v) => selectedStatus = v!,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withAlpha(51)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          'Info',
                          'User creation is handled via registration endpoints',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF1A1A1A),
                          colorText: Colors.white,
                          icon: const Icon(Icons.info_outline, color: Color(0xFFE31837)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE31837),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Add User'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Chip Widget
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color? color;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.color,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isSelected 
              ? foregroundColor ?? color ?? const Color(0xFFE31837) 
              : foregroundColor?.withOpacity(0.7) ?? Colors.white70,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: backgroundColor ?? Colors.transparent,
      selectedColor: (color ?? const Color(0xFFE31837)).withAlpha(26),
      side: BorderSide(
        color: isSelected
            ? color ?? const Color(0xFFE31837)
            : Colors.white.withAlpha(51),
        width: 1,
      ),
      shape: StadiumBorder(),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// Animated User Card
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedUserCard extends StatelessWidget {
  final User user;
  final UserController controller;
  final int index;

  const _AnimatedUserCard({
    required this.user,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(26)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showUserDetails(context, user),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _UserAvatar(user: user),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withAlpha(153),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _CompactBadge(
                              label: user.status.displayName,
                              color: user.status.color,
                              icon: Icons.circle,
                            ),
                            _CompactBadge(
                              label: user.role.displayName,
                              color: user.role.color,
                              icon: Icons.admin_panel_settings,
                            ),
                            if (user.verifiedAt != null)
                              const _CompactBadge(
                                label: 'Verified',
                                color: Colors.green,
                                icon: Icons.verified,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: const Color(0xFF1A1A1A),
                    onSelected: (value) {
                      if (value == 'view') _showUserDetails(context, user);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Color(0xFFE31837)),
                            SizedBox(width: 12),
                            Text('View Details', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(Icons.more_vert, color: Colors.white.withAlpha(102)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUserDetails(BuildContext context, User user) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withAlpha(26)),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _UserAvatar(user: user, size: 80),
              const SizedBox(height: 16),
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withAlpha(153),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(13),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(26)),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.admin_panel_settings,
                      label: 'Role',
                      value: user.role.displayName,
                      color: user.role.color,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.circle,
                      label: 'Status',
                      value: user.status.displayName,
                      color: user.status.color,
                    ),
                    if (user.countryId != null) ...[
                      const SizedBox(height: 12),
                      _DetailRow(
                        icon: Icons.location_on,
                        label: 'Country',
                        value: user.countryId!,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Created',
                      value: _fmt(user.createdAt),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.verified,
                      label: 'Verified',
                      value: _fmt(user.verifiedAt),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return 'Not set';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User Avatar Widget
// ─────────────────────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  final User user;
  final double size;

  const _UserAvatar({required this.user, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            user.role.color,
            user.role.color.withValues(alpha: 0.7),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact Badge Widget
// ─────────────────────────────────────────────────────────────────────────────

class _CompactBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _CompactBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail Row Widget
// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? const Color(0xFFE31837)),
        const SizedBox(width: 12),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.white.withAlpha(179),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading Animation Widget
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingAnimation extends StatelessWidget {
  const _LoadingAnimation();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE31837)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading users...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withAlpha(153),
          ),
        ),
      ],
    );
  }
}