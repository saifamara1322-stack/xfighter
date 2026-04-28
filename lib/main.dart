import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/core/theme/app_theme.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';
import 'package:xfighter/modules/auth/bindings/auth_binding.dart';
import 'package:xfighter/modules/auth/routes/auth_routes.dart';
import 'package:xfighter/modules/auth/views/login_view.dart';
import 'package:xfighter/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:xfighter/modules/dashboard/views/dashboard_view.dart';

//json-server db.json --port 3000
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize global controllers
  Get.put(AuthController());
  
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
      initialRoute: '/',
      getPages: [
        ...AuthRoutes.pages,
        GetPage(
          name: '/dashboard',
          page: () => const DashboardView(),
          binding: DashboardBinding(),
        ),
      ],
    );
  }
}
  
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return Obx(() {
      if (authController.isLoggedIn.value) {
        return  DashboardView();
      } else {
        return LoginView();
      }
    });
  }
