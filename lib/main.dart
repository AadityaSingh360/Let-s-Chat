import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:letschat/screen/chat_screen.dart';
import 'package:letschat/screen/login_screen.dart';
import 'package:letschat/screen/registration_screen.dart';
import 'package:letschat/screen/welcome_screen.dart';
import 'package:letschat/src/pages/index.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(LetsChat());
}

class LetsChat extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'welcome_screen',

      routes: {
        WelcomeScreen.id: (context)=>WelcomeScreen(),
        LoginScreen.id: (context)=>LoginScreen(),
        RegistrationScreen.id: (context)=>RegistrationScreen(),
        ChatScreen.id: (context)=>ChatScreen(),
        IndexPage.id: (context)=>IndexPage()

      },
    );
  }
}
