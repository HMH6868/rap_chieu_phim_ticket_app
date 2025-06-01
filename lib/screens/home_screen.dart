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
  bool _isHeaderVisible = true;
  final ScrollController _scrollController = ScrollController();

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
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _allMovies = movies;
        _filteredMovies = movies;
        _isLoading = false;
      });
    }
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchBarBackgroundColor = isDark ? Colors.grey[800] : Colors.grey.withOpacity(0.1);
    final searchBarShadowColor = isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final emptyIconColor = isDark ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.5);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang chủ", style: TextStyle(color: Colors.white)),
        backgroundColor: isDark ? Colors.grey[900] : Colors.red,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(height: MediaQuery.of(context).padding.top),
          
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isHeaderVisible ? null : 0,
            curve: Curves.easeInOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: searchBarBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: searchBarShadowColor,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
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
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm phim...',
                            hintStyle: TextStyle(color: subTextColor),
                            prefixIcon: Icon(
                              Icons.search,
                              color: primaryColor,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, color: subTextColor),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onChanged: _onSearchChanged,
                        );
                      },
                    ),
                  ),
                ),
                
                // Genre Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Thể loại phim',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Đã chọn: $_selectedGenre',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Genre Filter
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _genres.length,
                    itemBuilder: (context, index) {
                      final genre = _genres[index];
                      final isSelected = _selectedGenre == genre;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: ChoiceChip(
                            label: Text(genre),
                            selected: isSelected,
                            selectedColor: primaryColor,
                            backgroundColor: isDark ? Colors.grey[800] : Colors.grey.withOpacity(0.1),
                            elevation: isSelected ? 3 : 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (_) => _filterByGenre(genre),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : isDark ? Colors.white70 : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Movies Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Danh sách phim',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_filteredMovies.length} phim',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Movie Grid
          Expanded(
            child: _isLoading
                ? _buildShimmerList()
                : _filteredMovies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.movie_filter,
                              size: 64,
                              color: emptyIconColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không có phim phù hợp',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.grey[400] : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Thử tìm với từ khóa khác',
                              style: TextStyle(
                                fontSize: 14,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          if (notification is ScrollUpdateNotification) {
                            if (notification.scrollDelta! > 0 && _isHeaderVisible) {
                              setState(() {
                                _isHeaderVisible = false;
                              });
                            } else if (notification.scrollDelta! < 0 && !_isHeaderVisible) {
                              setState(() {
                                _isHeaderVisible = true;
                              });
                            }
                          }
                          return true;
                        },
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _filteredMovies.length,
                          itemBuilder: (context, index) {
                            final movie = _filteredMovies[index];
                            return MovieCard(
                              movie: movie,
                              showFavoriteIcon: false,
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
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[600]! : Colors.grey[100]!;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster area
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                // Title area
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 10,
                          width: 80,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
