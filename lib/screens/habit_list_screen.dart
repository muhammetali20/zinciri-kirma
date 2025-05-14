import 'dart:io'; // Platformu kontrol etmek için
import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMob için

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // For ValueListenableBuilder
import 'package:intl/intl.dart'; // For date formatting if needed

import '../models/habit.dart';
import '../services/habit_service.dart';
import 'add_edit_habit_screen.dart'; // Import the new screen
import 'habit_detail_screen.dart'; // Import the detail screen
import '../utils/custom_page_route.dart'; // Import the custom route
// import 'habit_detail_screen.dart'; // Navigate to detail screen (create later)

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  final HabitService _habitService = HabitService();
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  // Android banner reklamı için gerçek kimlik
  final String _androidBannerAdUnitId = 'ca-app-pub-6066087562934404/6054041918';
  final String _iosBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716'; // iOS için test kimliği

  @override
  void initState() {
    print('[[ DEBUG ]] _HabitListScreenState: initState START');
    super.initState();
    print('[HabitListScreen] initState called'); // initState çağrısını kontrol et
    _loadBannerAd();
    print('[[ DEBUG ]] _HabitListScreenState: initState END');
  }

  void _loadBannerAd() {
    print('[[ DEBUG ]] _HabitListScreenState: _loadBannerAd START');
    print('[HabitListScreen] _loadBannerAd called'); // Fonksiyon çağrısını kontrol et
    String adUnitId = Platform.isAndroid ? _androidBannerAdUnitId : _iosBannerAdUnitId;
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(
        keywords: ['health', 'fitness', 'productivity'], // Anahtar kelimeler ekle
        nonPersonalizedAds: true, // Kişiselleştirilmiş olmayan reklamlar göster
      ),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('[[ DEBUG ]] $BannerAd loaded.');
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('[[ DEBUG ]] $BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('[[ DEBUG ]] $BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('[[ DEBUG ]] $BannerAd onAdClosed.'),
        onAdImpression: (Ad ad) => print('[[ DEBUG ]] $BannerAd onAdImpression.'),
      ),
    );
    _bannerAd?.load();
    print('[[ DEBUG ]] _HabitListScreenState: _loadBannerAd END');
  }

  @override
  void dispose() {
    print('[[ DEBUG ]] _HabitListScreenState: dispose called');
    _bannerAd?.dispose();
    super.dispose();
  }

  void _navigateToAddHabitScreen() {
    Navigator.push(
      context,
      FadePageRoute(child: const AddEditHabitScreen()), // Use FadePageRoute
    );
  }

  void _navigateToEditHabitScreen(Habit habit) {
     Navigator.push(
      context,
      FadePageRoute(child: AddEditHabitScreen(habit: habit)), // Use FadePageRoute
    );
  }

  void _navigateToDetailScreen(Habit habit) {
     Navigator.push(
      context,
      FadePageRoute(child: HabitDetailScreen(habit: habit)), // Use FadePageRoute
    );
  }

  @override
  Widget build(BuildContext context) {
    print('[[ DEBUG ]] _HabitListScreenState: build called');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alışkanlık Takibi'),
        // TODO: Add potential actions like filtering or settings
      ),
      body: Column( // Wrap body with Column
        children: [
          Expanded( // Make ListView take available space
            child: ValueListenableBuilder(
              valueListenable: _habitService.getHabitListenable(),
              builder: (context, Box<Habit> box, _) {
                final habits = box.values.toList();
                // Sort habits by creation date - newest first might be better for lists
                habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (habits.isEmpty) {
                  return const Center(
                    child: Text(
                      'Henüz alışkanlık eklemediniz.\nBaşlamak için + butonuna dokunun.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    final bool isCompletedToday = habit.isCompletedToday();
                    final int streak = habit.currentStreak;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        leading: IconButton(
                          icon: Icon(
                            isCompletedToday ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isCompletedToday ? Colors.green : Colors.grey,
                            size: 30,
                            semanticLabel: isCompletedToday ? 'Bugün tamamlandı' : 'Bugün tamamlanmadı',
                          ),
                          tooltip: isCompletedToday ? 'Tamamlamayı geri al' : 'Bugün tamamla',
                          onPressed: () {
                            _habitService.toggleHabitCompletion(habit.id);
                          },
                        ),
                        title: Text(habit.name),
                        subtitle: Text(streak > 0 ? '🔥 Seri: $streak gün' : 'Henüz seri yok'), // Show streak more engagingly
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min, // Prevent Row from taking full width
                          children: [
                             IconButton(
                               icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
                               tooltip: 'Düzenle',
                               onPressed: () => _navigateToEditHabitScreen(habit),
                             ),
                             IconButton(
                               icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                               tooltip: 'Sil',
                               onPressed: () {
                                 // Confirmation dialog before deleting
                                 showDialog(
                                   context: context,
                                   builder: (ctx) => AlertDialog(
                                     title: const Text('Alışkanlığı Sil'),
                                     content: Text('"${habit.name}" alışkanlığını silmek istediğinizden emin misiniz?'),
                                     actions: <Widget>[
                                       TextButton(
                                         child: const Text('İptal'),
                                         onPressed: () {
                                           Navigator.of(ctx).pop();
                                         },
                                       ),
                                       TextButton(
                                         style: TextButton.styleFrom(
                                          foregroundColor: Theme.of(context).colorScheme.error,
                                         ),
                                         child: const Text('Sil'),
                                         onPressed: () {
                                           _habitService.deleteHabit(habit.id);
                                           Navigator.of(ctx).pop(); // Close the dialog
                                         },
                                       ),
                                     ],
                                   ),
                                 );
                               },
                             ),
                          ],
                        ),
                        onTap: () => _navigateToDetailScreen(habit), // Navigate to detail screen
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Add Banner Ad container at the bottom of the body
          if (_isBannerAdLoaded && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddHabitScreen,
        tooltip: 'Yeni Alışkanlık Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
} 