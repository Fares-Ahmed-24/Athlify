// import 'package:shared_preferences/shared_preferences.dart';

// class GetUserData {
//   Future<String> getUserName() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('userName') ?? "User";
//   }

//   Future<String?> getEmailFromPrefs() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('email');
//   }

//   Future<String> getUserType() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('userType') ?? 'user';
//   }
//   // static SharedPreferences? _prefs;

//   // static Future<void> init() async {
//   //   _prefs ??= await SharedPreferences.getInstance();
//   // }

//   // static String? get email => _prefs?.getString('email');
//   // static String? get userType => _prefs?.getString('userType');
//   // static String? get userName => _prefs?.getString('userName');
//   // static String? get sessionId => _prefs?.getString('sessionId');
//   // static bool get isAuthenticated =>
//   //     _prefs?.getBool('isAuthenticated') ?? false;

//   // static Future<void> clear() async {
//   //   await _prefs?.clear();
//   // }
//   //b3d kda hn7ot dol fe el main
// //     void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await LocalStorageService.init();
// //   runApp(MyApp());
// // }
// // // we bnstd3y kda
// // final email = LocalStorageService.email;
// // final userType = LocalStorageService.userType;
// // final isAuthenticated = LocalStorageService.isAuthenticated;

// // w 7ad3th el logout w el isAuthenticateed
// // Future<bool> logout() async {
// //   try {
// //     String? sessionId = LocalStorageService.sessionId;

// //     if (sessionId == null) {
// //       print("No session found.");
// //       return false;
// //     }

// //     print("Logging out with Session ID: $sessionId");

// //     final response = await http.post(
// //       Uri.parse('$baseUrl/api/auth/logout'),
// //       headers: {
// //         'Content-Type': 'application/json',
// //       },
// //       body: jsonEncode({"sessionId": sessionId}),
// //     );

// //     if (response.statusCode == 200) {
// //       await LocalStorageService.clear();
// //       print("Session cleared.");
// //       return true;
// //     } else {
// //       print("Logout failed. Server response: ${response.body}");
// //       return false;
// //     }
// //   } catch (error) {
// //     print("Logout Error: $error");
// //     return false;
// //   }
// // }
// // bool get isAuthenticated => LocalStorageService.isAuthenticated;
// }
