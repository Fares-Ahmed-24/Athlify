import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/services/market/cart_service.dart';
import 'package:Athlify/views/market%20Screens/complete_order.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartProducts = [];
  bool isLoading = true;
  double totalPrice = 0.0;
  String? email;
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    fetchUserCart();
  }

  Future<void> fetchUserCart() async {
    try {
      final products = await _cartService.fetchCartProducts();
      print('Cart Products: $products');
      setState(() {
        cartProducts = products;
        totalPrice = cartProducts.fold(
          0.0,
          (sum, product) =>
              sum +
              ((product['productPrice'] ?? 0.0) * (product['quantity'] ?? 1)),
        );
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching cart: $e');
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      await _cartService.removeProductFromCart(productId);
      await fetchUserCart();
    } catch (e) {
      print('Error removing product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Your Cart',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Color(0xff243555),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cartProducts.isEmpty
              ? Center(child: Text("Your cart is empty"))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartProducts.length,
                        itemBuilder: (context, index) {
                          final product = cartProducts[index];
                          return Card(
                            color: ContainerColor,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: product['productImage'] != null &&
                                      product['productImage']
                                          .toString()
                                          .isNotEmpty
                                  ? Image.network(
                                      product['productImage'],
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.image_not_supported),
                              title: Text(
                                product['productName'] ?? 'No name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '\$${product['productPrice'].toString()}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Quantity: ${product['quantity']}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  if (product['size'] != null)
                                    Text(
                                      'Size: ${product['size']}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  removeFromCart(product['_id']);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: \$${totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String? userId = prefs.getString('userId');

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CompleteOrderPage(
                                    totalPrice: totalPrice,
                                    userId: userId!,
                                    cartProducts:
                                        cartProducts, // ابعت البيانات كاملة
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Complete the Order',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              textStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
