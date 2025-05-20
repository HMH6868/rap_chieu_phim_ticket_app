import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'payment_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Movie movie;

  const SeatSelectionScreen({super.key, required this.movie});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final List<String> _selectedSeats = [];
  final double _ticketPrice = 90000;

  final List<List<int>> _seatLayout =
      List.generate(7, (_) => List.filled(8, 1));
  final List<String> _bookedSeats = ['A2', 'A3', 'C4', 'E5', 'F6', 'G7'];

  DateTime? _selectedDate;
  String? _selectedTime;

  final List<String> _availableTimes = [
    '10:00',
    '12:30',
    '15:00',
    '17:30',
    '20:00',
    '22:30',
  ];

  String _getSeatLabel(int row, int col) {
    final rowLabel = String.fromCharCode(65 + row);
    final colLabel = col + 1;
    return '$rowLabel$colLabel';
  }

  bool _isSeatBooked(int row, int col) =>
      _bookedSeats.contains(_getSeatLabel(row, col));

  bool _isSeatSelected(int row, int col) =>
      _selectedSeats.contains(_getSeatLabel(row, col));

  void _toggleSeatSelection(int row, int col) {
    final seatLabel = _getSeatLabel(row, col);
    setState(() {
      if (_selectedSeats.contains(seatLabel)) {
        _selectedSeats.remove(seatLabel);
      } else {
        _selectedSeats.add(seatLabel);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn ghế'),
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  widget.movie.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 14)),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _selectedDate == null
                              ? 'Chọn ngày'
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.access_time),
                          labelText: 'Giờ chiếu',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedTime,
                        items: _availableTimes.map((time) {
                          return DropdownMenuItem(
                            value: time,
                            child: Text(time),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedTime = value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegend('Trống', Colors.white),
                _buildLegend('Đã chọn', Colors.red),
                _buildLegend('Đã đặt', Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'MÀN HÌNH',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(_seatLayout.length, (row) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          String.fromCharCode(65 + row),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ...List.generate(_seatLayout[row].length, (col) {
                        final seatLabel = _getSeatLabel(row, col);
                        final isBooked = _isSeatBooked(row, col);
                        final isSelected = _isSeatSelected(row, col);

                        return GestureDetector(
                          onTap: isBooked
                              ? null
                              : () => _toggleSeatSelection(row, col),
                          child: Container(
                            width: 30,
                            height: 30,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isBooked
                                  ? Colors.grey
                                  : isSelected
                                      ? Colors.red
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Center(
                              child: Text(
                                '${col + 1}',
                                style: TextStyle(
                                  color: isBooked || isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedSeats.length} ghế: ${_selectedSeats.join(', ')}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tổng: ${(_selectedSeats.length * _ticketPrice).toStringAsFixed(0)} VND',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _selectedSeats.isEmpty ||
                            _selectedDate == null ||
                            _selectedTime == null
                        ? null
                        : () {
                            final selectedDateTime = DateTime(
                              _selectedDate!.year,
                              _selectedDate!.month,
                              _selectedDate!.day,
                              int.parse(_selectedTime!.split(':')[0]),
                              int.parse(_selectedTime!.split(':')[1]),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentScreen(
                                  movie: widget.movie,
                                  selectedSeats: _selectedSeats,
                                  totalAmount:
                                      _selectedSeats.length * _ticketPrice,
                                  selectedDateTime: selectedDateTime,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        const Text('Tiếp tục', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey),
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
