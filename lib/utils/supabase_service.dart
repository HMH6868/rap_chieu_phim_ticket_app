import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
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
    
    // Ensure storage and database are properly configured
    await _checkAndSetupSupabase();
  }
  
  // Check and setup Supabase tables and storage
  static Future<void> _checkAndSetupSupabase() async {
    try {
      debugPrint('Checking Supabase configuration...');
      
      // Check if the avatars bucket exists
      final storageResponse = await _supabase.storage.getBucket('avatars');
      debugPrint('Avatars bucket exists: ${storageResponse != null}');

      // Attempt to create the profiles table if it doesn't exist
      // This is a simplified approach - in production, migrations should be handled more carefully
      try {
        debugPrint('Checking profiles table...');
        await _supabase.rpc('create_profiles_if_not_exists');
      } catch (e) {
        debugPrint('Error checking/creating profiles table: $e');
        // If RPC doesn't exist, we can try a direct query (though this requires additional permissions)
        try {
          await _supabase.from('profiles').select('id').limit(1);
          debugPrint('Profiles table exists');
        } catch (tableError) {
          debugPrint('Could not access profiles table: $tableError');
        }
      }
    } catch (e) {
      debugPrint('Error during Supabase configuration check: $e');
    }
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
  static Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      debugPrint('Attempting to sign in user: $email');
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // If login successful, try to get profile data
      if (authResponse.user != null) {
        debugPrint('Sign in successful for user: ${authResponse.user!.id}');
        
        // Try to get existing profile
        Map<String, dynamic>? profileData;
        try {
          profileData = await getUserProfile();
          debugPrint('Profile data retrieved: ${profileData != null}');
          
          // Nếu không có avatar trong profile, kiểm tra trực tiếp trong storage
          if (profileData != null && (profileData['avatar_url'] == null || profileData['avatar_url'].toString().isEmpty)) {
            debugPrint('No avatar URL in profile, checking storage directly');
            
            try {
              // Lấy danh sách tất cả file trong bucket avatars
              final avatarFiles = await _supabase.storage
                .from('avatars')
                .list();
              
              debugPrint('Total avatar files in bucket: ${avatarFiles.length}');
              
              // Tìm file avatar của user này (files thường có tên bắt đầu bằng user ID)
              final userId = authResponse.user!.id;
              final userFiles = avatarFiles.where((file) => file.name.startsWith(userId)).toList();
              
              if (userFiles.isNotEmpty) {
                debugPrint('Found ${userFiles.length} avatar files for this user');
                
                // Lấy file avatar mới nhất
                final latestFile = userFiles.first;
                final avatarUrl = _supabase.storage
                  .from('avatars')
                  .getPublicUrl(latestFile.name);
                
                debugPrint('Found avatar URL: $avatarUrl');
                
                // Cập nhật profile với avatar URL
                await _supabase.from('profiles').upsert({
                  'user_id': userId,
                  'email': email,
                  'avatar_url': avatarUrl,
                  'updated_at': DateTime.now().toIso8601String(),
                });
                
                // Lấy lại profile đã cập nhật
                profileData = await getUserProfile();
                debugPrint('Updated profile with avatar URL');
              } else {
                debugPrint('No avatar files found for this user');
              }
            } catch (storageError) {
              debugPrint('Error accessing storage: $storageError');
            }
          }
        } catch (profileError) {
          debugPrint('Error retrieving profile: $profileError');
        }
        
        return {
          'success': true,
          'user': authResponse.user,
          'profile': profileData,
        };
      }
      
      debugPrint('Sign in failed - user is null');
      return {
        'success': false,
        'error': 'Login failed',
      };
    } catch (e) {
      debugPrint('Error during sign in: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
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

  // Upload avatar image
  static Future<String?> uploadAvatar(File imageFile, String userEmail) async {
    try {
      debugPrint('Starting avatar upload process...');
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Error: User not logged in');
        return null;
      }

      // Generate a unique filename with user ID, timestamp and extension
      final fileExt = path.extension(imageFile.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${user.id}_$timestamp$fileExt';
      debugPrint('Uploading file: $fileName with size: ${await imageFile.length()} bytes');

      // Check if file exists and is readable
      if (!await imageFile.exists()) {
        debugPrint('Error: File does not exist');
        return null;
      }

      // Upload to avatars bucket with new file name each time
      debugPrint('Uploading to Supabase storage bucket: avatars');
      await _supabase.storage
          .from('avatars')
          .upload(
            fileName, 
            imageFile, 
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false, // Disable upsert to create new file each time
            )
          );

      // Get the public URL with cache-busting query parameter
      debugPrint('Getting public URL');
      final String publicUrl = '${_supabase.storage.from('avatars').getPublicUrl(fileName)}?t=$timestamp';
      debugPrint('Image uploaded successfully, URL: $publicUrl');
      
      // Update user metadata with avatar URL
      debugPrint('Updating profile with new avatar URL');
      try {
        // Kiểm tra xem profile đã tồn tại chưa
        final existingProfile = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
        
        if (existingProfile == null) {
          debugPrint('Creating new profile for user');
          // Tạo mới profile
          await _supabase.from('profiles').insert({
            'user_id': user.id,
            'email': userEmail,
            'avatar_url': publicUrl,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        } else {
          debugPrint('Updating existing profile');
          // Cập nhật profile
          await _supabase.from('profiles')
            .update({
              'avatar_url': publicUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', user.id);
        }
        
        debugPrint('Profile updated successfully');
        
        // Xóa các file avatar cũ để tiết kiệm dung lượng
        try {
          final allFiles = await _supabase.storage
            .from('avatars')
            .list();
            
          // Lọc các file avatar cũ của user này (trừ file vừa upload)
          final oldFiles = allFiles
            .where((file) => file.name.startsWith(user.id.toString()) && file.name != fileName)
            .map((file) => file.name)
            .toList();
            
          if (oldFiles.isNotEmpty) {
            debugPrint('Deleting ${oldFiles.length} old avatar files');
            await _supabase.storage
              .from('avatars')
              .remove(oldFiles);
          }
        } catch (e) {
          debugPrint('Error cleaning up old files: $e');
          // Không ảnh hưởng đến việc upload, chỉ log lỗi
        }
      } catch (e) {
        debugPrint('Error updating profile: $e');
        // Vẫn trả về URL dù có lỗi khi cập nhật profile
      }

      return publicUrl;
    } catch (e, stackTrace) {
      // Log detailed error information
      debugPrint('Error uploading avatar: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Check for specific error types
      if (e.toString().contains('permission') || e.toString().contains('access')) {
        debugPrint('Permission error: Check Supabase RLS policies');
      } else if (e.toString().contains('network')) {
        debugPrint('Network error: Check internet connection');
      } else if (e.toString().contains('storage')) {
        debugPrint('Storage error: Check if bucket exists and is public');
      }
      
      return null;
    }
  }

  // Get user profile data including avatar URL
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Cannot get profile: User not logged in');
        return null;
      }

      debugPrint('Fetching profile for user: ${user.id}');
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
      
      if (response == null) {
        debugPrint('Profile not found, creating new profile');
        // Create profile if it doesn't exist
        await _supabase.from('profiles').insert({
          'user_id': user.id,
          'email': user.email ?? '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        // Fetch newly created profile
        final newProfile = await _supabase
            .from('profiles')
            .select()
            .eq('user_id', user.id)
            .single();
            
        debugPrint('New profile created');
        return newProfile;
      }
      
      debugPrint('Profile found: ${response.toString()}');
      return response;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Get latest avatar URL directly
  static Future<String?> getLatestAvatarUrl() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Cannot get avatar: User not logged in');
        return null;
      }

      debugPrint('Getting latest avatar URL for user ${user.id}');
      
      // CÁCH 1: Truy vấn từ profiles table
      try {
        final profileResponse = await _supabase
            .from('profiles')
            .select('avatar_url')
            .eq('user_id', user.id)
            .single();
        
        if (profileResponse['avatar_url'] != null) {
          final avatarUrl = profileResponse['avatar_url'] as String;
          if (avatarUrl.isNotEmpty) {
            debugPrint('SUCCESS - Found avatar URL in profiles: $avatarUrl');
            
            // Thêm timestamp để tránh cache
            final timestampedUrl = avatarUrl.contains('?') 
                ? '$avatarUrl&t=${DateTime.now().millisecondsSinceEpoch}' 
                : '$avatarUrl?t=${DateTime.now().millisecondsSinceEpoch}';
                
            return timestampedUrl;
          }
        }
        debugPrint('Profiles table query returned no URL');
      } catch (e) {
        debugPrint('Error querying profiles table: $e');
      }
      
      // CÁCH 2: Truy vấn trực tiếp file trong storage
      try {
        debugPrint('Attempting to find avatar file in storage');
        final avatarFiles = await _supabase.storage
            .from('avatars')
            .list();
            
        final userFiles = avatarFiles
            .where((file) => file.name.startsWith(user.id.toString()))
            .toList();
            
        if (userFiles.isNotEmpty) {
          // Sắp xếp để lấy file mới nhất
          userFiles.sort((a, b) => 
            b.name.compareTo(a.name)); // Đơn giản hóa việc sắp xếp
            
          final latestFile = userFiles.first;
          final fileUrl = _supabase.storage
              .from('avatars')
              .getPublicUrl(latestFile.name);
              
          debugPrint('SUCCESS - Found file in storage: ${latestFile.name}');
          debugPrint('File URL: $fileUrl');
          
          // Cập nhật profiles table với URL mới tìm được
          await _supabase.from('profiles').upsert({
            'user_id': user.id,
            'email': user.email ?? '',
            'avatar_url': fileUrl,
            'updated_at': DateTime.now().toIso8601String(),
          });
          
          // Thêm timestamp để tránh cache
          final timestampedUrl = '$fileUrl?t=${DateTime.now().millisecondsSinceEpoch}';
          return timestampedUrl;
        }
        debugPrint('No avatar files found in storage');
      } catch (e) {
        debugPrint('Error searching in storage: $e');
      }
      
      // Không tìm thấy URL từ cả hai cách
      debugPrint('FAILED - No avatar URL found for user');
      return null;
    } catch (e) {
      debugPrint('Error getting avatar URL: $e');
      return null;
    }
  }

  // FAVORITES MANAGEMENT
  
  // Add movie to favorites
  static Future<bool> addFavorite({
    required String userEmail,
    required String movieId,
    required String title,
    required String posterUrl,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Cannot add favorite: User not logged in');
        return false;
      }
      
      await _supabase.from('favorites').insert({
        'user_id': user.id,
        'user_email': userEmail,
        'movie_id': movieId,
        'title': title,
        'poster_url': posterUrl,
        'created_at': DateTime.now().toIso8601String()
      });
      
      return true;
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      return false;
    }
  }
  
  // Remove movie from favorites
  static Future<bool> removeFavorite(String userEmail, String movieId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Cannot remove favorite: User not logged in');
        return false;
      }
      
      await _supabase.from('favorites')
        .delete()
        .match({
          'user_id': user.id,
          'movie_id': movieId
        });
        
      return true;
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      return false;
    }
  }
  
  // Check if movie is in favorites
  static Future<bool> isFavorite(String userEmail, String movieId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Cannot check favorite: User not logged in');
        return false;
      }
      
      final result = await _supabase.from('favorites')
        .select()
        .match({
          'user_id': user.id,
          'movie_id': movieId
        });
        
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking favorite: $e');
      return false;
    }
  }
  
  // Get all favorites for user
  static Future<List<dynamic>> getFavorites(String userEmail) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Cannot get favorites: User not logged in');
        return [];
      }
      
      final result = await _supabase.from('favorites')
        .select()
        .eq('user_id', user.id);
        
      return result;
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      return [];
    }
  }
  
  // TICKETS MANAGEMENT
  
  // Insert new ticket
  static Future<bool> insertTicket(Map<String, dynamic> ticketData) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Cannot insert ticket: User not logged in');
        return false;
      }
      
      // Add user_id to ticket data
      ticketData['user_id'] = user.id;
      ticketData['created_at'] = DateTime.now().toIso8601String();
      
      await _supabase.from('tickets').insert(ticketData);
      return true;
    } catch (e) {
      debugPrint('Error inserting ticket: $e');
      return false;
    }
  }
  
  // Get tickets by user
  static Future<List<dynamic>> getTicketsByUser(String userEmail) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Cannot get tickets: User not logged in');
        return [];
      }
      
      final result = await _supabase.from('tickets')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
        
      return result;
    } catch (e) {
      debugPrint('Error getting tickets: $e');
      return [];
    }
  }
  
  // Update ticket status
  static Future<bool> updateTicketStatus(int id, String status) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Cannot update ticket: User not logged in');
        return false;
      }
      
      await _supabase.from('tickets')
        .update({'status': status})
        .eq('id', id)
        .eq('user_id', user.id);
        
      return true;
    } catch (e) {
      debugPrint('Error updating ticket status: $e');
      return false;
    }
  }
  
  // Delete ticket
  static Future<bool> deleteTicket(int id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Cannot delete ticket: User not logged in');
        return false;
      }
      
      await _supabase.from('tickets')
        .delete()
        .eq('id', id)
        .eq('user_id', user.id);
        
      return true;
    } catch (e) {
      debugPrint('Error deleting ticket: $e');
      return false;
    }
  }

  // REVIEWS MANAGEMENT

  // Get all reviews for a movie
  static Future<List<dynamic>> getReviews(String movieId) async {
    try {
      final result = await _supabase
          .from('reviews')
          .select()
          .eq('movie_id', movieId)
          .order('created_at', ascending: false);
      return result;
    } catch (e) {
      debugPrint('Error getting reviews: $e');
      return [];
    }
  }

  // Add a new review
  static Future<bool> addReview({
    required String movieId,
    required double rating,
    required String comment,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Cannot add review: User not logged in');
        return false;
      }

      final profile = await getUserProfile();
      final avatarUrl = profile?['avatar_url'];

      await _supabase.from('reviews').insert({
        'movie_id': movieId,
        'user_id': user.id,
        'user_email': user.email!,
        'user_avatar_url': avatarUrl,
        'rating': rating,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error adding review: $e');
      return false;
    }
  }
}
