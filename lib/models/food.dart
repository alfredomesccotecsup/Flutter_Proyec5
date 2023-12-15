class Food {
  String name;
  String image;
  double cal;
  double time;
  double rate;
  int reviews;
  bool isLiked;

  Food({
    required this.name,
    required this.image,
    required this.cal,
    required this.time,
    required this.rate,
    required this.reviews,
    required this.isLiked,
  });
}

final List<Food> foods = [
  Food(
    name: "UNSA",
    image: "assets/images/unsa.png",
    cal: 120,
    time: 300,
    rate: 4.4,
    reviews: 23,
    isLiked: false,
  ),
  Food(
    name: "TECSUP",
    image: "assets/images/tecsup.png",
    cal: 140,
    time: 300,
    rate: 4.9,
    reviews: 23,
    isLiked: true,
  ),
  Food(
    name: "UCSM",
    image: "assets/images/UCSM.png",
    cal: 130,
    time: 300,
    rate: 4.2,
    reviews: 10,
    isLiked: false,
  ),
  Food(
    name: "USP",
    image: "assets/images/USP.png",
    cal: 110,
    time: 300,
    rate: 4.6,
    reviews: 90,
    isLiked: true,
  ),
  Food(
    name: "UTP",
    image: "assets/images/utp.png",
    cal: 150,
    time: 300,
    rate: 4.0,
    reviews: 76,
    isLiked: false,
  )
];
