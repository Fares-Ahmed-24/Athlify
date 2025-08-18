// import 'package:flutter/material.dart';
// import 'package:Athlify/constant/Constants.dart';
// import 'package:Athlify/services/market/productService.dart';
// import 'package:Athlify/views/market%20Screens/widgets/product_details_bottom_sheet.dart';

// class MarketProductGridBox extends StatelessWidget {
//   final List<Map<String, dynamic>> products;

//   MarketProductGridBox({required this.products});

//   final productService = ProductService();

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       padding: const EdgeInsets.only(top: 8),
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       itemCount: products.length,
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         mainAxisSpacing: 16,
//         crossAxisSpacing: 16,
//         childAspectRatio: 0.72,
//       ),
//       itemBuilder: (context, index) {
//         final product = products[index];
//         final isSoldOut = (product['quantity'] ?? 0) == 0;

//         return GestureDetector(
//           onTap: isSoldOut
//               ? null
//               : () {
//                   showModalBottomSheet(
//                     context: context,
//                     isScrollControlled: true,
//                     backgroundColor: Colors.transparent,
//                     builder: (_) => ProductDetailsBottomSheet(
//                       product: product,
//                       onAddToCart: (context, product, quantity) =>
//                           productService.addToCart(context, product, quantity),
//                       onAddToFavourites: (context, product) =>
//                           productService.addToFavourites(context, product),
//                     ),
//                   );
//                 },
//           child: Stack(
//             children: [
//               Card(
//                 color: ContainerColor,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 elevation: 4,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ClipRRect(
//                       borderRadius:
//                           BorderRadius.vertical(top: Radius.circular(20)),
//                       child: Container(
//                         height: 120,
//                         width: double.infinity,
//                         color: Colors.grey[200],
//                         child: product["productImage"] != null &&
//                                 product["productImage"].isNotEmpty
//                             ? Image.network(
//                                 product["productImage"],
//                                 fit: BoxFit.cover,
//                               )
//                             : Icon(
//                                 Icons.image_not_supported,
//                                 color: Colors.grey[400],
//                                 size: 40,
//                               ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(6),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             product["productName"] ?? 'No name',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                               color: Colors.indigo[900],
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             '\$${product["productPrice"]?.toStringAsFixed(2) ?? '0.00'}',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green[700],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (isSoldOut)
//                 Positioned.fill(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey.withOpacity(0.5),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Center(
//                       child: Text(
//                         'SOLD OUT',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                           shadows: [
//                             Shadow(
//                               blurRadius: 4,
//                               color: Colors.black45,
//                               offset: Offset(1, 1),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
