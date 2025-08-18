import 'package:Athlify/views/dashboard/DashboardAdmin/widget/resetStock.dart';
import 'package:Athlify/views/market%20Screens/widgets/market_product.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:Athlify/services/market/productService.dart';

class Marketdashboard extends StatefulWidget {
  const Marketdashboard({Key? key}) : super(key: key);

  @override
  State<Marketdashboard> createState() => _MarketdashboardState();
}

class _MarketdashboardState extends State<Marketdashboard> {
  final ProductService _productService = ProductService();
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final data = await _productService.getProducts();
      setState(() {
        _products = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct(String id, String name) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      title: 'Are you sure?',
      desc: 'Do you really want to delete "$name"?',
      btnCancelText: "Cancel",
      btnOkText: "Delete",
      btnOkOnPress: () async {
        await _productService.deleteProductById(id);
        _fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Product "$name" deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      },
      btnCancelOnPress: () {},
    ).show();
  }

  void _restockProduct(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) {
        return RestockDialog(
          product: product,
          onSubmit: (updatedSizes) async {
            final response = await _productService.restockProduct(
              product['_id'],
              updatedSizes,
            );

            Navigator.pop(context);

            if (response['statusCode'] == 200) {
              _fetchProducts();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Product restocked successfully.'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ ${response['message']}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      },
    );
  }

  void _editProduct(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController =
            TextEditingController(text: product['productName']);
        final priceController =
            TextEditingController(text: product['productPrice'].toString());
        final imageController =
            TextEditingController(text: product['productImage']);
        final descriptionController =
            TextEditingController(text: product['productDescription']);

        return AlertDialog(
          title: Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name')),
                TextField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number),
                TextField(
                    controller: imageController,
                    decoration: InputDecoration(labelText: 'Image URL')),
                TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _productService.updateProduct(
                  productId: product['_id'],
                  productName: nameController.text,
                  productPrice: int.tryParse(priceController.text) ?? 0,
                  productImage: imageController.text,
                  productDescription: descriptionController.text,
                  sizes: (product['sizes'] as List<dynamic>)
                      .map((e) => e as Map<String, dynamic>)
                      .toList(),
                  productType: product['productType'],
                );

                Navigator.pop(context);
                _fetchProducts();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '✅ Product "${nameController.text}" updated successfully.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Save'),
            ),
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: _products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.58,
                ),
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ProductCard(
                    product: product,
                    showAdminActions: true,
                    onEdit: () => _editProduct(product),
                    onDelete: () =>
                        _deleteProduct(product['_id'], product['productName']),
                    onRestock: () => _restockProduct(product), // ده المهم
                  );
                },
              ),
            ),
    );
  }
}
