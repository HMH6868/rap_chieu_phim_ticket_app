import 'package:flutter/material.dart';
import '../utils/supabase_service.dart';
import '../models/movie.dart';

class FavoriteProvider extends ChangeNotifier {
  final Map<String, Set<String>> _userFavorites = {};

  bool isFavorite(String movieId, [String userEmail = '']) {
    final favorites = _userFavorites[userEmail] ?? {};
    return favorites.contains(movieId);
  }

  Future<void> toggleFavorite({
    required String userEmail,
    required String movieId,
    required String title,
    required String posterUrl,
  }) async {
    final isFav = isFavorite(movieId, userEmail);

    if (isFav) {
      final result = await SupabaseService.removeFavorite(userEmail, movieId);
      if (result) {
        _userFavorites[userEmail]?.remove(movieId);
      }
    } else {
      final result = await SupabaseService.addFavorite(
        userEmail: userEmail,
        movieId: movieId,
        title: title,
        posterUrl: posterUrl,
      );
      if (result) {
        _userFavorites.putIfAbsent(userEmail, () => {}).add(movieId);
      }
    }

    notifyListeners();
  }

  Future<void> loadFavorites(String userEmail) async {
    final favorites = await SupabaseService.getFavorites(userEmail);
    
    // Chuyển đổi từ dynamic list sang Movie list
    final movies = favorites.map((item) => Movie(
      id: item['movie_id'] ?? '',
      title: item['title'] ?? '',
      posterUrl: item['poster_url'] ?? '',
      rating: 0,
      genres: const [],
      duration: 'Không rõ',
      trailerUrl: '',
      overview: '', // Thêm giá trị mặc định cho overview
    )).toList();
    
    _userFavorites[userEmail] = movies.map((movie) => movie.id).toSet();
    notifyListeners();
  }
}
