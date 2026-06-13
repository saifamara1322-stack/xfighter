import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/models/category_model.dart';
import 'package:xfighter/data/repositories/category_repository.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(_CategoriesController());
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('CATEGORIES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE31837)),
            onPressed: () => _showSheet(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE31837)));
        }
        if (controller.categories.isEmpty) {
          return _emptyState(context, controller);
        }
        return RefreshIndicator(
          color: const Color(0xFFE31837),
          backgroundColor: const Color(0xFF0D0D1A),
          onRefresh: controller.load,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.categories.length,
            itemBuilder: (_, i) => _CategoryCard(category: controller.categories[i], controller: controller),
          ),
        );
      }),
    );
  }

  Widget _emptyState(BuildContext context, _CategoriesController controller) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.category, size: 64, color: Colors.white24),
      const SizedBox(height: 16),
      const Text('No categories yet', style: TextStyle(color: Colors.white54, fontSize: 16)),
      const SizedBox(height: 8),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE31837), foregroundColor: Colors.white),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
        onPressed: () => _showSheet(context, controller),
      ),
    ]),
  );
}

void _showSheet(BuildContext context, _CategoriesController controller, {Category? existing}) {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final descCtrl = TextEditingController(text: existing?.description ?? '');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0D0D1A),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.category, color: Color(0xFFE31837)),
          const SizedBox(width: 8),
          Text(existing == null ? 'NEW CATEGORY' : 'EDIT CATEGORY',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Get.back()),
        ]),
        const SizedBox(height: 20),
        _darkField(nameCtrl, 'Category Name', Icons.label_outline),
        const SizedBox(height: 12),
        _darkField(descCtrl, 'Description (optional)', Icons.info_outline),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity, height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE31837), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Get.back();
              final req = CreateCategoryRequest(name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim());
              if (existing == null) {
                await controller.create(req);
              } else {
                await controller.updateCategory(existing.id, req);
              }
            },
            child: Text(existing == null ? 'CREATE' : 'SAVE',
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ),
      ]),
    ),
  );
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final _CategoriesController controller;
  const _CategoryCard({required this.category, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.07), Colors.white.withOpacity(0.03)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: const Color(0xFFE31837).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.category, color: Color(0xFFE31837), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(category.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          if (category.description != null)
            Text(category.description!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ])),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 20),
          onPressed: () => _showSheet(context, controller, existing: category),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Color(0xFFE31837), size: 20),
          onPressed: () => Get.dialog(AlertDialog(
            backgroundColor: const Color(0xFF0D0D1A),
            title: const Text('Delete Category', style: TextStyle(color: Colors.white)),
            content: Text('Delete "${category.name}"?', style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(onPressed: Get.back, child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
              TextButton(onPressed: () { Get.back(); controller.delete(category.id); },
                  child: const Text('DELETE', style: TextStyle(color: Color(0xFFE31837), fontWeight: FontWeight.bold))),
            ],
          )),
        ),
      ]),
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class _CategoriesController extends GetxController {
  final _repo = CategoryRepository();
  final categories = <Category>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() { super.onInit(); load(); }

  Future<void> load() async {
    isLoading.value = true;
    try { categories.value = await _repo.getCategories(); }
    catch (e) { Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM); }
    finally { isLoading.value = false; }
  }

  Future<void> create(CreateCategoryRequest req) async {
    try {
      final c = await _repo.createCategory(req);
      categories.insert(0, c);
      Get.snackbar('Created', '${c.name} added', backgroundColor: const Color(0xFF1B5E20), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) { Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM); }
  }

  Future<void> updateCategory(String id, CreateCategoryRequest req) async {
    try {
      final c = await _repo.updateCategory(id, req);
      final idx = categories.indexWhere((x) => x.id == id);
      if (idx != -1) categories[idx] = c;
      Get.snackbar('Updated', '${c.name} updated', backgroundColor: const Color(0xFF1B5E20), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) { Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM); }
  }

  Future<void> delete(String id) async {
    try {
      await _repo.deleteCategory(id);
      categories.removeWhere((x) => x.id == id);
      Get.snackbar('Deleted', 'Category removed', backgroundColor: Colors.grey[800], colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) { Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM); }
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _darkField(TextEditingController ctrl, String label, IconData icon) =>
    TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: const Color(0xFFE31837), size: 20),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE31837), width: 2)),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
      ),
    );
