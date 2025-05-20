import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../database/favorite_database.dart';
import '../utils/auth_provider.dart';
import '../utils/favorite_provider.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Movie> _favoriteMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final userEmail = context.read<AuthProvider>().user?.email ?? '';
    final movies = await FavoriteDatabase.getFavorites(userEmail);
    setState(() {
      _favoriteMovies = movies;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoriteProvider>(context);
    final userEmail = Provider.of<AuthProvider>(context).user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phim yêu thích'),
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _favoriteMovies.isEmpty
              ? const Center(child: Text('Chưa có phim nào được yêu thích'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _favoriteMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _favoriteMovies[index];
                    final isFav = favProvider.isFavorite(movie.id, userEmail);

                    return MovieCard(
                      movie: movie,
                      isFavorite: isFav,
                      showFavoriteIcon: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MovieDetailScreen(movie: movie),
                          ),
                        );
                      },
                      onFavoriteToggle: () async {
                        await favProvider.toggleFavorite(
                          userEmail: userEmail,
                          movieId: movie.id,
                          title: movie.title,
                          posterUrl: movie.posterUrl,
                        );
                        _loadFavorites();
                      },
                    );
                  },
                ),
    );
  }
}
