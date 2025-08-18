class ClubModel {
  final String id;
  final String name;
  final String email;
  final String location;
  final int price;
  final String clubType;
  final String? image;
  final String clubStatue;

  ClubModel({
    required this.id,
    required this.name,
    required this.email,
    required this.location,
    required this.price,
    required this.clubType,
    required this.clubStatue,
    this.image,
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) {
    return ClubModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      email: json['email'] ?? '',
      price: json['price'] ?? 0,
      clubType: json['clubType'] ?? '',
      image: json['image'],
      clubStatue: json['clubStatue'] ?? 'available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'location': location,
      'price': price,
      'clubType': clubType,
      'image': image,
      'clubStatue': clubStatue,
    };
  }
}
