import 'package:Athlify/constant/Constants.dart';
import 'package:flutter/material.dart';

class RestockDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(List<Map<String, dynamic>>) onSubmit;

  const RestockDialog({
    Key? key,
    required this.product,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<RestockDialog> createState() => _RestockDialogState();
}

class _RestockDialogState extends State<RestockDialog> {
  late List<dynamic> sizes;
  late Map<String, int> restockQuantities;

  @override
  void initState() {
    super.initState();
    sizes = widget.product['sizes'] as List<dynamic>;

    final String productType = widget.product['productType'] ?? 'none';

    List<String> allSizes;
    if (productType == 'shoes') {
      allSizes = ['37', '38', '39', '40', '41', '42', '43', '44'];
    } else if (productType == 'clothes') {
      allSizes = ['S', 'M', 'L', 'XL'];
    } else {
      allSizes = ['none'];
    }

    // نعمل merge بين المقاسات اللي موجودة في المنتج والمقاسات الافتراضية
    final existingSizes = {for (var s in sizes) s['size']: s['quantity']};

    // نجهز restock quantities 0 لكل المقاسات
    restockQuantities = {for (var size in allSizes) size: 0};

    // نجهز sizes اللي هنعدلها مع الكميات الأصلية
    sizes = allSizes.map((size) {
      return {
        'size': size,
        'quantity': existingSizes[size] ?? 0,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Restock "${widget.product['productName']}"'),
      content: SingleChildScrollView(
        child: Column(
          children: restockQuantities.keys.map((size) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Size $size"),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (restockQuantities[size]! > 0) {
                            restockQuantities[size] =
                                restockQuantities[size]! - 1;
                          }
                        });
                      },
                    ),
                    Text('${restockQuantities[size]}'),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          restockQuantities[size] =
                              restockQuantities[size]! + 1;
                        });
                      },
                    ),
                  ],
                ),
              ],
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: SecondaryContainerText),
          ),
        ),
        TextButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: PrimaryColor,
          ),
          onPressed: () {
            List<Map<String, dynamic>> updatedSizes = sizes.map((s) {
              final oldQty = s['quantity'];
              final added = restockQuantities[s['size']] ?? 0;
              return {
                'size': s['size'],
                'quantity': (oldQty + added).toInt(),
              };
            }).toList();

            widget.onSubmit(updatedSizes);
            Navigator.pop(context);
          },
          child: const Text(
            'Submit',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
