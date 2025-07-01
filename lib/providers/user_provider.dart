import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:fullstack_instagram_clone/model/user.dart';
import 'package:fullstack_instagram_clone/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final AuthMethods _authMethods = AuthMethods();
  StreamSubscription<User?>? _authSubscription;

  UserProvider() {
    // Listen to auth state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      if (user != null) {
        // User is signed in, refresh user data
        refreshUser();
      } else {
        // User is signed out, clear user data
        _user = null;
        notifyListeners();
      }
    });
  }

  UserModel? get getUser => _user;

  Future<void> refreshUser() async {
    try {
      UserModel user = await _authMethods.getUsersDetails();
      _user = user;
      notifyListeners();
    } catch (e) {
      // Handle error - user might be signed out
      _user = null;
      notifyListeners();
    }
  }

  // Method to clear user (for logout)
  void clearUser() {
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
