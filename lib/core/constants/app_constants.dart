/// Global Application Constants for CARFIXZI
class AppConstants {
  static const String appName = 'CARFIXZI';
  static const String appTagline = 'Verified Automotive Services & Marketplace';
  static const String appVersion = '1.0.0';

  // Pilot Geography (Default pilot city: Sahiwal / Configurable)
  static const String defaultCityId = 'sahiwal_pk';
  static const String defaultCityName = 'Sahiwal, Pakistan';
  static const double defaultLatitude = 30.6682;
  static const double defaultLongitude = 73.1114;

  // Currency
  static const String currencyCode = 'PKR';
  static const String currencySymbol = 'Rs ';

  // Password Policy: Minimum 12 characters, uppercase, lowercase, number, symbol
  static const int minPasswordLength = 12;

  // OpenStreetMap Tile Configuration
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmUserAgent = 'com.carfixzi.app';
  static const String osmAttribution = '© OpenStreetMap contributors';

  // Commission Baseline Defaults (Illustrative demo values)
  static const int defaultServiceCommissionBps = 1000; // 10.00%
  static const int defaultPartsCommissionBps = 500;    // 5.00%
}

