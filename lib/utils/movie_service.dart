import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/movie.dart';

class MovieService {
  static Future<List<Movie>> loadMovies() async {
    final String response =
        await rootBundle.loadString('assets/danh_sach_phim.json');
    final List<dynamic> data = json.decode(response);

    return data
        .map((json) => Movie(
              id: json['id'] ?? '',
              title: json['title'] ?? '',
              posterUrl: json['poster_url'] ?? '',
              rating: (json['vote_average'] ?? 0).toDouble(),
              genres: List<String>.from(json['genres'] ?? []),
              duration: json['duration'] ?? 'Không rõ',
              trailerUrl: json['trailer_url'] ?? '',
            ))
        .toList();
  }
}
