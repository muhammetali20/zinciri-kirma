import 'dart:async';
import 'package:flutter/material.dart';
import 'habit_list_screen.dart'; // Ana ekranınıza giden yol
import '../utils/custom_page_route.dart'; // FadePageRoute için

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Animasyon kontrolcüsü
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Fade animasyonu - 0'dan başlayıp 1'e gidecek
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    // Ölçek animasyonu - 0.5'ten başlayıp 1'e gidecek
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    
    // Animasyonu başlat
    _controller.forward();
    
    // 3 saniye sonra ana ekrana geçiş
    Timer(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        FadePageRoute(child: const HabitListScreen()),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Logo için Image widget'ı kullanıyoruz
                    Image.asset(
                      'assets/icon/icon.png',
                      width: 180,
                      height: 180,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Zinciri Kırma',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'Minimalist Alışkanlık Takibi',
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        'Alışkanlıklarınızı yönetin, hedeflerinize ulaşın.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 