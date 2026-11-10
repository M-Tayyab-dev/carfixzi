/// Service entity offered by workshops or mobile wash partners
class ServiceItem {
  final String id;
  final String partnerId;
  final String title;
  final String description;
  final int pricePaisa; // Integer PKR Paisa (e.g. 500000 = Rs 5,000.00)
  final String category; // 'repair', 'wash', 'mobile_mechanic', 'diagnostic'
  final bool isMotorcycleEligible;
  final bool isCarEligible;
  final int estimatedDurationMinutes;
  final bool isAutoConfirm; // true = instant slot reservation; false = manual workshop acceptance

  const ServiceItem({
    required this.id,
    required this.partnerId,
    required this.title,
    required this.description,
    required this.pricePaisa,
    required this.category,
    this.isMotorcycleEligible = true,
    this.isCarEligible = true,
    this.estimatedDurationMinutes = 60,
    this.isAutoConfirm = true,
  });

  /// Seed catalogue for pilot city (Sahiwal)
  static List<ServiceItem> get pilotServices => [
        const ServiceItem(
          id: 'srv_diag_01',
          partnerId: 'ws_01',
          title: 'Computerized Multi-Point Diagnostic',
          description: 'OBD sensor scanning, engine health check, and battery voltage inspection',
          pricePaisa: 250000, // Rs 2,500.00
          category: 'diagnostic',
          estimatedDurationMinutes: 45,
          isAutoConfirm: true,
        ),
        const ServiceItem(
          id: 'srv_brake_02',
          partnerId: 'ws_01',
          title: 'Full Brake Pad Replacement & Bleed',
          description: 'Ceramic brake pad fitment, rotor cleaning, and hydraulic brake fluid top-up',
          pricePaisa: 420000, // Rs 4,200.00
          category: 'repair',
          estimatedDurationMinutes: 90,
          isAutoConfirm: false,
        ),
        const ServiceItem(
          id: 'srv_wash_03',
          partnerId: 'ws_02',
          title: 'Doorstep Foam Wash & Interior Vacuum',
          description: 'Pressure snow foam wash, tire dressing, dashboard conditioning, and carpet vacuum',
          pricePaisa: 150000, // Rs 1,500.00
          category: 'wash',
          estimatedDurationMinutes: 60,
          isAutoConfirm: true,
        ),
        const ServiceItem(
          id: 'srv_mech_04',
          partnerId: 'ws_01',
          title: 'Mobile Jumpstart & Minor Issue Inspection',
          description: 'On-site roadside mechanic arrival with booster cables and tool kit',
          pricePaisa: 120000, // Rs 1,200.00
          category: 'mobile_mechanic',
          estimatedDurationMinutes: 30,
          isAutoConfirm: false,
        ),
      ];
}
