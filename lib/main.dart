import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fullstack_instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:fullstack_instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:fullstack_instagram_clone/responsive/web_screen_layout.dart';
import 'package:fullstack_instagram_clone/screens/login_screen.dart';
import 'package:fullstack_instagram_clone/screens/signup_screen.dart';
import 'package:fullstack_instagram_clone/utils/colors.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBxRHflMrMoXHWe4pEvMszX1rpdV2DXYsQ",
        appId: "1:718394058282:android:5b06cfcc9e0f15a9b08553",
        messagingSenderId: "718394058282",
        projectId: "instagram-app-2279d",
        storageBucket: "instagram-app-2279d.firebasestorage.app",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Instagram Clone',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: mobileBackgroundColor,
      ),
      home: SignupScreen(),
    );
  }
}
