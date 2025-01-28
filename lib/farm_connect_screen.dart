// farm_connect_screen.dart
import 'package:demo/values/app_routes.dart';
import 'package:flutter/material.dart';

class FarmConnectScreen extends StatelessWidget {
  const FarmConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40, width: 250),
              // App Logo and Title
              Icon(
                Icons.agriculture,
                size: 100,
                color: Colors.green[700],
              ),
              const Text(
                'FarmConnect',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 60),
              // Registration Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildButton(
                      icon: Icons.agriculture_rounded,
                      label: 'Farmers Login',
                      color: Colors.green[600]!,
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                            arguments: 'Farmer');
                      },
                    ),
                    const SizedBox(height: 16, width: 250,),
                    _buildButton(
                      icon: Icons.shopping_cart_outlined,
                      label: 'Buyer Login',
                      color: Colors.green[700]!,
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                            arguments: 'Buyer');
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildButton(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'FCO Login',
                      color: Colors.green[800]!,
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                            arguments: 'FCO');
                      },
                    ),

                  ],
                ),
              ),
              const Spacer(),
              // Decorative Bottom Element
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}