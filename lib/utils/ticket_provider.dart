import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../models/movie.dart';
import '../database/ticket_database.dart';

class TicketProvider extends ChangeNotifier {
  List<Ticket> _tickets = [];

  List<Ticket> get tickets => _tickets;

  Future<void> loadTickets(String userEmail) async {
    _tickets = await TicketDatabase.getTicketsByUser(userEmail);
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
    final newTicket = Ticket(
      movieId: movie.id,
      movieTitle: movie.title,
      posterUrl: movie.posterUrl,
      seats: selectedSeats,
      totalAmount: totalAmount,
      dateTime: dateTime ?? DateTime.now(),
      userEmail: userEmail,
      theater: theater,
      status: 'active',
    );

    await TicketDatabase.insertTicket(newTicket);
    await loadTickets(userEmail);
  }

  Future<void> cancelTicket(int id, String userEmail) async {
    await TicketDatabase.updateStatus(id, 'cancelled');
    await loadTickets(userEmail);
  }

  Future<void> removeTicket(int id) async {
    await TicketDatabase.deleteTicket(id);
    _tickets.removeWhere((ticket) => ticket.id == id);
    notifyListeners();
  }

  Future<void> clearTickets(String userEmail) async {
    await TicketDatabase.clearAllTickets();
    _tickets.clear();
    notifyListeners();
  }
}
