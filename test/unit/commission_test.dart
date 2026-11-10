import 'package:flutter_test/flutter_test.dart';
import 'package:carfixzi/core/utils/currency_utils.dart';

void main() {
  group('CurrencyUtils.calculateCommission', () {
    test('10% on service revenue (1000 bps)', () {
      // Rs 24,200 revenue = 2420000 paisa at 1000 bps (10%)
      final comm = CurrencyUtils.calculateCommission(2420000, 1000);
      expect(comm, 242000); // Rs 2,420
    });

    test('5% on parts revenue (500 bps)', () {
      // Rs 8,540 revenue = 854000 paisa at 500 bps (5%)
      final comm = CurrencyUtils.calculateCommission(854000, 500);
      expect(comm, 42700); // Rs 427
    });

    test('zero rate returns zero', () {
      final comm = CurrencyUtils.calculateCommission(1000000, 0);
      expect(comm, 0);
    });

    test('zero revenue returns zero', () {
      final comm = CurrencyUtils.calculateCommission(0, 1000);
      expect(comm, 0);
    });

    test('30% max rate (3000 bps)', () {
      // Rs 10,000 = 1000000 paisa at 3000 bps (30%)
      final comm = CurrencyUtils.calculateCommission(1000000, 3000);
      expect(comm, 300000); // Rs 3,000
    });

    test('fractional paisa rounds correctly', () {
      // 333 paisa at 1000 bps = 33.3 paisa -> rounds to 33
      // (333 * 1000 + 5000) ~/ 10000 = 338000 ~/ 10000 = 33
      final comm = CurrencyUtils.calculateCommission(333, 1000);
      expect(comm, 33);
    });

    test('1 paisa at 1 bps rounds to 0 or 1', () {
      // (1 * 1 + 5000) ~/ 10000 = 5001 ~/ 10000 = 0
      final comm = CurrencyUtils.calculateCommission(1, 1);
      expect(comm, 0);
    });

    test('large revenue at standard rate', () {
      // Rs 3,27,400 = 32740000 paisa at 1000 bps (10%)
      final comm = CurrencyUtils.calculateCommission(32740000, 1000);
      expect(comm, 3274000); // Rs 32,740
    });
  });
}

