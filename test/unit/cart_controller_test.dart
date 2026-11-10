import 'package:flutter_test/flutter_test.dart';
import 'package:carfixzi/features/customer/presentation/controllers/cart_controller.dart';
import 'package:carfixzi/features/customer/domain/entities/part_item.dart';

void main() {
  group('CartController', () {
    late CartController cart;

    setUp(() {
      cart = CartController();
    });

    test('starts empty', () {
      expect(cart.items.length, 0);
      expect(cart.itemCount, 0);
      expect(cart.subtotalPaisa, 0);
    });

    test('addToCart adds a new item with quantity 1', () {
      final part = PartItem.pilotParts[0]; // OEM Ceramic Front Brake Pads
      cart.addToCart(part);

      expect(cart.items.length, 1);
      expect(cart.itemCount, 1);
      expect(cart.items[0].quantity, 1);
      expect(cart.subtotalPaisa, part.pricePaisa);
    });

    test('addToCart increments quantity on duplicate', () {
      final part = PartItem.pilotParts[1]; // Engine Oil, stock 18
      cart.addToCart(part);
      cart.addToCart(part);

      expect(cart.items.length, 1);
      expect(cart.itemCount, 2);
      expect(cart.items[0].quantity, 2);
      expect(cart.subtotalPaisa, part.pricePaisa * 2);
    });

    test('addToCart respects available stock limit', () {
      // Spark Plugs, stock = 2
      final part = PartItem.pilotParts[2];
      cart.addToCart(part); // qty 1
      cart.addToCart(part); // qty 2 (max stock)
      cart.addToCart(part); // should NOT increment beyond stock

      expect(cart.items[0].quantity, 2);
      expect(cart.itemCount, 2);
    });

    test('addToCart refuses out of stock item', () {
      const outOfStock = PartItem(
        id: 'part_oos',
        partnerId: 'ws_01',
        partnerName: 'Test Shop',
        sku: 'OOS-001',
        title: 'Out of Stock Part',
        category: 'Engine',
        compatibility: 'Universal',
        pricePaisa: 100000,
        availableStock: 0,
      );
      cart.addToCart(outOfStock);

      expect(cart.items.length, 0);
      expect(cart.itemCount, 0);
    });

    test('increment increases quantity', () {
      final part = PartItem.pilotParts[1]; // stock 18
      cart.addToCart(part);
      cart.increment(part.id);

      expect(cart.items[0].quantity, 2);
    });

    test('increment respects stock ceiling', () {
      final part = PartItem.pilotParts[2]; // stock 2
      cart.addToCart(part); // qty 1
      cart.increment(part.id); // qty 2
      cart.increment(part.id); // capped at 2

      expect(cart.items[0].quantity, 2);
    });

    test('decrement reduces quantity', () {
      final part = PartItem.pilotParts[1]; // stock 18
      cart.addToCart(part);
      cart.addToCart(part); // qty 2
      cart.decrement(part.id);

      expect(cart.items[0].quantity, 1);
      expect(cart.items.length, 1);
    });

    test('decrement removes item when quantity reaches zero', () {
      final part = PartItem.pilotParts[0];
      cart.addToCart(part); // qty 1
      cart.decrement(part.id); // qty 0 -> remove

      expect(cart.items.length, 0);
      expect(cart.itemCount, 0);
    });

    test('subtotalPaisa calculates correctly for mixed items', () {
      final part1 = PartItem.pilotParts[0]; // 650000 paisa
      final part2 = PartItem.pilotParts[3]; // 150000 paisa
      cart.addToCart(part1);
      cart.addToCart(part2);
      cart.addToCart(part2); // qty 2

      // part1(650000 * 1) + part2(150000 * 2) = 950000
      expect(cart.subtotalPaisa, 950000);
      expect(cart.itemCount, 3);
    });

    test('clearCart empties everything', () {
      cart.addToCart(PartItem.pilotParts[0]);
      cart.addToCart(PartItem.pilotParts[1]);
      cart.clearCart();

      expect(cart.items.length, 0);
      expect(cart.itemCount, 0);
      expect(cart.subtotalPaisa, 0);
    });
  });

  group('CartLineItem', () {
    test('totalPaisa is price × quantity', () {
      const part = PartItem(
        id: 'test',
        partnerId: 'ws',
        partnerName: 'Shop',
        sku: 'T-001',
        title: 'Test Part',
        category: 'Engine',
        compatibility: 'All',
        pricePaisa: 350000,
        availableStock: 50,
      );
      final line = CartLineItem(part: part, quantity: 3);
      expect(line.totalPaisa, 1050000); // 350000 * 3
    });
  });
}

