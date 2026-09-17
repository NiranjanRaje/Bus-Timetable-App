class AdConfig {
  // Use test ads by default so a forgotten production flag fails safe.
  // Production build: flutter build appbundle --release --dart-define=USE_TEST_ADS=false
  // Test build: flutter build appbundle --release
  static const bool _useTestAds =
      bool.fromEnvironment('USE_TEST_ADS', defaultValue: true);

  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _liveBanner = 'ca-app-pub-6766080149505294/9171665972';

  static String get bannerUnitId => _useTestAds ? _testBanner : _liveBanner;
}
