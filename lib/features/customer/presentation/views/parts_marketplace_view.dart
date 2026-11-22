import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../app/routes/app_routes.dart';
import '../../domain/entities/part_item.dart';
import '../controllers/cart_controller.dart';

/// NEW-05: Spare Parts Marketplace (Customer Android)
/// Allows vehicle owners to discover, filter and purchase verified workshop parts.
class PartsMarketplaceView extends StatefulWidget {
  const PartsMarketplaceView({super.key});

  @override
  State<PartsMarketplaceView> createState() => _PartsMarketplaceViewState();
}

class _PartsMarketplaceViewState extends State<PartsMarketplaceView> {
  final List<PartItem> _allParts = PartItem.pilotParts;
  String _selectedCategory = 'All Parts';
  late CartController _cartCtrl;

  final List<String> _categories = [
    'All Parts',
    'Braking',
    'Fluids & Lubes',
    'Ignition',
    'Filters',
  ];

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<CartController>()) {
      _cartCtrl = Get.put(CartController());
    } else {
      _cartCtrl = Get.find<CartController>();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredParts = _selectedCategory == 'All Parts'
        ? _allParts
        : _allParts.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Spare Parts Marketplace', style: AppTypography.headlineSmall),
        actions: [
          IconButton(
            tooltip: 'View Cart',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_outlined),
                Obx(() {
                  final count = _cartCtrl.itemCount;
                  if (count == 0) return const SizedBox.shrink();
                  return Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accentGold,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.darkSlate,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            onPressed: () => Get.toNamed(AppRoutes.cart),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Filter Pills
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      labelStyle: AppTypography.labelSmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      selectedColor: AppColors.primaryContainer,
                      backgroundColor: AppColors.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : const Color.fromRGBO(45, 49, 66, 0.1),
                      ),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  );
                },
              ),
            ),

            // Parts List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filteredParts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final part = filteredParts[index];
                  return CarfixziCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.build_circle_outlined, size: 36, color: AppColors.primaryContainer),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    part.category.toUpperCase(),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.outline,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  if (part.isLowStock)
                                    const StatusBadge(label: 'LOW STOCK', variant: StatusBadgeVariant.warning)
                                  else if (part.isOutOfStock)
                                    const StatusBadge(label: 'OUT OF STOCK', variant: StatusBadgeVariant.error)
                                  else
                                    const StatusBadge(label: 'IN STOCK', variant: StatusBadgeVariant.success),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                part.title,
                                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'SKU: ${part.sku} · ${part.compatibility}',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      CurrencyUtils.formatPaisa(part.pricePaisa),
                                      style: AppTypography.headlineSmall.copyWith(
                                        color: AppColors.primaryContainer,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentGold,
                                      foregroundColor: AppColors.darkSlate,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      minimumSize: const Size(0, 34),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
                                    label: const Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      _cartCtrl.addToCart(part);
                                      Get.snackbar(
                                        'Added to Cart',
                                        '${part.title} added to your spare parts cart.',
                                        snackPosition: SnackPosition.BOTTOM,
                                        duration: const Duration(seconds: 2),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Floating Cart Bottom Bar
      bottomNavigationBar: Obx(() {
        if (_cartCtrl.itemCount == 0) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_cartCtrl.itemCount} items selected',
                    style: AppTypography.bodySmall,
                  ),
                  Text(
                    CurrencyUtils.formatPaisa(_cartCtrl.subtotalPaisa),
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.shopping_bag_rounded, size: 18),
                label: const Text('View Cart & Checkout'),
                onPressed: () => Get.toNamed(AppRoutes.cart),
              ),
            ],
          ),
        );
      }),
    );
  }
}

