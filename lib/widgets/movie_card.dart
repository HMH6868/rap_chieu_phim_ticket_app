import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;
  final bool showFavoriteIcon; // ⚠️ mới thêm

  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite = false,
    this.showFavoriteIcon = true, // ⚠️ mặc định là hiện
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.97;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          height: 300,
          width: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      widget.movie.posterUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.grey,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              widget.movie.rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.movie.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.movie.genres.join(', '),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // ❤️ Hiển thị nút yêu thích nếu được yêu cầu
              if (widget.showFavoriteIcon)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: widget.onFavoriteToggle,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        widget.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
