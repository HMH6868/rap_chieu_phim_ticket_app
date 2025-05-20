import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import 'seat_selection_screen.dart';
import 'trailer_player_screen.dart';
import '../utils/auth_provider.dart';
import '../database/favorite_database.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
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
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.grey, size: 80),
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
                              movieTitle: movie.title,
                              trailerUrl: movie.trailerUrl,
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
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              StatefulBuilder(
                builder: (context, setStateFav) {
                  final userEmail =
                      context.read<AuthProvider>().user?.email ?? '';
                  return FutureBuilder<bool>(
                    future: FavoriteDatabase.isFavorite(userEmail, movie.id),
                    builder: (context, snapshot) {
                      final isFavorite = snapshot.data ?? false;
                      return IconButton(
                        icon: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                        ),
                        onPressed: () async {
                          if (isFavorite) {
                            await FavoriteDatabase.removeFavorite(
                                userEmail, movie.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Đã xoá khỏi yêu thích')),
                            );
                          } else {
                            await FavoriteDatabase.addFavorite(
                              userEmail: userEmail,
                              movieId: movie.id,
                              title: movie.title,
                              posterUrl: movie.posterUrl,
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
                  Text(movie.title,
                      style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text('${movie.rating}/10',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Text(movie.duration,
                          style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: movie.genres.map((genre) {
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
                  const Text(
                    'Nội dung phim đang cập nhật...',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text('Đánh giá',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildReviewCard(
                      'Nguyễn Văn A',
                      'https://randomuser.me/api/portraits/men/32.jpg',
                      'Phim rất hay!',
                      4.5),
                  const SizedBox(height: 12),
                  _buildReviewCard(
                      'Trần Thị B',
                      'https://randomuser.me/api/portraits/women/44.jpg',
                      'Cốt truyện hấp dẫn!',
                      4.0),
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
                    ].map((time) => _buildTimeChip(time)).toList(),
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
                                  SeatSelectionScreen(movie: movie)),
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
      String name, String imageUrl, String review, double rating) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildTimeChip(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
