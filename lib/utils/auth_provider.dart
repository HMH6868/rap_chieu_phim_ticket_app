import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  void login(User user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
