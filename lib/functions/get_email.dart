 import 'package:Athlify/services/getUserType.dart';

Future<String> getUserId() async {
    final UserService _userData = UserService();
    return _userData.getEmail();
  }