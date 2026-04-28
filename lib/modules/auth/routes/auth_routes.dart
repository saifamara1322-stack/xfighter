import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';
import 'package:xfighter/modules/auth/views/login_view.dart';
import 'package:xfighter/modules/auth/views/register_view.dart';
import 'package:xfighter/modules/auth/bindings/auth_binding.dart';
import 'package:xfighter/modules/dashboard/views/dashboard_view.dart';

class AuthRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  
  static List<GetPage> pages = [
    GetPage(
      name: initial,
      page: () => const AuthWrapper(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
  ];
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return Obx(() {
      if (authController.isLoggedIn.value) {
        return const DashboardView();
      } else {
        return const LoginView();
      }
    });
  }
}