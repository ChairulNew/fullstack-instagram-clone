import 'package:flutter/widgets.dart';
import 'package:fullstack_instagram_clone/model/user.dart';
import 'package:fullstack_instagram_clone/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final AuthMethods _authMethods = AuthMethods();

  UserModel? get getUser => _user;

  Future<void> refreshUser() async {
    UserModel user = await _authMethods.getUsersDetails();
    _user = user;
    notifyListeners();
  }
}
