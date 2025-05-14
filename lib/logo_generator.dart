import 'package:flutter/material.dart';

/// Logo üretici sayfası - Screenshot alıp icon olarak kullanabilirsiniz
void main() {
  runApp(const LogoGeneratorApp());
}

class LogoGeneratorApp extends StatelessWidget {
  const LogoGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Debug banner'ı kaldır
      title: 'Logo Oluşturucu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LogoGeneratorScreen(),
    );
  }
}

class LogoGeneratorScreen extends StatelessWidget {
  const LogoGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ekran boyutunu al
    final screenSize = MediaQuery.of(context).size;
    // Logo için en küçük boyutu seç
    final logoSize = screenSize.width < screenSize.height 
        ? screenSize.width * 0.8 
        : screenSize.height * 0.8;
        
    return Scaffold(
      backgroundColor: Colors.white, // Arkaplan rengi
      body: Center(
        child: Container(
          width: logoSize, 
          height: logoSize,
          padding: EdgeInsets.all(logoSize * 0.05), // Responsive padding
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade700,
                Colors.blue.shade500,
              ],
            ),
            borderRadius: BorderRadius.circular(logoSize * 0.2), // Yuvarlaklık
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Zincir simgesi
                Icon(
                  Icons.link_off_rounded, // Kırık zincir simgesi
                  size: 120,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                // Logo metni
                const Text(
                  'ZK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 72,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 