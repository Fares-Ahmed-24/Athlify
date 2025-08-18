class Trainer {
  final String id;
  final String name;
  final String email;
  final String image;
  final int price;
  final String category;
  final String phone;
  final String location;
  final bool isAvailable;
  final String? bio;
  final int? experienceYears;
  final List<String>? gallery;
  final List<String>? certifications;

  Trainer({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.price,
    required this.category,
    required this.phone,
    required this.location,
    required this.isAvailable,
    this.bio,
    this.experienceYears,
    this.gallery,
    this.certifications,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      price: int.tryParse(json['price'].toString()) ?? 0,
      category: json['category'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      bio: json['bio'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      gallery: (json['gallery'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      certifications: (json['certifications'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'image': image,
      'price': price,
      'category': category,
      'phone': phone,
      'location': location,
      'isAvailable': isAvailable,
      'bio': bio,
      'experienceYears': experienceYears,
      'gallery': gallery,
      'certifications': certifications,
    };
  }
}
