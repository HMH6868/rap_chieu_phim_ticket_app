import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/user.dart' as app_models;
import '../screens/update_password_screen.dart';

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
      final Session? session = data.session;
      
      debugPrint('Auth event: $event');
      
      if (event == AuthChangeEvent.signedIn) {
        debugPrint('Đăng nhập thành công qua deep link');
        // Có thể thêm xử lý đặc biệt khi đăng nhập qua deep link ở đây
      } else if (event == AuthChangeEvent.passwordRecovery) {
        debugPrint('Nhận deep link đặt lại mật khẩu');
        // Chuyển hướng đến màn hình đặt lại mật khẩu ngay lập tức
        Future.microtask(() {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/update-password',
            (route) => false,
          );
        });
      } else if (event == AuthChangeEvent.userUpdated) {
        debugPrint('Thông tin người dùng đã được cập nhật');
      }
    });
    
    // Kiểm tra trạng thái deep link hiện tại (trong trường hợp app đã được mở qua deep link)
    _checkCurrentSession(context);
  }
  
  // Kiểm tra session hiện tại để xử lý trong trường hợp app đã được mở bởi deep link
  static void _checkCurrentSession(BuildContext context) async {
    final session = _supabase.auth.currentSession;
    
    if (session != null) {
      if (session.user.emailConfirmedAt != null) {
        debugPrint('Email đã được xác nhận');
      }
      
      // Kiểm tra nếu người dùng đang trong quá trình đặt lại mật khẩu
      final authType = await _supabase.auth.onAuthStateChange.first;
      if (authType.event == AuthChangeEvent.passwordRecovery) {
        debugPrint('Đang trong quá trình đặt lại mật khẩu');
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/update-password',
          (route) => false,
        );
      }
    }
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
    try {
      // Add timeout to prevent hanging
      await _supabase.auth.signOut().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('Sign out timed out, forcing logout');
          return;
        },
      );
    } catch (e) {
      debugPrint('Error during sign out: $e');
      // Continue with local logout regardless of error
    }
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