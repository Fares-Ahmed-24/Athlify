// import 'package:Athlify/models/product_model.dart';
// import 'package:Athlify/views/bottom_nav_view/widget/product_card_hometab.dart';
// import 'package:flutter/material.dart';

// class HomeProductSection extends StatelessWidget {
//   final List<Product> latestProducts;

//   const HomeProductSection({required this.latestProducts});

//   @override
//   Widget build(BuildContext context) {
//     return latestProducts.isEmpty
//         ? Text("No products found", style: TextStyle(color: Colors.grey))
//         : Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 10),
//               SizedBox(
//                 height: 260,
//                 child: ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: latestProducts.length,
//                   separatorBuilder: (_, __) => SizedBox(width: 12),
//                   itemBuilder: (context, index) {
//                     final product = latestProducts[index];
//                     return ProductCardHomeTab(product: product);
//                   },
//                 ),
//               ),
//             ],
//           );
//   }
// }
