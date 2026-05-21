import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/modules/verification/controllers/verification_controller.dart';
import 'package:xfighter/data/models/verification_model.dart';

class VerificationListView extends GetView<VerificationController> {
  const VerificationListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Pending Verifications',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: controller.loadPending),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Obx(() => Row(
                children: VerificationTab.values.map((tab) {
                  final selected = controller.activeTab.value == tab;
                  final label = tab.name[0].toUpperCase() + tab.name.substring(1);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.switchTab(tab),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: selected ? const Color(0xFFE53935) : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selected ? const Color(0xFFE53935) : Colors.white54,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            )),
                      ),
                    ),
                  );
                }).toList(),
              )),
        ),
      ),
      body: Column(
        children: [
          Obx(() => Container(
                color: const Color(0xFF1A1A2E),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(children: [
                  const Icon(Icons.hourglass_top, color: Colors.orange, size: 16),
                  const SizedBox(width: 6),
                  Text('${controller.totalElements.value} pending',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ]),
              )),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE53935)));
              }
              if (controller.pendingUsers.isEmpty) {
                return const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                    SizedBox(height: 12),
                    Text('No pending verifications',
                        style: TextStyle(color: Colors.white54, fontSize: 16)),
                  ]),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.pendingUsers.length,
                itemBuilder: (_, i) => _PendingCard(user: controller.pendingUsers[i]),
              );
            }),
          ),
          Obx(() => Container(
                color: const Color(0xFF1A1A2E),
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed:
                          controller.currentPage.value > 0 ? controller.previousPage : null,
                    ),
                    Text(
                        'Page ${controller.currentPage.value + 1} / ${controller.totalPages.value}',
                        style: const TextStyle(color: Colors.white70)),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: controller.currentPage.value <
                              controller.totalPages.value - 1
                          ? controller.nextPage
                          : null,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _PendingCard extends GetView<VerificationController> {
  final Map<String, dynamic> user;
  const _PendingCard({required this.user});

  String get userId => user['id']?.toString() ?? '';
  String get fullName => user['fullName'] ?? user['email'] ?? 'Unknown';
  String get email => user['email'] ?? '';
  String get role => user['role'] ?? '';

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A2E),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(0.2),
                child: Text(fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fullName,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    Text(email,
                        style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(role,
                    style: const TextStyle(color: Colors.orange, fontSize: 11)),
              ),
            ]),
            const SizedBox(height: 12),
            Obx(() {
              final docs = controller.selectedUserDocs.value;
              final isThisUser = docs?.userId == userId;
              if (!isThisUser) {
                return TextButton.icon(
                  onPressed: () => controller.loadUserDocuments(userId),
                  icon: const Icon(Icons.folder_open, color: Color(0xFF009688), size: 16),
                  label: const Text('View Documents',
                      style: TextStyle(color: Color(0xFF009688), fontSize: 12)),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Documents:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  ...docs!.documentUrls.entries.map((e) => Row(children: [
                        const Icon(Icons.attach_file, color: Colors.white38, size: 14),
                        const SizedBox(width: 4),
                        Text(e.key, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        const SizedBox(width: 4),
                        const Icon(Icons.check, color: Colors.green, size: 14),
                      ])),
                  if (docs.rejectionNote != null) ...[
                    const SizedBox(height: 4),
                    Text('Previous rejection: ${docs.rejectionNote}',
                        style: const TextStyle(color: Colors.orange, fontSize: 11)),
                  ],
                ],
              );
            }),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Reject', style: TextStyle(fontSize: 12)),
                onPressed: () => _showRejectDialog(context),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                icon: const Icon(Icons.check, size: 16, color: Colors.white),
                label: const Text('Approve', style: TextStyle(fontSize: 12, color: Colors.white)),
                onPressed: () => controller.approveUser(userId),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Reject User',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Provide a reason (min 10 characters):',
            style: TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 12),
        TextField(
          controller: controller.rejectionReasonController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'e.g. Documents are invalid...',
            hintStyle: const TextStyle(color: Colors.white30),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red)),
          ),
        ),
      ]),
      actions: [
        TextButton(
            onPressed: Get.back,
            child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            controller.rejectUser(userId);
            Get.back();
          },
          child: const Text('Reject', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}
