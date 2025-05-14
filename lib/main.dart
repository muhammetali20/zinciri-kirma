import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart'; // Or fflutter_riverpod if chosen
// import 'package:path_provider/path_provider.dart' as path_provider; // No longer needed for basic init
import 'package:intl/date_symbol_data_local.dart'; // Import for date formatting initialization
import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMob için import
import 'package:flutter/foundation.dart'; // kDebugMode için

// Import screens
import 'screens/habit_list_screen.dart'; // Placeholder, will create
import 'screens/splash_screen.dart'; // Import the splash screen

// Import models
import 'models/habit.dart'; // Import the Habit model and generated adapter

// Import services (will be created later)
// import 'services/habit_service.dart';

// Import providers (will be created later)
// import 'providers/habit_provider.dart';

// Define the box name as a constant
const String habitBoxName = 'habits';

// Test cihazlar için sabit tanımları
class TestDeviceAds {
  // Test cihaz kimlikleri
  static const List<String> testDeviceIds = [
    'kdev', // Bu özel bir anahtar - test cihazında bunu kullanınca gerçek cihaz ID'si konsola yazılır
    // 'Emulator cihazınızın ID'si'
  ];
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive in a specific directory (optional but good practice)
  // final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  // await Hive.initFlutter(appDocumentDir.path); // Use specific path
  await Hive.initFlutter(); // Or just use default path

  // Register Adapter
  Hive.registerAdapter(HabitAdapter()); // Now we can register the generated adapter

  // Open Hive boxes
  await Hive.openBox<Habit>(habitBoxName); // Open the box for habits

  // Initialize date formatting for Turkish locale
  await initializeDateFormatting('tr_TR', null);

  // AdMob SDK'yı başlat ve test cihazlarını ekle
  MobileAds.instance.initialize();
  
  // Test cihazları ekle - geliştirme sırasında gerçek reklamlar yerine test reklamlarını göster
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: kDebugMode ? TestDeviceAds.testDeviceIds : null,
    ),
  );

  // TODO: Initialize AdMob SDK
  // MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We might need a Provider here later for the HabitService
    return MaterialApp(
      title: 'Zinciri Kırma',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), // Updated theme
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal[700],
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
           backgroundColor: Colors.teal[600],
           foregroundColor: Colors.white,
        )
      ),
      // Initializing HabitListScreen - It needs to be created
      home: const SplashScreen(), // Start with the splash screen
    );
  }
} 