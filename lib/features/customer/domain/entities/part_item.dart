/// Spare Part Model for Marketplace & Inventory Management
class PartItem {
  final String id;
  final String partnerId;
  final String partnerName;
  final String sku;
  final String title;
  final String category; // 'Braking', 'Engine', 'Fluids & Lubes', 'Ignition'
  final String compatibility; // e.g. 'Honda Civic 2016-2021 / Toyota Corolla'
  final int pricePaisa; // Integer PKR Paisa
  final int availableStock;
  final int minReserveThreshold;
  final bool isDeliveryAvailable;
  final bool isPickupAvailable;

  const PartItem({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.sku,
    required this.title,
    required this.category,
    required this.compatibility,
    required this.pricePaisa,
    required this.availableStock,
    this.minReserveThreshold = 5,
    this.isDeliveryAvailable = true,
    this.isPickupAvailable = true,
  });

  bool get isLowStock => availableStock <= minReserveThreshold && availableStock > 0;
  bool get isOutOfStock => availableStock <= 0;

  /// Pilot spare parts seed catalog
  static List<PartItem> get pilotParts => [
        const PartItem(
          id: 'part_01',
          partnerId: 'ws_01',
          partnerName: 'Apex GT Motorwerks',
          sku: 'BRK-CER-9921',
          title: 'OEM Ceramic Front Brake Pads',
          category: 'Braking',
          compatibility: 'Honda Civic (2016-2022) 1.8L & 1.5T',
          pricePaisa: 650000, // Rs 6,500.00
          availableStock: 4, // Low reserve
          minReserveThreshold: 5,
        ),
        const PartItem(
          id: 'part_02',
          partnerId: 'ws_01',
          partnerName: 'Apex GT Motorwerks',
          sku: 'FLD-SYN-5W30',
          title: 'Fully Synthetic 5W-30 Engine Oil (4L)',
          category: 'Fluids & Lubes',
          compatibility: 'Universal Gasoline & Hybrid Engines',
          pricePaisa: 780000, // Rs 7,800.00
          availableStock: 18,
          minReserveThreshold: 6,
        ),
        const PartItem(
          id: 'part_03',
          partnerId: 'ws_01',
          partnerName: 'Apex GT Motorwerks',
          sku: 'IGN-PLUG-IRID',
          title: 'Laser Iridium Spark Plugs (Pack of 4)',
          category: 'Ignition',
          compatibility: 'Toyota Corolla GLi / Altis 1.6L & 1.8L',
          pricePaisa: 480000, // Rs 4,800.00
          availableStock: 2, // Low reserve
          minReserveThreshold: 4,
        ),
        const PartItem(
          id: 'part_04',
          partnerId: 'ws_02',
          partnerName: 'Royal Auto Detailing Hub',
          sku: 'FLT-CAB-HEPA',
          title: 'Activated Carbon AC Cabin Filter',
          category: 'Filters',
          compatibility: 'Suzuki Alto / Cultus / Wagon R',
          pricePaisa: 150000, // Rs 1,500.00
          availableStock: 25,
          minReserveThreshold: 5,
        ),
      ];
}

