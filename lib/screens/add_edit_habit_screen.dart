import 'dart:io'; // Platformu kontrol etmek için
import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMob için
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class AddEditHabitScreen extends StatefulWidget {
  final Habit? habit; // Optional habit for editing

  const AddEditHabitScreen({super.key, this.habit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final HabitService _habitService = HabitService();
  bool _isEditing = false;
  Habit? _existingHabit; // For editing

  InterstitialAd? _interstitialAd;
  static int _newHabitCounter = 0;

  BannerAd? _bannerAd; // Banner Ad variable
  bool _isBannerAdLoaded = false; // Banner Ad loaded status

  // Android için gerçek reklam kimlikleri
  final String _androidInterstitialAdUnitId = 'ca-app-pub-6066087562934404/5086484726'; // Android geçiş reklamı
  final String _iosInterstitialAdUnitId = 'ca-app-pub-3940256099942544/4411468910'; // iOS için test kimliği
  // Banner reklam kimlikleri
  final String _androidBannerAdUnitId = 'ca-app-pub-6066087562934404/6054041918'; // Android banner reklamı
  final String _iosBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716'; // iOS için test kimliği

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _isEditing = true;
      _existingHabit = widget.habit;
      _nameController.text = _existingHabit!.name;
    }
    _loadBannerAd(); // Load banner ad on init
    _nameController.addListener(_onTextChanged); // Use a dedicated method for the listener
    print('[[ DEBUG ]] initState: Listener added.');
  }

  // Method to handle text changes
  void _onTextChanged() {
      print('[[ DEBUG ]] _onTextChanged: Text changed: "${_nameController.text}"');
      if (mounted) { // Ensure widget is still mounted before calling setState
        setState(() {}); 
      }
  }

  @override
  void dispose() {
    print('[[ DEBUG ]] dispose: Removing listener.');
    _nameController.removeListener(_onTextChanged); // Correctly remove the listener
    _nameController.dispose();
    _interstitialAd?.dispose();
    _bannerAd?.dispose(); // Dispose banner ad
    super.dispose();
  }

  // --- Banner Ad Loading Logic ---
  void _loadBannerAd() {
    String adUnitId = Platform.isAndroid ? _androidBannerAdUnitId : _iosBannerAdUnitId;
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(
        keywords: ['health', 'fitness', 'productivity'],
        nonPersonalizedAds: true,
      ),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('[[ DEBUG ]] AddEditHabitScreen BannerAd loaded.');
          if (mounted) { // Check if the widget is still in the tree
            setState(() {
              _isBannerAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('[[ DEBUG ]] AddEditHabitScreen BannerAd failedToLoad: $error');
          ad.dispose();
        },
        // Optional: Add other listeners if needed
      ),
    );
    _bannerAd?.load();
  }
  // --- End Banner Ad Loading Logic ---

  void _loadInterstitialAd() {
    String adUnitId = Platform.isAndroid ? _androidInterstitialAdUnitId : _iosInterstitialAdUnitId;
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(
        keywords: ['health', 'fitness', 'productivity'],
        nonPersonalizedAds: true,
      ),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('$ad loaded');
          _interstitialAd = ad;
          _setFullScreenContentCallback(); // Callback'leri ayarla
          _interstitialAd?.show(); // Reklamı hemen göster
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error.');
          _interstitialAd?.dispose();
          _interstitialAd = null;
        },
      ),
    );
  }

  void _setFullScreenContentCallback() {
     _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _interstitialAd = null; // Dispose sonrası null yap
        // Navigator.of(context).pop(); // Reklam kapandıktan sonra geri git (opsiyonel)
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _interstitialAd = null;
        // Navigator.of(context).pop(); // Hata durumunda da geri git (opsiyonel)
      },
    );
  }

  void _showInterstitialAdIfNeeded() {
    if (_newHabitCounter % 3 == 0) { // Her 3 alışkanlıkta bir
      print('Interstitial Ad will be loaded.');
      _loadInterstitialAd(); // Reklamı yükle ve göster
    }
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      final habitName = _nameController.text.trim();
      bool shouldShowAd = false;

      if (_isEditing) {
        // Update existing habit (Need an update method in service or handle here)
        final updatedHabit = _existingHabit!;
        updatedHabit.name = habitName;
        // Hive objects extending HiveObject can be saved directly
        updatedHabit.save();
        print('Habit updated: ${updatedHabit.name}');
      } else {
        // Add new habit
        _habitService.addHabit(habitName);
        print('Habit added: $habitName');
        _newHabitCounter++; // Sayacı artır
        print('New habit count: $_newHabitCounter');
        shouldShowAd = true;
        print('Interstitial Ad will be loaded.');
      }

      // Önce sayfadan çık, sonra reklamı yükle/göster (isteğe bağlı sıra)
      Navigator.of(context).pop(); 

      if (shouldShowAd) {
        _showInterstitialAdIfNeeded(); // Reklamı yükle ve göster
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowIcon = _nameController.text.trim().isNotEmpty;
    print('[[ DEBUG ]] build: Current text: "${_nameController.text}", shouldShowIcon: $shouldShowIcon');
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Alışkanlığı Düzenle' : 'Yeni Alışkanlık Ekle'),
      ),
      body: Column( // Wrap body with Column for banner ad
        children: [
          Expanded( // Make the form scrollable area expand
            child: SingleChildScrollView( // Keep the original scroll view
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Alışkanlık Adı',
                        hintText: 'Örn: Günde 2 litre su iç',
                        border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(12.0),
                        ),
                        // Conditionally show suffix icon based on the variable
                        suffixIcon: shouldShowIcon
                           ? IconButton(
                               icon: const Icon(Icons.check_circle, color: Colors.green),
                               tooltip: _isEditing ? 'Değişiklikleri Kaydet' : 'Alışkanlığı Ekle',
                               onPressed: _saveHabit, // Call save method directly
                             )
                           : null, // Show nothing if text is empty
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen bir alışkanlık adı girin.';
                        }
                        return null;
                      },
                      // Optionally trigger save on text field submission
                      // onFieldSubmitted: (_) => _saveHabit(), 
                    ),
                    const SizedBox(height: 16),
                    _buildSuggestionChips(), // Suggestion chips
                    // TODO: Add other fields later if needed
                  ],
                ),
              ),
            ),
          ),
           // --- Banner Ad Widget ---
          if (_isBannerAdLoaded && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          // --- End Banner Ad Widget ---
        ],
      ),
    );
  }

  // Helper widget to build suggestion chips
  Widget _buildSuggestionChips() {
    final List<String> suggestions = [
      'Su İç',
      'Kitap Oku',
      'Egzersiz Yap',
      'Meditasyon Yap',
      'Erken Uyan'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Öneriler:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0, // Horizontal space between chips
          runSpacing: 4.0, // Vertical space between lines of chips
          children: suggestions.map((suggestion) {
            return ActionChip(
              label: Text(suggestion),
              onPressed: () {
                _nameController.text = suggestion; // Set text field value on tap
                _nameController.selection =
                    TextSelection.fromPosition(TextPosition(offset: _nameController.text.length));
              },
              // Modern tag styling
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 13, // Slightly smaller font
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0), // Adjust padding
              shape: RoundedRectangleBorder( // More defined shape
                 borderRadius: BorderRadius.circular(16.0),
                 side: BorderSide(
                   color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                   width: 0.5,
                 )
              ),
               elevation: 0, // No shadow
               pressElevation: 1, // Slight elevation on press
            );
          }).toList(),
        ),
      ],
    );
  }
} 