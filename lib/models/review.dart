class Review {
  final String id;
  final String movieId;
  final String userId;
  final String userEmail;
  final String? userAvatarUrl;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.userEmail,
    this.userAvatarUrl,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'].toString(),
      movieId: json['movie_id'],
      userId: json['user_id'],
      userEmail: json['user_email'],
      userAvatarUrl: json['user_avatar_url'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
