import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/views/market%20Screens/addProduct.dart';
import 'package:Athlify/views/market%20Screens/marketcart.dart';
import 'package:Athlify/views/market%20Screens/marketfavourite.dart';
import 'package:Athlify/views/market%20Screens/previousOrder.dart';

class MarketAppBar extends StatelessWidget {
  final bool isAdmin;
  final String? userId;
  final Function(String) onSearchChanged;
  final VoidCallback onRefreshProducts;

  const MarketAppBar({
    Key? key,
    required this.isAdmin,
    required this.userId,
    required this.onSearchChanged,
    required this.onRefreshProducts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      expandedHeight: 250,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAdmin)
              IconButton(
                icon: Icon(Icons.add, color: PrimaryColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddProductPage()),
                  ).then((_) => onRefreshProducts());
                },
              ),
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: Colors.green),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.favorite_outline, color: Colors.red),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavouritesPage()),
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
                      builder: (context) => PreviousOrdersPage(userId: userId!),
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
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.indigo),
              ),
            ),
            onChanged: onSearchChanged,
          ),
        ),
      ),
    );
  }
}
