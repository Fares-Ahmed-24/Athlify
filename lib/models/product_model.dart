class Product {
  final String id;
  final String productName;
  final int productPrice;
  final String productImage;
  final String productDescription;
  final int quantity;
  final String productType;
  final String userId; // 👈 أضفنا ده

  Product({
    required this.id,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.productDescription,
    required this.quantity,
    required this.productType,
    required this.userId, // 👈 ضروري
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      productName: json['productName'] ?? '',
      productPrice: json['productPrice'] ?? 0,
      productImage: json['productImage'] ?? '',
      productDescription: json['productDescription'] ?? '',
      quantity: json['quantity'] ?? 1,
      productType: json['productType'] ?? 'equipment',
      userId: json['userId'] ?? '', // 👈 خدناه من الباك
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productName': productName,
      'productPrice': productPrice,
      'productImage': productImage,
      'productDescription': productDescription,
      'quantity': quantity,
      'productType': productType,
      'userId': userId, // 👈 مهم
    };
  }
}
