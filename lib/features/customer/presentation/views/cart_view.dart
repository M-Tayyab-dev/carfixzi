import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/carfixzi_button.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/cart_controller.dart';

/// Shopping Cart View — Itemized spare parts checkout
/// Shows added parts, quantity stepper (+/−), subtotal in PKR Paisa,
/// delivery / pickup toggle, and route to checkout.
class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartCtrl = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Your Cart', style: AppTypography.headlineSmall),
        centerTitle: true,
        actions: [
          Obx(() {
            if (cartCtrl.items.isEmpty) return const SizedBox.shrink();
            return TextButton(
              onPressed: () => _confirmClearCart(cartCtrl),
              child: Text(
                'Clear All',
                style: AppTypography.labelSmall.copyWith(color: AppColors.error),
              ),
            );
          }),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (cartCtrl.items.isEmpty) {
          return _EmptyCartState();
        }

        return Column(
          children: [
            // Cart items list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cartCtrl.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final lineItem = cartCtrl.items[index];
                  return _CartItemCard(
                    lineItem: lineItem,
                    onIncrement: () => cartCtrl.increment(lineItem.part.id),
                    onDecrement: () => cartCtrl.decrement(lineItem.part.id),
                  );
                },
              ),
            ),

            // Delivery Method + Summary Footer
            _CartSummaryFooter(cartCtrl: cartCtrl),
          ],
        );
      }),
    );
  }

  void _confirmClearCart(CartController cartCtrl) {
    Get.defaultDialog(
      title: 'Clear Cart?',
      titleStyle: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
      middleText: 'Remove all items from your spare parts cart?',
      textConfirm: 'Clear',
      textCancel: 'Keep',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        cartCtrl.clearCart();
        Get.back();
      },
    );
  }
}

/// Individual cart line item with quantity stepper
class _CartItemCard extends StatelessWidget {
  final CartLineItem lineItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemCard({
    required this.lineItem,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final part = lineItem.part;

    return CarfixziCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Part thumbnail placeholder
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.build_circle_outlined,
              size: 28,
              color: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(width: 12),

          // Part info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part.title,
                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'SKU: ${part.sku} · ${part.partnerName}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Text(
                      CurrencyUtils.formatPaisa(lineItem.totalPaisa),
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    // Quantity Stepper
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromRGBO(45, 49, 66, 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StepperButton(
                            icon: lineItem.quantity == 1
                                ? Icons.delete_outline_rounded
                                : Icons.remove_rounded,
                            color: lineItem.quantity == 1
                                ? AppColors.error
                                : AppColors.darkSlate,
                            onTap: onDecrement,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              '${lineItem.quantity}',
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          _StepperButton(
                            icon: Icons.add_rounded,
                            color: lineItem.quantity < part.availableStock
                                ? AppColors.primaryContainer
                                : AppColors.outline,
                            onTap: onIncrement,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Stock availability note
                if (lineItem.quantity >= part.availableStock)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Max available stock reached (${part.availableStock})',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warning,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

/// Cart summary footer with delivery toggle and checkout
class _CartSummaryFooter extends StatefulWidget {
  final CartController cartCtrl;

  const _CartSummaryFooter({required this.cartCtrl});

  @override
  State<_CartSummaryFooter> createState() => _CartSummaryFooterState();
}

class _CartSummaryFooterState extends State<_CartSummaryFooter> {
  bool _isDelivery = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: const Border(
          top: BorderSide(color: Color.fromRGBO(45, 49, 66, 0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Delivery / Pickup Toggle
            Row(
              children: [
                Expanded(
                  child: _FulfillmentOption(
                    icon: Icons.local_shipping_outlined,
                    label: 'Delivery',
                    isSelected: _isDelivery,
                    onTap: () => setState(() => _isDelivery = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FulfillmentOption(
                    icon: Icons.store_outlined,
                    label: 'Workshop Pickup',
                    isSelected: !_isDelivery,
                    onTap: () => setState(() => _isDelivery = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Summary Line
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.cartCtrl.itemCount} item${widget.cartCtrl.itemCount > 1 ? 's' : ''} · ${_isDelivery ? 'Delivery' : 'Pickup'}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyUtils.formatPaisa(widget.cartCtrl.subtotalPaisa),
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 180,
                      child: CarfixziButton(
                        text: 'Checkout',
                        icon: Icons.shopping_bag_rounded,
                        onPressed: () => Get.toNamed(AppRoutes.paymentCheckout),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class _FulfillmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FulfillmentOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CarfixziCard(
      onTap: onTap,
      color: isSelected ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow,
      border: Border.all(
        color: isSelected ? AppColors.primaryContainer : const Color.fromRGBO(45, 49, 66, 0.1),
        width: isSelected ? 2 : 1,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? AppColors.primaryContainer : AppColors.outline,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primaryContainer : AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty cart state with call-to-action
class _EmptyCartState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppColors.outline.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse our verified workshop parts marketplace to find OEM & aftermarket spare parts for your vehicle.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              child: CarfixziButton(
                text: 'Browse Parts',
                icon: Icons.search_rounded,
                variant: ButtonVariant.secondary,
                onPressed: () => Get.toNamed(AppRoutes.partsMarketplace),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
