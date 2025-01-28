// splash_screen.dart
import 'package:flutter/material.dart';
import 'farm_connect_screen.dart';

class SplashScreen extends StatefulWidget {
  final String? arg; // Add this to receive the argument
  const SplashScreen({Key? key, this.arg}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _tractorController;
  late AnimationController _titleController;
  late Animation<Offset> _tractorSlideAnimation;
  late Animation<double> _titleFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Tractor animation controller
    _tractorController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Title animation controller
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Tractor slide animation
    _tractorSlideAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-1.5, 0),
          end: const Offset(0, 0),
        ),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(1.5, 0),
        ),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(1.5, 0),
          end: const Offset(0, 0),
        ),
        weight: 40,
      ),
    ]).animate(CurvedAnimation(
      parent: _tractorController,
      curve: Curves.easeInOut,
    ));

    // Title fade animation
    _titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_titleController);

    // Start animations
    _tractorController.forward();

    // Show title when tractor reaches center
    _tractorController.addListener(() {
      if (_tractorController.value > 0.3 && _tractorController.value < 0.4) {
        _titleController.forward();
      }
    });

    if (widget.arg == null) {_navigateToHome();}

  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FarmConnectScreen()),
    );
  }

  @override
  void dispose() {
    _tractorController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: _tractorSlideAnimation,
              child: const Icon(
                Icons.agriculture,
                size: 80,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _titleFadeAnimation,
              child: const Text(
                'FarmConnect',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}