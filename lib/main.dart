import 'package:flutter/material.dart';
import 'package:flast_app/screens/welcome_screen.dart';
import 'package:flast_app/screens/login_screen.dart';
import 'package:flast_app/screens/registration_screen.dart';
import 'package:flast_app/screens/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: ThemeData.dark().copyWith(
      //   textTheme: TextTheme(
      //     bodyText1: TextStyle(color: Colors.black54),
      //   ),
      // ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(), //must use '/'
        '/login': (context) => LoginScreen(),
        '/Registration': (context) => RegistrationScreen(),
        '/Chat': (context) => ChatScreen(),
      },
    );
  }
}
