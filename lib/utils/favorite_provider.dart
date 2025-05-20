import 'package:flutter/material.dart';
import '../database/favorite_database.dart';

class FavoriteProvider extends ChangeNotifier {
  final Map<String, Set<String>> _userFavorites = {};

  bool isFavorite(String movieId, [String userEmail = '']) {
    loadFavorites(userEmail);
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
      await FavoriteDatabase.removeFavorite(userEmail, movieId);
      _userFavorites[userEmail]?.remove(movieId);
    } else {
      await FavoriteDatabase.addFavorite(
        userEmail: userEmail,
        movieId: movieId,
        title: title,
        posterUrl: posterUrl,
      );
      _userFavorites.putIfAbsent(userEmail, () => {}).add(movieId);
    }

    notifyListeners();
  }

  Future<void> loadFavorites(String userEmail) async {
    final favorites = await FavoriteDatabase.getFavorites(userEmail);
    _userFavorites[userEmail] = favorites.map((movie) => movie.id).toSet();
    notifyListeners();
  }
}
