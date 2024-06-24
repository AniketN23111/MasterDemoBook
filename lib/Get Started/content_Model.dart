class UnbordingContent {
  String image;
  String title;
  String discription;

  UnbordingContent({required this.image, required this.title, required this.discription});
}

List<UnbordingContent> contents = [
  UnbordingContent(
      title: 'Parlour',
      image: 'assets/images/Parlour.jpg',
      discription: ""
  ),
  UnbordingContent(
      title: 'SPA',
      image: 'assets/images/Spa.jpg',
      discription: " "
  ),
  UnbordingContent(
      title: 'Mens Salon',
      image: 'assets/images/Men.jpg',
      discription: ""
  ),
];