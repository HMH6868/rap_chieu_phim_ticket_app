import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movie.dart';
import 'payment_screen.dart';
import '../utils/supabase_service.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Movie movie;

  const SeatSelectionScreen({super.key, required this.movie});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final List<String> _selectedSeats = [];
  final double _ticketPrice = 90000;

  final _supabase = Supabase.instance.client;
  RealtimeChannel? _ticketChannel;
  List<String> _bookedSeats = [];
  bool _isLoadingSeats = false;

  final List<List<int>> _seatLayout =
      List.generate(7, (_) => List.filled(8, 1));

  DateTime? _selectedDate;
  String? _selectedTime;

  final List<String> _allAvailableTimes = [
    '10:00',
    '12:30',
    '15:00',
    '17:30',
    '20:00',
    '22:30',
  ];

  List<String> _getFilteredAvailableTimes() {
    if (_selectedDate == null) {
      return [];
    }

    final now = DateTime.now();
    final isToday = _selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day;

    if (!isToday) {
      return _allAvailableTimes;
    }

    return _allAvailableTimes.where((time) {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final showtime = DateTime(now.year, now.month, now.day, hour, minute);
      return showtime.isAfter(now);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.movie.id.isNotEmpty) {
      _setupTicketChannel();
    }
  }

  @override
  void dispose() {
    _ticketChannel?.unsubscribe();
    super.dispose();
  }

  void _setupTicketChannel() {
    // Lắng nghe các thay đổi trên bảng showtime_seats
    _ticketChannel = _supabase.channel('public:showtime_seats');
    _ticketChannel!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'showtime_seats',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'movie_id',
        value: widget.movie.id,
      ),
      callback: (payload) {
        print('Realtime event received for showtime_seats: $payload');
        if (mounted && _selectedDate != null && _selectedTime != null) {
          final newSeat = payload.newRecord;
          final showtime = DateTime.parse(newSeat['showtime']);
          final selectedDateTime = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            int.parse(_selectedTime!.split(':')[0]),
            int.parse(_selectedTime!.split(':')[1]),
          );
          // Nếu sự kiện real-time dành cho đúng suất chiếu đang xem, hãy cập nhật lại danh sách ghế
          if (showtime.isAtSameMomentAs(selectedDateTime)) {
            _fetchBookedSeats();
          }
        }
      },
    ).subscribe();
  }

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

  Future<void> _fetchBookedSeats() async {
    if (_selectedDate == null || _selectedTime == null) return;

    setState(() {
      _isLoadingSeats = true;
    });

    try {
      final selectedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        int.parse(_selectedTime!.split(':')[0]),
        int.parse(_selectedTime!.split(':')[1]),
      );

      // Gọi hàm RPC mới để lấy danh sách ghế đã đặt
      final newBookedSeats = await SupabaseService.getBookedSeats(widget.movie.id, selectedDateTime);

      if (!mounted) return;

      setState(() {
        _bookedSeats = newBookedSeats;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách ghế: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSeats = false;
        });
      }
    }
  }

  // Format price with thousand separator dots
  String _formatPrice(double price) {
    String priceString = price.toStringAsFixed(0);
    final pattern = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return priceString.replaceAllMapped(pattern, (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[100];
    final screenColor = isDark ? Colors.grey[800] : Colors.grey[300];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn ghế', style: TextStyle(color: Colors.white)),
        elevation: 0,
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          // Movie info and date/time selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie title
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(widget.movie.posterUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.movie.title,
                            style: const TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.movie.genres.join(', '),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.movie.duration} phút',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                // Date selection
                Text(
                  'NGÀY CHIẾU',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final date = DateTime.now().add(Duration(days: index));
                      final isSelected = _selectedDate != null &&
                          _selectedDate!.day == date.day &&
                          _selectedDate!.month == date.month &&
                          _selectedDate!.year == date.year;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                            _selectedTime = null;
                            _bookedSeats = [];
                            _selectedSeats.clear();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? primaryColor 
                                : isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected 
                                ? Border.all(color: primaryColor) 
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'][date.weekday % 7],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${date.day}/${date.month}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isSelected ? Colors.white : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Time selection
                if (_selectedDate != null) ...[
                  Text(
                    'GIỜ CHIẾU',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _getFilteredAvailableTimes().map((time) {
                      final isSelected = _selectedTime == time;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTime = time;
                            _selectedSeats.clear();
                          });
                          _fetchBookedSeats();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? primaryColor 
                                : isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected 
                                ? Border.all(color: primaryColor)
                                : null,
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              color: backgroundColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Legend
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegend('Trống', isDark ? Colors.grey[700]! : Colors.white, isDark),
                          const SizedBox(width: 20),
                          _buildLegend('Đã chọn', primaryColor, isDark),
                          const SizedBox(width: 20),
                          _buildLegend('Đã đặt', Colors.grey, isDark),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Screen
                    Transform.scale(
                      scaleX: 1.1,
                      child: Container(
                        width: double.infinity,
                        height: 30,
                        margin: const EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                          color: screenColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(100),
                            topRight: Radius.circular(100),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: screenColor!.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'MÀN HÌNH',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Seats
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isLoadingSeats)
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: List.generate(_seatLayout.length, (row) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      child: Text(
                                        String.fromCharCode(65 + row),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white70 : Colors.black54,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    ...List.generate(_seatLayout[row].length, (col) {
                                      final isBooked = _isSeatBooked(row, col);
                                      final isSelected = _isSeatSelected(row, col);
                                      
                                      return GestureDetector(
                                        onTap: isBooked || _isLoadingSeats
                                            ? null
                                            : () => _toggleSeatSelection(row, col),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 36,
                                          height: 36,
                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                          decoration: BoxDecoration(
                                            color: isBooked
                                                ? Colors.grey
                                                : isSelected
                                                    ? primaryColor
                                                    : isDark ? Colors.grey[700] : Colors.white,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                              bottomLeft: Radius.circular(3),
                                              bottomRight: Radius.circular(3),
                                            ),
                                            border: Border.all(
                                              color: isSelected || isBooked
                                                  ? Colors.transparent
                                                  : Colors.grey,
                                              width: 1,
                                            ),
                                            boxShadow: isSelected || isBooked
                                                ? [
                                                    BoxShadow(
                                                      color: (isSelected ? primaryColor : Colors.grey)
                                                          .withOpacity(0.3),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${col + 1}',
                                              style: TextStyle(
                                                color: isBooked || isSelected
                                                    ? Colors.white
                                                    : isDark ? Colors.white70 : Colors.black87,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                    
                    // Increase bottom spacing to avoid overlap with the bottom sheet
                    const SizedBox(height: 140), // Increased from 80 to 140
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedSeats.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text(
                        'Ghế đã chọn:',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedSeats.join(', '),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng tiền',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${_formatPrice(_selectedSeats.length * _ticketPrice)} VND',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
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
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Tiếp tục'.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(String text, Color color, bool isDark) {
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
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
