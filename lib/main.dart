import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fullstack_instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:fullstack_instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:fullstack_instagram_clone/responsive/web_screen_layout.dart';
import 'package:fullstack_instagram_clone/screens/login_screen.dart';
import 'package:fullstack_instagram_clone/screens/signup_screen.dart';
import 'package:fullstack_instagram_clone/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDNKHCGIB6y9u_vpkTWqCOSWwB4bhCUtjs",
        appId: "1:478361084693:web:b3ed5ef082b581ed77ff1c",
        messagingSenderId: "478361084693",
        projectId: "instagram-clone-14d27",
        storageBucket: "instagram-clone-14d27.firebasestorage.app",
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
      // home: ResponsiveLayout(
      //   webScreenLayout: WebScreenLayout(),
      //   mobileScreenLayout: MobileScreenLayout(),
      // ),
      home: SignupScreen(),
    );
  }
}
