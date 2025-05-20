import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../utils/movie_service.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _allMovies = [];
  List<Movie> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadMovies() async {
    final movies = await MovieService.loadMovies();
    setState(() {
      _allMovies = movies;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchResults = _allMovies.where((movie) {
        return movie.title.toLowerCase().contains(query) ||
            movie.genres.any((genre) => genre.toLowerCase().contains(query));
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm phim...',
            border: InputBorder.none,
          ),
          autofocus: true,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.black),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _searchController.text.isEmpty
              ? _buildMovies(_allMovies)
              : _buildMovies(_searchResults),
    );
  }

  Widget _buildMovies(List<Movie> movies) {
    if (movies.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy kết quả',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MovieCard(
          movie: movie,
          showFavoriteIcon: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovieDetailScreen(movie: movie),
              ),
            );
          },
        );
      },
    );
  }
}
