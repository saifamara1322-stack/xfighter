import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/models/sport_model.dart';
import 'package:xfighter/data/models/category_model.dart';
import 'package:xfighter/data/repositories/sport_repository.dart';
import 'package:xfighter/data/repositories/category_repository.dart';

class SportsView extends StatelessWidget {
  const SportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(_SportsController());
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('SPORTS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE31837)),
            onPressed: () => _showSportSheet(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE31837)));
        }
        if (controller.sports.isEmpty) {
          return _emptyState();
        }
        return RefreshIndicator(
          color: const Color(0xFFE31837),
          backgroundColor: const Color(0xFF0D0D1A),
          onRefresh: controller.load,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.sports.length,
            itemBuilder: (_, i) => _SportCard(
              sport: controller.sports[i],
              controller: controller,
            ),
          ),
        );
      }),
    );
  }

  Widget _emptyState() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.sports, size: 64, color: Colors.white24),
      const SizedBox(height: 16),
      const Text('No sports yet', style: TextStyle(color: Colors.white54, fontSize: 16)),
      const SizedBox(height: 8),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE31837), foregroundColor: Colors.white),
        icon: const Icon(Icons.add),
        label: const Text('Add Sport'),
        onPressed: () => _showSportSheet(Get.context!, Get.find<_SportsController>()),
      ),
    ]),
  );
}



void _showSportSheet(BuildContext context, _SportsController controller, {Sport? existing}) {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final codeCtrl = TextEditingController(text: existing?.code ?? '');
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
          const Icon(Icons.sports, color: Color(0xFFE31837)),
          const SizedBox(width: 8),
          Text(existing == null ? 'NEW SPORT' : 'EDIT SPORT',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Get.back()),
        ]),
        const SizedBox(height: 20),
        _darkField(nameCtrl, 'Sport Name', Icons.sports),
        const SizedBox(height: 12),
        _darkField(codeCtrl, 'Sport Code (e.g. MT, MMA)', Icons.code),
        const SizedBox(height: 12),
        _darkField(descCtrl, 'Description (optional)', Icons.info_outline),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE31837), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || codeCtrl.text.trim().isEmpty) return;
              Get.back();
              final req = CreateSportRequest(
                name: nameCtrl.text.trim(),
                code: codeCtrl.text.trim().toUpperCase(),
                description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
              );
              if (existing == null) {
                await controller.create(req);
              } else {
                await controller.updateSport(existing.id, req);
              }
            },
            child: Text(existing == null ? 'CREATE SPORT' : 'SAVE CHANGES',
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ),
      ]),
    ),
  );
}

Future<void> _showAttachCategorySheet(BuildContext context, _SportsController controller, String sportId) async {
  final minAgeCtrl = TextEditingController();
  final maxAgeCtrl = TextEditingController();
  final selectedCat = Rx<Category?>(null);

  await showModalBottomSheet(
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
          const Text('ATTACH CATEGORY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Get.back()),
        ]),
        const SizedBox(height: 16),
        Obx(() => DropdownButtonFormField<Category>(
          dropdownColor: const Color(0xFF1A1A2E),
          style: const TextStyle(color: Colors.white),
          decoration: _darkDeco('Age Category', Icons.category_outlined),
          value: selectedCat.value,
          items: controller.allCategories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
          onChanged: (v) => selectedCat.value = v,
        )),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _darkField(minAgeCtrl, 'Min Age', Icons.person_outline, type: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: _darkField(maxAgeCtrl, 'Max Age', Icons.person_outline, type: TextInputType.number)),
        ]),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity, height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE31837), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (selectedCat.value == null) return;
              Get.back();
              await controller.attachCategory(sportId, CreateSportCategoryRuleRequest(
                categoryId: selectedCat.value!.id,
                minAge: int.tryParse(minAgeCtrl.text),
                maxAge: int.tryParse(maxAgeCtrl.text),
              ));
            },
            child: const Text('ATTACH', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ),
      ]),
    ),
  );
}

class _SportCard extends StatelessWidget {
  final Sport sport;
  final _SportsController controller;
  const _SportCard({required this.sport, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.07), Colors.white.withOpacity(0.03)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: const Color(0xFFE31837).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.sports, color: Color(0xFFE31837), size: 24),
          ),
          title: Row(
            children: [
              Text(sport.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              if (sport.code != null && sport.code!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE31837).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE31837).withOpacity(0.5)),
                  ),
                  child: Text(
                    sport.code!,
                    style: const TextStyle(color: Color(0xFFE31837), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          subtitle: sport.description != null
              ? Text(sport.description!, style: const TextStyle(color: Colors.white54, fontSize: 12))
              : null,
          iconColor: Colors.white54,
          collapsedIconColor: Colors.white54,
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 20),
              onPressed: () => _showSportSheet(context, controller, existing: sport),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFE31837), size: 20),
              onPressed: () => _confirmDelete(context, sport, controller),
            ),
          ]),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _CategoryRulesSection(sportId: sport.id, controller: controller),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Sport sport, _SportsController controller) {
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF0D0D1A),
      title: const Text('Delete Sport', style: TextStyle(color: Colors.white)),
      content: Text('Delete "${sport.name}"?', style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
        TextButton(onPressed: () { Get.back(); controller.delete(sport.id); },
            child: const Text('DELETE', style: TextStyle(color: Color(0xFFE31837), fontWeight: FontWeight.bold))),
      ],
    ));
  }
}

class _CategoryRulesSection extends StatefulWidget {
  final String sportId;
  final _SportsController controller;
  const _CategoryRulesSection({required this.sportId, required this.controller});

  @override
  State<_CategoryRulesSection> createState() => _CategoryRulesSectionState();
}

class _CategoryRulesSectionState extends State<_CategoryRulesSection> {
  List<SportCategory> rules = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      rules = await widget.controller.getSportCategories(widget.sportId);
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('AGE-CATEGORY RULES', style: TextStyle(color: Color(0xFFE31837), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
        const Spacer(),
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFE31837)),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('ATTACH', style: TextStyle(fontSize: 11)),
          onPressed: () async {
            await _showAttachCategorySheet(context, widget.controller, widget.sportId);
            await _load();
          },
        ),
      ]),
      if (loading) const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator(color: Color(0xFFE31837))),
      if (!loading && rules.isEmpty)
        const Padding(padding: EdgeInsets.all(8),
            child: Text('No category rules attached', style: TextStyle(color: Colors.white38, fontSize: 12))),
      ...rules.map((r) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          const Icon(Icons.category_outlined, color: Colors.white54, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(r.categoryName ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 13))),
          if (r.minAge != null || r.maxAge != null)
            Text('${r.minAge ?? '?'} – ${r.maxAge ?? '?'} yrs',
                style: const TextStyle(color: Color(0xFFE31837), fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
      )),
    ]);
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class _SportsController extends GetxController {
  final _repo = SportRepository();
  final _catRepo = CategoryRepository();

  final sports = <Sport>[].obs;
  final allCategories = <Category>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([_repo.getSports(), _catRepo.getCategories()]);
      sports.value = results[0] as List<Sport>;
      allCategories.value = results[1] as List<Category>;
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> create(CreateSportRequest req) async {
    try {
      final s = await _repo.createSport(req);
      sports.insert(0, s);
      Get.snackbar('Success', '${s.name} created', backgroundColor: const Color(0xFF1B5E20), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }


  Future<void> updateSport(String id, CreateSportRequest req) async {
    try {
      final s = await _repo.updateSport(id, req);
      final idx = sports.indexWhere((x) => x.id == id);
      if (idx != -1) sports[idx] = s;
      Get.snackbar('Updated', '${s.name} updated', backgroundColor: const Color(0xFF1B5E20), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repo.deleteSport(id);
      sports.removeWhere((x) => x.id == id);
      Get.snackbar('Deleted', 'Sport removed', backgroundColor: Colors.grey[800], colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<List<SportCategory>> getSportCategories(String sportId) => _repo.getSportCategories(sportId);

  Future<void> attachCategory(String sportId, CreateSportCategoryRuleRequest req) async {
    try {
      await _repo.attachCategory(sportId, req);
      Get.snackbar('Attached', 'Category rule added', backgroundColor: const Color(0xFF1B5E20), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _darkField(TextEditingController ctrl, String label, IconData icon, {TextInputType? type}) =>
    TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: _darkDeco(label, icon),
    );

InputDecoration _darkDeco(String label, IconData icon) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(color: Colors.white54),
  prefixIcon: Icon(icon, color: const Color(0xFFE31837), size: 20),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE31837), width: 2)),
  filled: true,
  fillColor: Colors.black.withOpacity(0.3),
);
