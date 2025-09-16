import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../utils/app_layout.dart';
import '../../utils/my_helper.dart';
import 'onboarding/onboarding_screen.dart';

class NewSplashScreen extends StatefulWidget {
  const NewSplashScreen({super.key});

  @override
  State<NewSplashScreen> createState() => _NewSplashScreenState();
}

class _NewSplashScreenState extends State<NewSplashScreen> {
  GetStorage sharedPref = GetStorage();

  @override
  void initState() {
    super.initState();
    // Mark that the app has been launched at least once
    sharedPref.write(MyHelper.firstLaunch, false);

    // Navigate to onboarding after delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLayout.screenPortrait1();
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0E1A),
                  Color(0xFF1A1F2E),
                ],
              ),
            ),
          ),

          // Center logo/content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo or icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF4F46E5),
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 40),

                // App name
                const Text(
                  'ECLIPSE VPN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),

                // Slogan
                Text(
                  'Secure & Fast Connection',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 60),

                // Loading indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
