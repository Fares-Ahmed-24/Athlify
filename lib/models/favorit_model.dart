import 'package:Athlify/models/user_model.dart'; // Assuming User model is in user_model.dart
import 'package:Athlify/models/trainer_model.dart'; // Assuming Trainer model is in trainer_model.dart

class Favorite {
  final String userId;
  final String itemId;
  final String itemType;
  final dynamic item; // Can be User or Trainer based on itemType

  Favorite({
    required this.userId,
    required this.itemId,
    required this.itemType,
    this.item,
  });

  // Convert from JSON to Favorite object
  factory Favorite.fromJson(Map<String, dynamic> json) {
    dynamic item;

    // Based on the itemType, parse the item differently
    if (json['itemType'] == 'user') {
      item = json['itemId'] is Map<String, dynamic>
          ? User.fromJson(json['itemId'])
          : null;
    } else if (json['itemType'] == 'trainer') {
      item = json['itemId'] is Map<String, dynamic>
          ? Trainer.fromJson(json['itemId'])
          : null;
    }

    return Favorite(
      userId: json['userId'],
      itemId: json['itemId'] is String ? json['itemId'] : json['itemId']['_id'],
      itemType: json['itemType'],
      item: item,
    );
  }

  // Convert the Favorite object to JSON
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'itemId': itemId,
        'itemType': itemType,
        // Optionally, you can include the item data (user or trainer)
        if (item != null) 'item': item is User ? (item as User).toJson() : (item as Trainer).toJson(),
      };
}
