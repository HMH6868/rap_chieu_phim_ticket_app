import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/movie.dart';

class MovieService {
  static Future<List<Movie>> loadMovies() async {
    final String response =
        await rootBundle.loadString('assets/danh_sach_phim.json');
    final List<dynamic> data = json.decode(response);

    return data
        .map((json) => Movie.fromJson(json))
        .toList();
  }
}
