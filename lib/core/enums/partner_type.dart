/// Partner Subtype
/// Note: Both workshops and independent wash partners share the same partner role,
/// but differ by partnerType attribute.
enum PartnerType {
  workshop,
  mobile_wash,
  both;

  String get displayName {
    switch (this) {
      case PartnerType.workshop:
        return 'Automotive Workshop';
      case PartnerType.mobile_wash:
        return 'Mobile Detailing & Wash';
      case PartnerType.both:
        return 'Full Service & Mobile Wash';
    }
  }

  static PartnerType fromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'mobile_wash':
        return PartnerType.mobile_wash;
      case 'both':
        return PartnerType.both;
      case 'workshop':
      default:
        return PartnerType.workshop;
    }
  }
}
