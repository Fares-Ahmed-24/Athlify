import 'package:Athlify/constant/Constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PreviousOrdersPage extends StatefulWidget {
  final String userId;

  const PreviousOrdersPage({required this.userId});

  @override
  State<PreviousOrdersPage> createState() => _PreviousOrdersPageState();
}

class _PreviousOrdersPageState extends State<PreviousOrdersPage> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final url = Uri.parse("$baseUrl/api/orders/${widget.userId}");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _orders = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Widget buildProductItem(dynamic product) {
    return ListTile(
      leading: Image.network(
        product['productImage'] ?? '',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.image_not_supported),
      ),
      title: Text(product['productName'] ?? 'Unnamed'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Price: EGP ${product['productPrice']}"),
          Text("Quantity: ${product['quantity']}"),
          if (product['size'] != null) Text("Size: ${product['size']}"),
        ],
      ),
    );
  }

  Widget buildOrderCard(dynamic order) {
    List<dynamic> products = order['products'] ?? [];

    return Card(
      color: ContainerColor,
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${order['name']}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Total Price: EGP ${order['totalPrice']}",
                style: TextStyle(fontSize: 16)),
            Text("Payment: ${order['paymentMethod']}",
                style: TextStyle(fontSize: 16)),
            Text("Date: ${order['date'].toString().substring(0, 10)}",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Products:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Divider(),
            ...products.map((product) => buildProductItem(product)).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Previous Orders",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff243555),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text("No previous orders found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) =>
                      buildOrderCard(_orders[index]),
                ),
    );
  }
}
