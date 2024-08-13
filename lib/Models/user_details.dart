class UserDetails {
  final String name;
  final String password;
  final String email;
  final String number;
  final int userID;
  final String imageURL;

  UserDetails({
    required this.name,
    required this.password,
    required this.email,
    required this.number,
    required this.userID,
    required this.imageURL,
  });
  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      name: json['name'],
      password: json['password'],
      email: json['email'],
      number: json['number'],
      userID: int.tryParse(json['user_id']) ?? 0,
      imageURL: json['image_url'],
    );
  }
}
