import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/user.dart' as app_models;

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://qexwyenizrcmzpabzuzx.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFleHd5ZW5penJjbXpwYWJ6dXp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2ODczMjUsImV4cCI6MjA2NDI2MzMyNX0.41n0ZOW2vNUvil6JWOELTvD5y2GidxX-Om7FnzkIzZY',
      debug: true,
    );
  }
  
  // Khởi tạo DeepLink Listener
  static void setupDeepLinkListener(BuildContext context) {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        debugPrint('Đăng nhập thành công qua deep link');
        // Có thể thêm xử lý đặc biệt khi đăng nhập qua deep link ở đây
      }
    });
  }
  
  // Sign Up
  static Future<AuthResponse> signUp(String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'hmh://vexemphim/auth/callback',
    );
    return response;
  }
  
  // Sign In
  static Future<AuthResponse> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }
  
  // Sign Out
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  
  // Get current user
  static app_models.User? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return app_models.User(
        email: user.email ?? '',
        password: '', // We don't store or retrieve passwords
      );
    }
    return null;
  }
  
  // Reset Password
  static Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'hmh://vexemphim/auth/reset-password',
    );
  }
  
  // Update user password
  static Future<UserResponse> updatePassword(String newPassword) async {
    return await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
} 