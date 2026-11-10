import 'package:get/get.dart';
import '../../domain/entities/part_item.dart';

class CartLineItem {
  final PartItem part;
  int quantity;

  CartLineItem({required this.part, this.quantity = 1});

  int get totalPaisa => part.pricePaisa * quantity;
}

/// GetxController managing customer shopping cart and inventory reservation
class CartController extends GetxController {
  final RxList<CartLineItem> items = <CartLineItem>[].obs;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  int get subtotalPaisa => items.fold(0, (sum, i) => sum + i.totalPaisa);

  void addToCart(PartItem part) {
    final index = items.indexWhere((i) => i.part.id == part.id);
    if (index != -1) {
      if (items[index].quantity < part.availableStock) {
        items[index].quantity++;
        items.refresh();
      }
    } else {
      if (part.availableStock > 0) {
        items.add(CartLineItem(part: part, quantity: 1));
      }
    }
  }

  void increment(String partId) {
    final index = items.indexWhere((i) => i.part.id == partId);
    if (index != -1) {
      if (items[index].quantity < items[index].part.availableStock) {
        items[index].quantity++;
        items.refresh();
      }
    }
  }

  void decrement(String partId) {
    final index = items.indexWhere((i) => i.part.id == partId);
    if (index != -1) {
      if (items[index].quantity > 1) {
        items[index].quantity--;
        items.refresh();
      } else {
        items.removeAt(index);
      }
    }
  }

  void clearCart() {
    items.clear();
  }
}

