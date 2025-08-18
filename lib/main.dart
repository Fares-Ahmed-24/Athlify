import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/services/admin_notify.dart';
import 'package:Athlify/views/Home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Athlify/cubits/field_trainer_cubit/addField_cubit.dart';
import 'package:Athlify/cubits/field_trainer_cubit/getField_cubit.dart';
import 'package:Athlify/introduction.dart';
import 'package:Athlify/services/trainer.dart';
import 'package:Athlify/services/auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  Stripe.publishableKey = publishableKey;
  await Firebase.initializeApp();
  print('✅ Firebase connected!');

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isAuthenticated = null;

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      bool authStatus = await AuthService().isAuthenticated();
      // String? token = await FirebaseMessaging.instance.getToken();
      // print("FCM Token: $token");
      if (mounted) {
        setState(() {
          isAuthenticated = authStatus;
        });
      }
    } catch (e) {
      print("Error checking auth status: $e");
      if (mounted) {
        setState(() {
          isAuthenticated = false; // Default to login screen if error occurs
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<getFieldsCubit>(
          create: (context) => getFieldsCubit(TrainerService()),
        ),
        BlocProvider(
          create: (context) => AddTrainerCubit(TrainerService()),
        )
      ],
      child: MaterialApp(
        theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            dialogTheme: DialogThemeData(backgroundColor: Colors.white)),
        debugShowCheckedModeBanner: false,
        home: isAuthenticated == null
            ? Scaffold(
                body:
                    Center(child: CircularProgressIndicator()), // Show loading
              )
            : isAuthenticated!
                ? HomePage()
                : Intro(),
      ),
    );
  }
}
