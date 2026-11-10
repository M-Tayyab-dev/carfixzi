import 'package:intl/intl.dart';

/// Monetary utility for integer PKR paisa calculations and formatting.
/// Invariant: 100 paisa = 1 PKR. Floating-point arithmetic is strictly avoided.
class CurrencyUtils {
  static final NumberFormat _formatter = NumberFormat("#,##0.00", "en_US");
  static final NumberFormat _wholeFormatter = NumberFormat("#,##0", "en_US");

  /// Formats integer paisa to display string with PKR symbol (e.g. 500000 paisa -> "Rs 5,000.00")
  static String formatPaisa(int paisa, {bool includeDecimals = true}) {
    final rupees = paisa / 100.0;
    return 'Rs ${includeDecimals ? _formatter.format(rupees) : _wholeFormatter.format(rupees)}';
  }

  /// Converts whole rupees to paisa (e.g. 5000 Rs -> 500000 paisa)
  static int rupeesToPaisa(int rupees) {
    return rupees * 100;
  }

  /// Calculates commission in paisa from basis points (rateBps)
  /// Formula: roundHalfUp(eligibleBaseMinor * rateBps / 10000)
  static int calculateCommission(int eligibleBasePaisa, int rateBps) {
    final raw = (eligibleBasePaisa * rateBps + 5000) ~/ 10000;
    return raw;
  }
}

