class Movie {
  final String id;
  final String title;
  final String posterUrl;
  final double rating;
  final List<String> genres;
  final String duration;
  final String trailerUrl;
  final String overview;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.rating,
    required this.genres,
    required this.duration,
    required this.trailerUrl,
    required this.overview,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      posterUrl: json['poster_url'] ?? '',
      rating: (json['vote_average'] ?? 0).toDouble(),
      genres: List<String>.from(json['genres'] ?? []),
      duration: json['duration'] ?? 'Không rõ',
      trailerUrl: json['trailer_url'] ?? '',
      overview: json['overview'] ?? 'Nội dung phim đang cập nhật...',
    );
  }
}
