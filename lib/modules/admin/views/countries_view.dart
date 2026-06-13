import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/models/country_model.dart';
import 'package:xfighter/data/repositories/country_repository.dart';
import 'package:xfighter/data/models/user_model.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';

class CountriesView extends StatelessWidget {
  const CountriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(_CountriesController());
    final authController = Get.find<AuthController>();
    final isSuperAdmin = authController.currentUser.value?.role == UserRole.SUPER_ADMIN;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('COUNTRIES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isSuperAdmin)
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFFE31837)),
              onPressed: () => _showSheet(context, controller),
            ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search countries...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Color(0xFFE31837)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE31837), width: 2)),
              filled: true, fillColor: Colors.white.withOpacity(0.05),
            ),
            onChanged: (q) => controller.search(q),
          ),
        ),
        Expanded(child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE31837)));
          }
          final list = controller.filtered;
          if (list.isEmpty) {
            return const Center(child: Text('No countries found', style: TextStyle(color: Colors.white54)));
          }
          return RefreshIndicator(
            color: const Color(0xFFE31837),
            backgroundColor: const Color(0xFF0D0D1A),
            onRefresh: controller.load,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: list.length,
              itemBuilder: (_, i) => _CountryTile(country: list[i]),
            ),
          );
        })),
      ]),
    );
  }
}

void _showSheet(BuildContext context, _CountriesController controller) {
  final nameCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final flagCtrl = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0D0D1A),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.flag, color: Color(0xFFE31837)),
          const SizedBox(width: 8),
          const Text('NEW COUNTRY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Get.back()),
        ]),
        const SizedBox(height: 20),
        _darkField(nameCtrl, 'Country Name', Icons.public),
        const SizedBox(height: 12),
        _darkField(codeCtrl, 'Country Code (e.g. TN)', Icons.code),
        const SizedBox(height: 12),
        _darkField(flagCtrl, 'Flag URL (optional)', Icons.image_outlined),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity, height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE31837), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || codeCtrl.text.trim().isEmpty) return;
              Get.back();
              await controller.create(CreateCountryRequest(
                name: nameCtrl.text.trim(),
                code: codeCtrl.text.trim().toUpperCase(),
                flagUrl: flagCtrl.text.trim().isEmpty ? null : flagCtrl.text.trim(),
              ));
            },
            child: const Text('CREATE COUNTRY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ),
      ]),
    ),
  );
}

class _CountryTile extends StatelessWidget {
  final Country country;
  const _CountryTile({required this.country});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.07), Colors.white.withOpacity(0.03)]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 34,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.grey[800]),
          child: country.flagUrl != null && country.flagUrl!.isNotEmpty && country.flagUrl != 'string'
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(country.flagUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.flag, color: Colors.white54, size: 20)),
                )
              : Center(child: Text(country.code.length >= 2 ? country.code.substring(0, 2) : country.code,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(country.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          Text('Code: ${country.code}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE31837).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE31837).withOpacity(0.3)),
          ),
          child: Text(country.code, style: const TextStyle(color: Color(0xFFE31837), fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ]),
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class _CountriesController extends GetxController {
  final _repo = CountryRepository();
  final _all = <Country>[].obs;
  final filtered = <Country>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() { super.onInit(); load(); }

  Future<void> load() async {
    isLoading.value = true;
    try {
      _all.value = await _repo.getAllCountries();
      filtered.value = _all;
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } finally { isLoading.value = false; }
  }

  void search(String q) {
    if (q.isEmpty) { filtered.value = _all; return; }
    final lq = q.toLowerCase();
    filtered.value = _all.where((c) => c.name.toLowerCase().contains(lq) || c.code.toLowerCase().contains(lq)).toList();
  }

  Future<void> create(CreateCountryRequest req) async {
    try {
      final c = await _repo.createCountry(req);
      _all.insert(0, c);
      filtered.value = _all;
      Get.snackbar('Created', '${c.name} added', backgroundColor: const Color(0xFF1B5E20), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
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
