import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/movie.dart';
import '../models/review.dart';
import 'seat_selection_screen.dart';
import 'trailer_player_screen.dart';
import '../utils/auth_provider.dart';
import '../utils/supabase_service.dart';
import '../services/gemini_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<List<Review>> _reviewsFuture;
  String? _movieSummary;
  bool _isSummaryLoading = true;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _fetchReviews();
    _fetchMovieSummary();
  }

  Future<void> _fetchMovieSummary() async {
    setState(() {
      _isSummaryLoading = true;
    });
    final summary = await GeminiService.getMovieSummary(widget.movie.title);
    if (mounted) {
      setState(() {
        _movieSummary = summary;
        _isSummaryLoading = false;
      });
    }
  }

  Future<List<Review>> _fetchReviews() async {
    final reviewsData = await SupabaseService.getReviews(widget.movie.id);
    return reviewsData.map((json) => Review.fromJson(json)).toList();
  }

  void _refreshReviews() {
    setState(() {
      _reviewsFuture = _fetchReviews();
    });
  }

  void _showReviewDialog() {
    final reviewController = TextEditingController();
    double userRating = 3.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Viết đánh giá'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: userRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  userRating = rating;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                decoration: const InputDecoration(
                  hintText: 'Nhập bình luận của bạn...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await SupabaseService.addReview(
                  movieId: widget.movie.id,
                  rating: userRating,
                  comment: reviewController.text,
                );
                if (success) {
                  Navigator.pop(context);
                  _refreshReviews();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã gửi đánh giá!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lỗi khi gửi đánh giá.')),
                  );
                }
              },
              child: const Text('Gửi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    widget.movie.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDark ? Colors.grey[800] : Colors.grey[300],
                      child: Center(
                        child: Icon(Icons.broken_image,
                            color: isDark ? Colors.grey[400] : Colors.grey, size: 80),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrailerPlayerScreen(
                              movieTitle: widget.movie.title,
                              trailerUrl: widget.movie.trailerUrl,
                            ),
                          ),
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow,
                            color: Colors.white, size: 32),
                      ),
                      iconSize: 48,
                    ),
                  ),
                ),
              ],
            ),
            leading: IconButton(
              icon: CircleAvatar(
                backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                child: Icon(Icons.arrow_back, 
                  color: isDark ? Colors.white : Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              StatefulBuilder(
                builder: (context, setStateFav) {
                  final userEmail =
                      context.read<AuthProvider>().user?.email ?? '';
                  return FutureBuilder<bool>(
                    future: SupabaseService.isFavorite(userEmail, widget.movie.id),
                    builder: (context, snapshot) {
                      final isFavorite = snapshot.data ?? false;
                      return IconButton(
                        icon: CircleAvatar(
                          backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                        ),
                        onPressed: () async {
                          if (isFavorite) {
                            await SupabaseService.removeFavorite(
                                userEmail, widget.movie.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Đã xoá khỏi yêu thích')),
                            );
                          } else {
                            await SupabaseService.addFavorite(
                              userEmail: userEmail,
                              movieId: widget.movie.id,
                              title: widget.movie.title,
                              posterUrl: widget.movie.posterUrl,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Đã thêm vào yêu thích')),
                            );
                          }
                          setStateFav(() {});
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.movie.title,
                      style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text('${widget.movie.rating}/10',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Text(widget.movie.duration,
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: widget.movie.genres.map((genre) {
                      return Chip(
                        label: Text(genre,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                        backgroundColor: Colors.red,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Nội dung',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _isSummaryLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Text(
                          _movieSummary ?? widget.movie.overview,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Đánh giá',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _showReviewDialog,
                        icon: const Icon(Icons.edit),
                        label: const Text('Viết đánh giá'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Review>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Lỗi: ${snapshot.error}'));
                      }
                      final reviews = snapshot.data ?? [];
                      if (reviews.isEmpty) {
                        return const Center(
                            child: Text('Chưa có đánh giá nào.'));
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return _buildReviewCard(
                            review.userEmail,
                            review.userAvatarUrl ?? 'https://i.pravatar.cc/150?u=${review.userId}',
                            review.comment ?? '',
                            review.rating,
                            isDark,
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('Lịch chiếu',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      '10:00',
                      '12:30',
                      '15:00',
                      '17:30',
                      '20:00',
                      '22:30'
                    ].map((time) => _buildTimeChip(time, isDark)).toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SeatSelectionScreen(movie: widget.movie)),
                        );
                      },
                      child: const Text('Đặt vé ngay',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
      String name, String imageUrl, String review, double rating, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.grey[850] : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(imageUrl), radius: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < rating.floor()
                            ? Icons.star
                            : (index < rating
                                ? Icons.star_half
                                : Icons.star_border),
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String time, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      child: Text(time, 
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87
        )
      ),
    );
  }
}
