import 'package:Athlify/models/rating_model.dart';
import 'package:Athlify/services/market/productService.dart';
import 'package:Athlify/services/rating%20_service.dart';
import 'package:Athlify/views/market%20Screens/addProduct.dart';
import 'package:Athlify/views/market%20Screens/marketcart.dart';
import 'package:Athlify/views/market%20Screens/marketfavourite.dart';
import 'package:Athlify/views/market%20Screens/previousOrder.dart';
import 'package:Athlify/views/market%20Screens/widgets/market_product.dart';
import 'package:Athlify/views/market%20Screens/widgets/product_details_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class market_page extends StatefulWidget {
  @override
  State<market_page> createState() => _MarketPageState();
}

class _MarketPageState extends State<market_page> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  bool isAdmin = false;
  String _searchQuery = '';
  List<Map<String, dynamic>> filteredProducts = [];
  final ProductService _productService = ProductService();
  final productService = ProductService();
  Map<String, RatingResponse> _ratingsData = {};

  String? userId;
  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
    checkUserType();
    loadUserId();
  }

  Future<void> fetchProducts() async {
    // print("Fetching products...");
    try {
      final data = await ProductService().getProducts();
      // print(data);
      setState(() {
        products = data;
        filteredProducts =
            ProductService().getFilteredProducts(products, _searchQuery);
        isLoading = false;
      });

// 👇 ضيف السطر ده هنا بعد الـ setState
      _loadRatingDataForProducts(data);
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      filteredProducts =
          _productService.getFilteredProducts(products, _searchQuery);
    });
  }

  Future<void> checkUserType() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');
    if (userType == 'admin') {
      setState(() {
        isAdmin = true;
      });
    }
  }

  void _loadRatingDataForProducts(List<Map<String, dynamic>> products) async {
    for (var product in products) {
      final id = product['_id'];
      try {
        final data = await RatingService.fetchAverageRating(id);
        if (mounted) {
          setState(() {
            _ratingsData[id] = data;
          });
        }
      } catch (e) {
        print('Failed to load rating for $id: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.indigo,
                strokeWidth: 3,
              ),
            )
          : CustomScrollView(
              slivers: [
                // SliverAppBar عشان الصورة تبقى مرنة
                SliverAppBar(
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: Colors.white,
                  expandedHeight: 250,
                  floating: false,
                  pinned: true, // خليه مثبت عشان الأزرار تبقى ظاهرة لما تنزل
                  automaticallyImplyLeading: false,
                  actions: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAdmin)
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.indigo),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddProductPage()),
                              ).then((_) => fetchProducts());
                            },
                          ),
                        IconButton(
                          icon: Icon(Icons.shopping_cart_outlined,
                              color: Colors.green),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CartPage()),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.favorite_outline, color: Colors.red),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FavouritesPage()),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.receipt_long, color: Colors.teal),
                          onPressed: () {
                            if (userId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PreviousOrdersPage(userId: userId!),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please log in first')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.asset(
                      'assets/AthlifyMarket.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(60),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search for products...',
                            prefixIcon: Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Colors.indigo),
                            ),
                          ),
                          onChanged: onSearchChanged),
                    ),
                  ),
                ),

                // المنتجات
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = filteredProducts[index];
                        return ProductCard(
                          product: product,
                          rating: _ratingsData[product['_id']],
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => ProductDetailsBottomSheet(
                                product: product,
                                onAddToCart:
                                    (context, product, quantity, size) =>
                                        productService.addToCart(
                                            context, product, quantity, size),
                                onAddToFavourites: (context, product) =>
                                    productService.addToFavourites(
                                        context, product),
                                isInitiallyFavourite: false,
                              ),
                            );
                          },
                        );
                      },
                      childCount: filteredProducts.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
