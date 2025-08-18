import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/rating_model.dart';
import 'package:Athlify/services/rating%20_service.dart';
import 'package:Athlify/views/rating/dialogue_rating.dart';
import 'package:flutter/material.dart';

class ProductDetailsBottomSheet extends StatefulWidget {
  final Map<String, dynamic> product;
  final Future<void> Function(BuildContext, Map<String, dynamic>, int, String)
      onAddToCart;
  final Future<void> Function(BuildContext, Map<String, dynamic>)
      onAddToFavourites;
  final bool isInitiallyFavourite; // ✅ جديد

  const ProductDetailsBottomSheet({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onAddToFavourites,
    required this.isInitiallyFavourite,
  });

  @override
  State<ProductDetailsBottomSheet> createState() =>
      _ProductDetailsBottomSheetState();
}

class _ProductDetailsBottomSheetState extends State<ProductDetailsBottomSheet> {
  int quantity = 1;
  String? selectedSize;
  RatingResponse? _ratingData;
  bool isFavourite = false; // ✅ جديد

  @override
  void initState() {
    super.initState();
    isFavourite = widget.isInitiallyFavourite; // ✅ تعيين القيمة الأولية

    final sizes = widget.product['sizes'] as List<dynamic>?;

    if (sizes != null && sizes.isNotEmpty) {
      final firstAvailable = sizes.firstWhere(
        (s) => (s['quantity'] ?? 0) > 0,
        orElse: () => null,
      );
      if (firstAvailable != null) {
        selectedSize = firstAvailable['size'];
      }
    }

    _loadRatingData();
  }

  void _loadRatingData() async {
    try {
      final data =
          await RatingService.fetchAverageRating(widget.product['_id']);
      if (mounted) {
        setState(() {
          _ratingData = data;
        });
      }
    } catch (e) {
      print('Failed to load rating data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final sizes = product['sizes'] as List<dynamic>? ?? [];
    final average = _ratingData?.averageRating ?? 0.0;
    final count = _ratingData?.ratingCount ?? 0;

    int maxQty = sizes.fold<int>(0, (int sum, dynamic s) {
      final int qty = (s['quantity'] ?? 0).toInt();
      return sum + qty;
    });

    int selectedSizeQty = 0;
    if (selectedSize != null) {
      final sizeItem = sizes.firstWhere(
        (s) => s['size'] == selectedSize,
        orElse: () => null,
      );
      if (sizeItem != null) {
        selectedSizeQty = sizeItem['quantity'] ?? 0;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12, bottom: 16),
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product['productImage'] != null &&
                      product['productImage'].toString().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        product['productImage'],
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(Icons.image_not_supported,
                          size: 50, color: Colors.grey[400]),
                    ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product['productName'] ?? 'No name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: PrimaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${product['productPrice']?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: SecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          SizedBox(width: 4),
                          Text(
                            average.toStringAsFixed(1),
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '($count)',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      Text(
                        'Ship: 50',
                        style: TextStyle(
                            fontSize: 15, color: SecondaryContainerText),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text('Description',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: PrimaryColor)),
                  SizedBox(height: 5),
                  Text(
                    product['productDescription'] ?? 'No description available',
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 15),
                  if (sizes.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Sizes:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: PrimaryColor,
                          ),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: sizes.map<Widget>((sizeItem) {
                            final sizeName = sizeItem['size'] ?? '';
                            final sizeQty = sizeItem['quantity'] ?? 0;
                            final isSelected = selectedSize == sizeName;
                            final isDisabled = sizeQty == 0;

                            return ChoiceChip(
                              backgroundColor: ContainerColor,
                              showCheckmark: false,
                              label: Text('$sizeName'),
                              selected: isSelected,
                              onSelected: (maxQty == 0 || isDisabled)
                                  ? null
                                  : (selected) {
                                      setState(() {
                                        selectedSize =
                                            selected ? sizeName : null;
                                        quantity = 1;
                                      });
                                    },
                              selectedColor: PrimaryColor,
                              disabledColor: ContainerColor,
                              labelStyle: TextStyle(
                                color: isDisabled
                                    ? Colors.grey[600]
                                    : isSelected
                                        ? Colors.white
                                        : Colors.indigo[900],
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: quantity > 1
                            ? () {
                                setState(() => quantity--);
                              }
                            : null,
                      ),
                      Text(
                        '$quantity',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: quantity >= selectedSizeQty
                            ? null
                            : () {
                                setState(() => quantity++);
                              },
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final result = await showDialog(
                            context: context,
                            builder: (_) => MarketRatingDialog(
                              itemId: product['_id'],
                            ),
                          );
                          if (result == true) {
                            _loadRatingData();
                          }
                        },
                        child: Text(
                          'Rate this product',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: PrimaryColor,
                          ),
                        ),
                      ),
                      Text(
                        'In Stock: $maxQty',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: SecondaryContainerText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: maxQty == 0
                            ? Container(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.red[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'SOLD OUT',
                                  style: TextStyle(
                                    color: Colors.red[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: (selectedSize == null &&
                                        sizes.isNotEmpty)
                                    ? null
                                    : () async {
                                        Navigator.pop(context);
                                        Map<String, dynamic> productToAdd =
                                            Map.from(product);
                                        if (selectedSize != null) {
                                          productToAdd['size'] = selectedSize;
                                        }
                                        await widget.onAddToCart(
                                          context,
                                          productToAdd,
                                          quantity,
                                          selectedSize ?? "",
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.shopping_cart),
                                    SizedBox(width: 8),
                                    Text("Add to Cart")
                                  ],
                                ),
                              ),
                      ),
                      SizedBox(width: 15),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            setState(() {
                              isFavourite = !isFavourite;
                            });
                            Navigator.pop(context);
                            await widget.onAddToFavourites(context, product);
                          },
                          icon: Icon(
                            isFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
