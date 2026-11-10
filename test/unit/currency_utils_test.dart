import 'package:flutter_test/flutter_test.dart';
import 'package:carfixzi/core/utils/currency_utils.dart';

void main() {
  group('CurrencyUtils Tests', () {
    test('formatPaisa correctly converts paisa to PKR display string', () {
      expect(CurrencyUtils.formatPaisa(500000), 'Rs 5,000.00');
      expect(CurrencyUtils.formatPaisa(500000, includeDecimals: false), 'Rs 5,000');
      expect(CurrencyUtils.formatPaisa(125075), 'Rs 1,250.75');
      expect(CurrencyUtils.formatPaisa(0), 'Rs 0.00');
    });

    test('rupeesToPaisa converts whole rupees to paisa', () {
      expect(CurrencyUtils.rupeesToPaisa(5000), 500000);
      expect(CurrencyUtils.rupeesToPaisa(250), 25000);
    });

    test('calculateCommission calculates correct commission in paisa from basis points', () {
      // 5,000 PKR service (500,000 paisa) at 10% (1,000 bps) -> 500 PKR (50,000 paisa)
      final servicePaisa = 500000;
      final serviceBps = 1000;
      expect(CurrencyUtils.calculateCommission(servicePaisa, serviceBps), 50000);

      // 2,000 PKR spare part (200,000 paisa) at 5% (500 bps) -> 100 PKR (10,000 paisa)
      final partsPaisa = 200000;
      final partsBps = 500;
      expect(CurrencyUtils.calculateCommission(partsPaisa, partsBps), 10000);
    });
  });
}
