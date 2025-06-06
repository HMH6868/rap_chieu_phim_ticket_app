import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user.dart';
import 'supabase_service.dart';

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

  Future<void> loadUserProfile() async {
    final supabaseUser = supabase.Supabase.instance.client.auth.currentUser;
    if (supabaseUser != null) {
      final profileData = await SupabaseService.getUserProfile();
      _user = User(
        email: supabaseUser.email ?? '',
        password: '', // Không lưu mật khẩu
        avatarUrl: profileData?['avatar_url'],
      );
      notifyListeners();
    }
  }
  
  // Update user avatar
  void updateAvatar(String? avatarUrl) {
    if (_user != null) {
      _user!.updateAvatarUrl(avatarUrl);
      notifyListeners();
    }
  }
}
