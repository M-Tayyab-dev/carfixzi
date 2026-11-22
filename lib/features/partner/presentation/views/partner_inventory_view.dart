import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../customer/domain/entities/part_item.dart';

/// D21: Partner Inventory Management
/// Allows workshop partners to view, search, and manage their spare parts stock.
/// Features:
/// - Category-filtered parts listing with stock levels
/// - Low reserve threshold alerts (amber warnings)
/// - Out-of-stock indicators (red badges)
/// - Add New SKU dialog for pilot catalog expansion
/// - Quick stock adjustment (+ / −)
class PartnerInventoryView extends StatefulWidget {
  const PartnerInventoryView({super.key});

  @override
  State<PartnerInventoryView> createState() => _PartnerInventoryViewState();
}

class _PartnerInventoryViewState extends State<PartnerInventoryView> {
  late List<_InventoryItem> _inventory;
  String _filterCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _categories = [
    'All',
    'Braking',
    'Fluids & Lubes',
    'Ignition',
    'Filters',
    'Engine',
  ];

  @override
  void initState() {
    super.initState();
    // Seed with pilot parts belonging to current partner (ws_01)
    _inventory = PartItem.pilotParts
        .where((p) => p.partnerId == 'ws_01')
        .map((p) => _InventoryItem.fromPartItem(p))
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_InventoryItem> get _filteredInventory {
    return _inventory.where((item) {
      final matchCategory = _filterCategory == 'All' || item.category == _filterCategory;
      final matchSearch = _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  int get _totalLowStock => _inventory.where((i) => i.isLowStock).length;
  int get _totalOutOfStock => _inventory.where((i) => i.isOutOfStock).length;

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredInventory;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Parts Inventory', style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSkuDialog,
        backgroundColor: AppColors.accentGold,
        foregroundColor: AppColors.darkSlate,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Part',
          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Summary Statistics Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.surfaceContainerLowest,
              child: Row(
                children: [
                  _StatChip(
                    label: 'Total Parts',
                    value: '${_inventory.length}',
                    color: AppColors.primaryContainer,
                  ),
                  const SizedBox(width: 12),
                  _StatChip(
                    label: 'Low Stock',
                    value: '$_totalLowStock',
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 12),
                  _StatChip(
                    label: 'Out of Stock',
                    value: '$_totalOutOfStock',
                    color: AppColors.error,
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search by part name or SKU...',
                  hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.outline),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color.fromRGBO(45, 49, 66, 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color.fromRGBO(45, 49, 66, 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Category Filter Chips
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _filterCategory;
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : const Color.fromRGBO(45, 49, 66, 0.1),
                      ),
                      onSelected: (_) => setState(() => _filterCategory = cat),
                    ),
                  );
                },
              ),
            ),

            // Inventory List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No parts match your filter.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _InventoryCard(
                          item: item,
                          onStockAdjust: (delta) {
                            setState(() {
                              item.stock = (item.stock + delta).clamp(0, 9999);
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSkuDialog() {
    final skuCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    String selectedCategory = 'Braking';

    Get.defaultDialog(
      title: 'Add New Part',
      titleStyle: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
      contentPadding: const EdgeInsets.all(20),
      content: StatefulBuilder(
        builder: (context, setDialogState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: skuCtrl,
              decoration: InputDecoration(
                labelText: 'Part Code',
                hintText: 'e.g. BRK-DISC-001',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'Part Name',
                hintText: 'e.g. Front Disc Rotor Set',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: ['Braking', 'Fluids & Lubes', 'Ignition', 'Filters', 'Engine']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setDialogState(() => selectedCategory = v!),
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price (Rs)',
                      hintText: '5000',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: stockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Initial Stock',
                      hintText: '20',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.darkSlate,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () {
          final sku = skuCtrl.text.trim();
          final title = titleCtrl.text.trim();
          final price = int.tryParse(priceCtrl.text.trim()) ?? 0;
          final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;

          if (sku.isEmpty || title.isEmpty || price <= 0) {
            Get.snackbar(
              'Validation Error',
              'Please fill Part Code, Part Name and a valid Price.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.errorContainer,
              colorText: AppColors.error,
            );
            return;
          }

          setState(() {
            _inventory.add(_InventoryItem(
              id: 'part_custom_${DateTime.now().millisecondsSinceEpoch}',
              sku: sku,
              title: title,
              category: selectedCategory,
              compatibility: 'Universal',
              pricePaisa: price * 100,
              stock: stock,
              minReserve: 5,
            ));
          });

          Get.back();
          Get.snackbar(
            'Part Added',
            '$title ($sku) added to your inventory.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        },
        child: const Text('Add Part'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }
}

/// Internal mutable inventory model for partner-side stock management
class _InventoryItem {
  final String id;
  final String sku;
  final String title;
  final String category;
  final String compatibility;
  final int pricePaisa;
  int stock;
  final int minReserve;

  _InventoryItem({
    required this.id,
    required this.sku,
    required this.title,
    required this.category,
    required this.compatibility,
    required this.pricePaisa,
    required this.stock,
    required this.minReserve,
  });

  bool get isLowStock => stock > 0 && stock <= minReserve;
  bool get isOutOfStock => stock <= 0;

  factory _InventoryItem.fromPartItem(PartItem p) => _InventoryItem(
        id: p.id,
        sku: p.sku,
        title: p.title,
        category: p.category,
        compatibility: p.compatibility,
        pricePaisa: p.pricePaisa,
        stock: p.availableStock,
        minReserve: p.minReserveThreshold,
      );
}

class _InventoryCard extends StatelessWidget {
  final _InventoryItem item;
  final void Function(int delta) onStockAdjust;

  const _InventoryCard({
    required this.item,
    required this.onStockAdjust,
  });

  @override
  Widget build(BuildContext context) {
    return CarfixziCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Category + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.sku,
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.category,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                  ),
                ],
              ),
              if (item.isOutOfStock)
                const StatusBadge(label: 'OUT OF STOCK', variant: StatusBadgeVariant.error)
              else if (item.isLowStock)
                const StatusBadge(label: 'LOW RESERVE', variant: StatusBadgeVariant.warning)
              else
                const StatusBadge(label: 'IN STOCK', variant: StatusBadgeVariant.success),
            ],
          ),
          const SizedBox(height: 10),

          // Part Title & Compatibility
          Text(
            item.title,
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            item.compatibility,
            style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
          ),
          const SizedBox(height: 12),

          // Price & Stock Adjuster Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price
              Text(
                CurrencyUtils.formatPaisa(item.pricePaisa),
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),

              // Stock level with +/- buttons
              Row(
                children: [
                  Text(
                    'Stock: ',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                  ),
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
                        InkWell(
                          onTap: item.stock > 0 ? () => onStockAdjust(-1) : null,
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.remove_rounded,
                              size: 16,
                              color: item.stock > 0 ? AppColors.darkSlate : AppColors.outline,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${item.stock}',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: item.isOutOfStock
                                  ? AppColors.error
                                  : item.isLowStock
                                      ? AppColors.warning
                                      : AppColors.darkSlate,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => onStockAdjust(1),
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Low reserve warning callout
          if (item.isLowStock)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warningContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Below minimum reserve threshold (${item.minReserve} units). Restock recommended.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.warning,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
