import 'package:Athlify/services/upload_image.dart';
import 'package:Athlify/widget/button.dart';
import 'package:Athlify/widget/custome_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Athlify/services/market/productService.dart';

class AddProductPage extends StatefulWidget {
  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController productName = TextEditingController();
  TextEditingController productPrice = TextEditingController();
  TextEditingController productDescription = TextEditingController();

  bool isAdmin = false;
  bool isLoading = true;
  int generalQuantity = 1;
  XFile? _pickedImage;
  final UploadImageService _imageService = UploadImageService();
  final ProductService _productService = ProductService();

  String productSizeType = 'equipment';
  final List<String> clothesSizes = ['S', 'M', 'L', 'XL'];
  final List<String> shoeSizes = [
    '37',
    '38',
    '39',
    '40',
    '41',
    '42',
    '43',
    '44'
  ];
  Map<String, int> sizeQuantities = {}; // size => quantity

  @override
  void initState() {
    super.initState();
    checkUserType();
  }

  Future<void> checkUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userType = prefs.getString('userType');

    setState(() {
      isAdmin = userType == 'admin';
      isLoading = false;
    });
  }

  List<String> getSizeList() {
    if (productSizeType == 'clothes') return clothesSizes;
    if (productSizeType == 'shoes') return shoeSizes;
    return [];
  }

  void submitProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userId = prefs.getString('userId'); // ✅ استرجاع userId

        if (userId == null) {
          throw Exception("User not logged in");
        }

        String? imageUrl;
        if (_pickedImage != null) {
          imageUrl = await _imageService.uploadImageToCloudinary(_pickedImage!);
        }

        List<Map<String, dynamic>> sizes = [];
        if (productSizeType == 'equipment') {
          sizes.add({'size': 'equipment', 'quantity': generalQuantity});
        } else {
          for (var size in getSizeList()) {
            final qty = sizeQuantities[size] ?? 0;
            if (qty > 0) {
              sizes.add({'size': size, 'quantity': qty});
            }
          }
        }

        var response = await _productService.addProduct(
          productName.text.trim(),
          int.parse(productPrice.text),
          imageUrl ?? '',
          productDescription.text.trim(),
          sizes,
          productSizeType,
          userId, // ✅ هنا ضفنا الـ userId
        );

        setState(() => isLoading = false);

        if (response['statusCode'] == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Product added successfully"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Failed to add product"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text("Add Product")),
        body: Center(
          child: Text(
            "Access Denied: Admins Only",
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff243555),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Add Product',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                CustomeImagePicker(
                  icon: Icons.camera_alt,
                  context: context,
                  pickedImage: _pickedImage,
                  onImagePicked: (XFile? image) {
                    setState(() {
                      _pickedImage = image;
                    });
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(labelText: "Product Name"),
                  controller: productName,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(labelText: "Description"),
                  controller: productDescription,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration:
                      InputDecoration(labelText: "Price", counter: Offstage()),
                  maxLength: 5,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: productPrice,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text("Product Type (for sizes)",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  title: const Text('No Sizes (e.g. ball, racket)'),
                  leading: Radio<String>(
                    value: 'equipment', // 👈 هنا التغيير
                    groupValue: productSizeType,
                    onChanged: (value) {
                      setState(() {
                        productSizeType = value!;
                        sizeQuantities.clear();
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Clothing Sizes (S, M, L, XL)'),
                  leading: Radio<String>(
                    value: 'clothes',
                    groupValue: productSizeType,
                    onChanged: (value) {
                      setState(() {
                        productSizeType = value!;
                        sizeQuantities.clear();
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Shoe Sizes (37–44)'),
                  leading: Radio<String>(
                    value: 'shoes',
                    groupValue: productSizeType,
                    onChanged: (value) {
                      setState(() {
                        productSizeType = value!;
                        sizeQuantities.clear();
                      });
                    },
                  ),
                ),
                if (productSizeType == 'equipment')
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Quantity", style: TextStyle(fontSize: 16)),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                setState(() {
                                  if (generalQuantity > 1) generalQuantity--;
                                });
                              },
                            ),
                            Text(
                              generalQuantity.toString(),
                              style: TextStyle(fontSize: 18),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setState(() {
                                  generalQuantity++;
                                });
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                if (productSizeType != 'equipment')
                  ...getSizeList().map((size) {
                    sizeQuantities[size] = sizeQuantities[size] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Size $size", style: TextStyle(fontSize: 16)),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    if ((sizeQuantities[size] ?? 0) > 0)
                                      sizeQuantities[size] =
                                          sizeQuantities[size]! - 1;
                                  });
                                },
                              ),
                              Text(
                                (sizeQuantities[size] ?? 0).toString(),
                                style: TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    sizeQuantities[size] =
                                        sizeQuantities[size]! + 1;
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  }).toList(),
                SizedBox(height: 50),
                Custbutton(
                  text: 'Add Product',
                  onPressed: submitProduct,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
