class MentorService {
  final int shopId;
  final String mainService;
  final String subService;
  final int rate;
  final int quantity;
  final String unitMeasurement;

  MentorService({
    required this.shopId,
    required this.mainService,
    required this.subService,
    required this.rate,
    required this.quantity,
    required this.unitMeasurement,
  });
}
