/// 📊 نماذج التسعير
enum PricingModel {
  perBooking('PerBooking', 'لكل حجز'),
  perDay('PerDay', 'لكل يوم'),
  perPerson('PerPerson', 'لكل شخص'),
  perUnit('PerUnit', 'لكل وحدة'),
  perHour('PerHour', 'لكل ساعة'),
  fixed('Fixed', 'سعر ثابت');
  final String value;
  final String label;
  const PricingModel(this.value, this.label);

  /// يدعم قيَم التطبيق وقيَم الباك اند (Fixed/PerPerson/PerNight)
  static PricingModel fromValue(String value) {
    final normalized = value.trim();
    // Try app values
    for (final model in PricingModel.values) {
      if (model.value == normalized) return model;
    }
    // Map backend enum strings
    switch (normalized) {
      case 'Fixed':
        return PricingModel.fixed;
      case 'PerPerson':
        return PricingModel.perPerson;
      case 'PerNight':
        return PricingModel.perDay; // أقرب تمثيل لدينا
      default:
        return PricingModel.perBooking;
    }
  }
}
