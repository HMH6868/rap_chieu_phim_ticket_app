import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'ticket_screen.dart';

class TicketSuccessScreen extends StatelessWidget {
  final Movie movie;
  final List<String> selectedSeats;
  final double totalAmount;

  const TicketSuccessScreen({
    super.key,
    required this.movie,
    required this.selectedSeats,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 100),
                const SizedBox(height: 24),
                const Text(
                  'Đặt vé thành công!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Bạn đã đặt ${selectedSeats.length} vé xem phim "${movie.title}" thành công.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const TicketScreen()),
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text(
                    'Xem vé của tôi',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
