import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/rating_model.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final RatingResponse? rating;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRestock;
  final bool showAdminActions;

  const ProductCard({
    Key? key,
    required this.product,
    this.rating,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onRestock,
    this.showAdminActions = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizes = product['sizes'] as List<dynamic>? ?? [];
    final int totalQuantity =
        sizes.fold<int>(0, (sum, s) => sum + ((s['quantity'] ?? 0) as int));
    final bool isSoldOut = totalQuantity == 0;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: ContainerColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                height: 120,
                width: double.infinity,
                color: Colors.grey[200],
                child: product["productImage"] != null &&
                        product["productImage"].isNotEmpty
                    ? Image.network(
                        product["productImage"],
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.image_not_supported,
                        color: Colors.grey[400], size: 40),
              ),
            ),

            // Product content
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["productName"] ?? 'No name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.indigo[900],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product["productPrice"]?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating != null
                            ? rating!.averageRating.toStringAsFixed(1)
                            : '0.0',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating != null ? '(${rating!.ratingCount})' : '(0)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  // Admin Actions
                  if (showAdminActions) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: onEdit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(70, 35),
                            backgroundColor: PrimaryColor,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Edit",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: onDelete,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(70, 35),
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Delete",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: ElevatedButton(
                        onPressed: onRestock,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(70, 35),
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Restock",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Sold Out overlay for non-admins
                  if (!showAdminActions && isSoldOut)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: Text(
                          'SOLD OUT',
                          style: TextStyle(
                            color: Colors.red[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
