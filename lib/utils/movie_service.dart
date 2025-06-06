import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  static const String _apiUrl = 'https://hmh6868.github.io/API_Phim/danh_sach_phim.json';

  static Future<List<Movie>> loadMovies() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        // API trả về chuỗi UTF-8, cần decode cho đúng
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Movie.fromJson(json)).toList();
      } else {
        // Nếu API lỗi, có thể trả về danh sách rỗng hoặc throw exception
        throw Exception('Failed to load movies from API');
      }
    } catch (e) {
      // Xử lý lỗi mạng hoặc các lỗi khác
      print('Error loading movies: $e');
      return []; // Trả về danh sách rỗng khi có lỗi
    }
  }
}
