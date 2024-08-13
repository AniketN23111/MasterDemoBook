class MentorService {
  final int advisorID;
  final String mainService;
  final String subService;
  final int rate;
  final int quantity;
  final String unitMeasurement;

  MentorService({
    required this.advisorID,
    required this.mainService,
    required this.subService,
    required this.rate,
    required this.quantity,
    required this.unitMeasurement,
  });
  factory MentorService.fromJson(Map<String, dynamic> json) {
    return MentorService(
      advisorID: json['advisor_id'] ?? 0,
      mainService: json['main_service'],
      subService: json['sub_service'],
      rate: json['rate'] ?? 0,
      quantity: json['quantity'] ?? 0,
      unitMeasurement: json['unit_of_measurement'],

    );
  }
}
