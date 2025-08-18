import 'dart:convert';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/views/market%20Screens/widgets/market_product.dart';
import 'package:Athlify/views/market%20Screens/widgets/product_details_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesPage extends StatefulWidget {
  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  List<Map<String, dynamic>> favouriteProducts = [];
  bool isLoading = true;
  Map<String, bool> isFavouriteMap = {};

  @override
  void initState() {
    super.initState();
    fetchUserFavourites();
  }

  Future<void> fetchUserFavourites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    final response = await http.get(
      Uri.parse('$baseUrl/api/users/favourites/$email'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<Map<String, dynamic>> fetchedFavourites =
          List<Map<String, dynamic>>.from(data['favourites']);

      Map<String, bool> fetchedFavouriteMap = {
        for (var product in fetchedFavourites) product['_id']: true,
      };

      setState(() {
        favouriteProducts = fetchedFavourites;
        isFavouriteMap = fetchedFavouriteMap;
        isLoading = false;
      });
    } else {
      print('Error fetching favourites: ${response.statusCode}');
      setState(() => isLoading = false);
    }
  }

  Future<void> addToCartFromFavourites(BuildContext parentContext,
      Map<String, dynamic> product, int quantity, String size) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    final response = await http.post(
      Uri.parse('$baseUrl/api/users/cart'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'productId': product['productId'] ?? product['_id'],
        'quantity': quantity,
        'size': size,
      }),
    );

    final responseBody = json.decode(response.body);
    ScaffoldMessenger.of(parentContext).showSnackBar(
      SnackBar(
        content: Text(responseBody['message']),
        backgroundColor: response.statusCode == 200 ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> removeFromFavourites(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    final response = await http.delete(
      Uri.parse('$baseUrl/api/users/favourites/remove/$email/$productId'),
    );

    if (response.statusCode == 200) {
      await fetchUserFavourites();
    } else {
      print('Error removing product from favourites: ${response.statusCode}');
    }
  }

  void showProductDetails(Map<String, dynamic> product) {
    final isFavourite = isFavouriteMap[product['_id']] ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ProductDetailsBottomSheet(
          product: product,
          isInitiallyFavourite: isFavourite,
          onAddToCart: addToCartFromFavourites,
          onAddToFavourites: (context, product) async {
            await removeFromFavourites(product['_id']);
            await fetchUserFavourites();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Favorite',
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
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.indigo,
                strokeWidth: 3,
              ),
            )
          : favouriteProducts.isEmpty
              ? Center(
                  child: Text(
                    'No favourite products yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    itemCount: favouriteProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final product = favouriteProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () => showProductDetails(product),
                        showAdminActions: false,
                      );
                    },
                  ),
                ),
    );
  }
}
