
////////////////////////////////////////////////commented until we want to use
// import 'package:flutter/material.dart';

// class CategoryChip extends StatelessWidget {
//   String label;
//   bool isSelected;
//   VoidCallback onPressed;
//   CategoryChip(
//       {required this.label, required this.isSelected, required this.onPressed});
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4.0),
//       child: GestureDetector(
//         onTap:
//             onPressed, // عند الضغط على التصنيف، يتم الانتقال إلى الصفحة المناسبة
//         child: Chip(
//           label: Text(label, style: TextStyle(color: Colors.white)),
//           backgroundColor: isSelected
//               ? Color.fromRGBO(36, 53, 85, 100)
//               : const Color.fromRGBO(36, 53, 85, 1),
//         ),
//       ),
//     );
//   }
// }






    // el buttons bta3t el update w el delete bta3t el trainers card 
// if (userType == 'admin')
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   ElevatedButton(
//                     onPressed: widget.onTapUpdate,
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(150, 50),
//                       backgroundColor: PrimaryColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text("Update",
//                         style: TextStyle(color: Colors.white)),
//                   ),
//                   ElevatedButton(
//                     onPressed: widget.onTapDelete,
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(150, 50),
//                       backgroundColor: Colors.red,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text("Delete",
//                         style: TextStyle(color: Colors.white)),
//                   ),
//                 ],
//               ),

////////////////////bnst5dm leh deeeeeeeee
// void _loadUserType() async {
//     String email = await _userData.getEmail();
//     String type = await _userData.getUserType();

//     if (!mounted) return;
//     setState(() {
//       userType = type;
//       userId = email;
//     });

//     _checkIfFavorite();
//   }





    // el buttons bta3t el update w el delete bta3t el club card 

  //  SizedBox(height: 15),
  //             if (userType == 'admin')
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                 children: [
  //                   ElevatedButton(
  //                     onPressed: widget.onTapUpdate,
  //                     style: ElevatedButton.styleFrom(
  //                       minimumSize: Size(150, 50),
  //                       backgroundColor: PrimaryColor,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                     ),
  //                     child: const Text(
  //                       "Update",
  //                       style: TextStyle(color: Colors.white),
  //                     ),
  //                   ),
  //                   ElevatedButton(
  //                     onPressed: widget.onTapDelete,
  //                     style: ElevatedButton.styleFrom(
  //                       minimumSize: Size(150, 50),
  //                       backgroundColor: Colors.red,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                     ),
  //                     child: const Text(
  //                       "Delete",
  //                       style: TextStyle(color: Colors.white),
  //                     ),
  //                   ),
  //                 ],
  //               ),

  // void _loadUserType() async {
  //   String email = await _userData.getEmail();
  //   String type = await _userData.getUserType();

  //   if (!mounted) return;
  //   setState(() {
  //     userType = type;
  //     userId = email;
  //   });

  //   _checkIfFavorite();
  // }


