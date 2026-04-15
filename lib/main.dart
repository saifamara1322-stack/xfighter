import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/app/controllers/registration_controller.dart';
import 'package:xfighter/app/views/fighter/fighter_profile_view.dart';
import 'app/controllers/auth_controller.dart';
import 'app/controllers/user_controller.dart';
import 'app/views/auth/login_view.dart';
import 'app/views/auth/register_view.dart';
import 'app/views/dashboard/dashboard_view.dart';
import 'app/views/users/user_list_view.dart';
import 'app/views/gym/gym_list_view.dart';
import 'app/views/gym/gym_detail_view.dart';
import 'app/views/coach/coach_profile_view.dart';
import 'app/views/coach/coach_management_view.dart';
import 'app/views/event/event_list_view.dart';
import 'app/views/event/event_detail_view.dart';
import 'app/views/event/admin_event_management_view.dart';
import 'app/views/registration/fighter_registrations_view.dart';
import 'app/views/registration/coach_registrations_view.dart';

//json-server db.json --port 3000
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize controllers
  Get.put(AuthController());
  Get.put(UserController());
  Get.put(RegistrationController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'XFIGHTER - Platforme de Combat Tunisienne',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const AuthWrapper()),
        GetPage(name: '/login', page: () =>  LoginView()),
        GetPage(name: '/register', page: () =>  RegisterView()),
        GetPage(name: '/dashboard', page: () =>  DashboardView()),
        GetPage(name: '/users', page: () =>  UserListView()),
        GetPage(name: '/fighter-profile', page: () => FighterProfileView()),
        GetPage(name: '/gyms', page: () =>  GymListView()),
        GetPage(name: '/gym/:id', page: () => GymDetailView(gymId: Get.parameters['id']!)),
        GetPage(name: '/coach-profile', page: () =>  CoachProfileView()),
        GetPage(name: '/coach-management', page: () =>  CoachManagementView()),
        GetPage(name: '/events', page: () =>  EventListView()),
        GetPage(name: '/event/:id', page: () => EventDetailView(eventId: Get.parameters['id']!)),
        GetPage(name: '/admin-events', page: () =>  AdminEventManagementView()),
        GetPage(name: '/my-registrations', page: () =>  FighterRegistrationsView()),
        GetPage(name: '/coach-registrations', page: () =>  CoachRegistrationsView()),
      ],
    );
  }
}


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  
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
}