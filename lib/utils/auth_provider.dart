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
    // Clear user data completely
    _user = null;
    
    // Notify listeners about the change
    notifyListeners();
  }
  
  // Update user avatar
  void updateAvatar(String? avatarUrl) {
    if (_user != null) {
      _user!.updateAvatarUrl(avatarUrl);
      notifyListeners();
    }
  }
}
