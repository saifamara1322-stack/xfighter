import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/core/theme/app_theme.dart';
import 'package:xfighter/core/routes/app_router.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global controllers (available for the entire app lifetime)
  Get.put(AuthController(), permanent: true);

  runApp(const XFighterApp());
}

class XFighterApp extends StatelessWidget {
  const XFighterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'XFIGHTER - Platforme de Combat Tunisienne',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.initial,
      getPages: AppRouter.pages,
      // Fallback for unknown routes
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => Scaffold(
          appBar: AppBar(title: const Text('Not Found')),
          body: const Center(child: Text('Page not found')),
        ),
      ),
    );
  }
}
