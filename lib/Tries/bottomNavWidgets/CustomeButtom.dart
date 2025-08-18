// // bottom_navigation.dart
// import 'package:flutter/material.dart';
// import 'package:Athlify/constant/Constants.dart'; // Assuming you have constants here

// class CustomBottomNavigationBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;

//   const CustomBottomNavigationBar({
//     Key? key,
//     required this.currentIndex,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       currentIndex: currentIndex,
//       backgroundColor: PrimaryColor,
//       selectedItemColor: ContainerColor,
//       unselectedItemColor: SecondaryContainerText,
//       onTap: onTap,
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//         BottomNavigationBarItem(
//             icon: Icon(Icons.sports_soccer), label: "Clubs"),
//         BottomNavigationBarItem(
//             icon: Icon(Icons.fitness_center), label: "Trainers"),
//         BottomNavigationBarItem(icon: Icon(Icons.storefront), label: "Market"),
//         BottomNavigationBarItem(icon: Icon(Icons.menu), label: "More"),
//       ],
//     );
//   }
// }










// Widget buildClubCard(dynamic club) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           height: 180,
//           width: MediaQuery.of(context).size.width,
//           margin: const EdgeInsets.only(right: 5),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(25),
//             image: DecorationImage(
//               image: NetworkImage(club['image']),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         const SizedBox(height: 5),
//         Text(club['name'],
//             style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.indigo)),
//         Text(club['location'],
//             style: TextStyle(fontSize: 14, color: Colors.grey)),
//         Text(" ${club['clubType']} - EGP ${club['price']}",
//             style: TextStyle(fontSize: 14, color: Colors.black)),
//       ],
//     );
//   }

//   Widget buildTrainerCard(dynamic trainer) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           height: 180,
//           width: MediaQuery.of(context).size.width,
//           margin: const EdgeInsets.only(right: 5),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(25),
//             image: DecorationImage(
//               image: NetworkImage(trainer['image']),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         const SizedBox(height: 5),
//         Text(trainer['name'],
//             style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.deepPurple)),
//         Text(trainer['location'],
//             style: TextStyle(fontSize: 14, color: Colors.grey)),
//         Text(" ${trainer['category']} - EGP ${trainer['price']}",
//             style: TextStyle(fontSize: 14, color: Colors.black)),
//       ],
//     );
//   }