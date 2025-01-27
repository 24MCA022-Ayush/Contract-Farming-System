// app_routes.dart

import 'package:demo/farm_connect_screen.dart';
import 'package:demo/screens/farmer_profile_page.dart';
import 'package:demo/screens/home_page.dart';
import 'package:demo/screens/login_page.dart';
import 'package:demo/screens/register_page.dart';
import 'package:flutter/material.dart';

import '../screens/farmerRegister.dart';

class AppRoutes
{
  const AppRoutes._();

  static const String login = 'login';
  static const String register = 'register';
  static const String farm_connect = 'farm_connect';
  static const String homepage = 'homepage';
  static const String farmer_register = 'farmer_register';
  static const String farmer_profile = 'farmer_profile';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      farm_connect: (context) => const FarmConnectScreen(),
      farmer_register: (context) => const FarmerRegister(),
      farmer_profile: (context) => const FarmerProfilePage(),
      // ... other routes
    };
  }
}
