class AdminService {
  final String service;
  final String subService;
  final String imageIcon;

  AdminService({
    required this.service,
    required this.subService,
    required this.imageIcon,

  });
  factory AdminService.fromJson(Map<String, dynamic> json) {
    return AdminService(
      service: json['service'],
      subService: json['sub_service'],
      imageIcon: json['icon_url'],
    );
  }
}
