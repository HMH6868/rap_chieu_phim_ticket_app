import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/movie.dart';
import '../utils/movie_service.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> _allMovies = [];
  List<Movie> _filteredMovies = [];
  String _selectedGenre = 'Tất cả';
  String _searchQuery = '';
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  final List<String> _genres = [
    'Tất cả',
    'Kinh dị',
    'Hành động',
    'Hài',
    'Phiêu lưu',
    'Tình cảm',
    'Viễn tưởng',
    'Hình sự',
    'Chính kịch',
  ];

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    final movies = await MovieService.loadMovies();
    await Future.delayed(const Duration(seconds: 1)); // shimmer delay
    setState(() {
      _allMovies = movies;
      _filteredMovies = movies;
      _isLoading = false;
    });
  }

  void _filterByGenre(String genre) {
    setState(() {
      _selectedGenre = genre;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Movie> filtered = _allMovies;

    if (_selectedGenre != 'Tất cả') {
      filtered = filtered
          .where((movie) => movie.genres
              .any((g) => g.toLowerCase() == _selectedGenre.toLowerCase()))
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((movie) =>
              movie.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    _filteredMovies = filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim();
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _genres.map((genre) {
                final isSelected = _selectedGenre == genre;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(genre),
                    selected: isSelected,
                    selectedColor: Colors.red,
                    onSelected: (_) => _filterByGenre(genre),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Autocomplete<Movie>(
              optionsBuilder: (TextEditingValue value) {
                if (value.text.isEmpty) return const Iterable<Movie>.empty();
                return _allMovies.where((movie) => movie.title
                    .toLowerCase()
                    .contains(value.text.toLowerCase()));
              },
              displayStringForOption: (movie) => movie.title,
              onSelected: (movie) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MovieDetailScreen(movie: movie),
                  ),
                );
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                _searchController.addListener(() {
                  _onSearchChanged(_searchController.text);
                });
                return TextField(
                  controller: _searchController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm phim...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? _buildShimmerList()
                : _filteredMovies.isEmpty
                    ? const Center(child: Text('Không có phim phù hợp'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _filteredMovies.length,
                        itemBuilder: (context, index) {
                          final movie = _filteredMovies[index];
                          return MovieCard(
                            movie: movie,
                            showFavoriteIcon: false, // ✅ ẨN icon trái tim
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MovieDetailScreen(movie: movie),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
