import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../models/movie.dart';
import '../utils/supabase_service.dart';

class TicketProvider extends ChangeNotifier {
  List<Ticket> _tickets = [];

  List<Ticket> get tickets => _tickets;

  Future<void> loadTickets(String userEmail) async {
    final ticketsData = await SupabaseService.getTicketsByUser(userEmail);
    
    // Chuyển đổi từ dynamic list sang Ticket list
    _tickets = ticketsData.map((item) => Ticket(
      id: item['id'],
      movieId: item['movie_id'] ?? '',
      movieTitle: item['movie_title'] ?? '',
      posterUrl: item['poster_url'] ?? '',
      seats: item['seats'] != null ? List<String>.from(item['seats']) : [],
      totalAmount: (item['total_amount'] ?? 0.0).toDouble(),
      dateTime: item['date_time'] != null ? DateTime.parse(item['date_time']) : DateTime.now(),
      userEmail: item['user_email'] ?? '',
      theater: item['theater'] ?? '',
      status: item['status'] ?? 'active',
    )).toList();
    
    notifyListeners();
  }

  Future<void> addTicket({
    required Movie movie,
    required List<String> selectedSeats,
    required double totalAmount,
    required String userEmail,
    String theater = 'CGV Aeon Mall',
    DateTime? dateTime,
  }) async {
    final ticketData = {
      'movie_id': movie.id,
      'movie_title': movie.title,
      'poster_url': movie.posterUrl,
      'seats': selectedSeats,
      'total_amount': totalAmount,
      'date_time': (dateTime ?? DateTime.now()).toIso8601String(),
      'user_email': userEmail,
      'theater': theater,
      'status': 'active',
    };

    final success = await SupabaseService.insertTicket(ticketData);
    if (success) {
      await loadTickets(userEmail);
    }
  }

  Future<void> cancelTicket(int id, String userEmail) async {
    final success = await SupabaseService.updateTicketStatus(id, 'cancelled');
    if (success) {
      await loadTickets(userEmail);
    }
  }

  Future<void> removeTicket(int id) async {
    final success = await SupabaseService.deleteTicket(id);
    if (success) {
      _tickets.removeWhere((ticket) => ticket.id == id);
      notifyListeners();
    }
  }

  // Không cần clearTickets vì không cần xóa toàn bộ vé từ hệ thống
}
