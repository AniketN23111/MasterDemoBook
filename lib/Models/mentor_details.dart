class MentorDetails {
  final String name;
  final String address;
  final String mobile;
  final String email;
  final String pincode;
  final String country;
  final String state;
  final String city;
  final String area;
  final String license;
  final String workingDays;
  final String timeSlots;
  final String imageURL;
  final int advisorID;
  final String companyName;
  final String designation;
  final String gender;
  final DateTime dateOfBirth;
  final String password;

  MentorDetails({
    required this.name,
    required this.address,
    required this.mobile,
    required this.email,
    required this.pincode,
    required this.country,
    required this.state,
    required this.city,
    required this.area,
    required this.license,
    required this.workingDays,
    required this.timeSlots,
    required this.imageURL,
    required this.advisorID,
    required this.companyName,
    required this.gender,
    required this.designation,
    required this.dateOfBirth,
    required this.password,
  });
  factory MentorDetails.fromJson(Map<String, dynamic> json) {
    return MentorDetails(
      name: json['name'],
      address: json['address'],
      mobile: json['mobile'],
      email: json['email'],
      pincode: json['pincode'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      area: json['area'],
      license: json['license'],
      workingDays: json['working_days'],
      timeSlots: json['timeslot'],
      imageURL: json['image_url'],
      advisorID:int.tryParse(json['advisor_id']) ?? 0,
      companyName: json['company_name'],
      designation: json['designation'],
      gender: json['gender'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      password: json['password'],
    );
  }
}
