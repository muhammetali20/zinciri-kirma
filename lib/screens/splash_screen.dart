import 'dart:async';
import 'package:flutter/material.dart';
import 'habit_list_screen.dart'; // Ana ekranınıza giden yol
import '../utils/custom_page_route.dart'; // FadePageRoute için

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3), // Açılış ekranının ne kadar süre görüneceği
      () => Navigator.pushReplacement(
        context,
        FadePageRoute(child: const HabitListScreen()), // HabitListScreen'e geçiş
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer, // Temaya uygun bir arka plan
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // İsterseniz buraya bir logo da ekleyebilirsiniz
            // Image.asset('assets/logo.png', height: 120),
            // const SizedBox(height: 24),
            Text(
              'Zinciri Kırma',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            Text(
              'Minimalist Alışkanlık Takibi',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Alışkanlıklarınızı yönetin, hedeflerinize ulaşın.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 50),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
} 