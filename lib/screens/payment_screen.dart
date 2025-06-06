import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../utils/auth_provider.dart';
import '../utils/ticket_provider.dart';
import 'ticket_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Movie movie;
  final List<String> selectedSeats;
  final double totalAmount;
  final DateTime selectedDateTime;

  const PaymentScreen({
    super.key,
    required this.movie,
    required this.selectedSeats,
    required this.totalAmount,
    required this.selectedDateTime,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 0;
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Thẻ tín dụng / Ghi nợ', 'icon': Icons.credit_card},
    {'name': 'Momo', 'icon': Icons.account_balance_wallet},
    {'name': 'ZaloPay', 'icon': Icons.payment},
    {'name': 'VNPay', 'icon': Icons.monetization_on},
  ];

  // Format price with thousand separator dots
  String _formatPrice(double price) {
    String priceString = price.toStringAsFixed(0);
    final pattern = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return priceString.replaceAllMapped(pattern, (Match m) => '${m[1]}.');
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    if (!mounted) return;

    final userEmail = context.read<AuthProvider>().user?.email ?? '';
    final ticketProvider = context.read<TicketProvider>();

    final result = await ticketProvider.addTicket(
      movie: widget.movie,
      selectedSeats: widget.selectedSeats,
      totalAmount: widget.totalAmount,
      userEmail: userEmail,
      dateTime: widget.selectedDateTime,
    );

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (result['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => TicketSuccessScreen(
            movie: widget.movie,
            selectedSeats: widget.selectedSeats,
            totalAmount: widget.totalAmount,
          ),
        ),
        (route) => route.isFirst, // Xóa tất cả các route trước đó cho đến màn hình chính
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Đặt vé không thành công'),
          content: Text(result['message'] ?? 'Đã có lỗi xảy ra.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                Navigator.of(context).pop(); // Quay lại màn hình chọn ghế
              },
              child: const Text('Chọn lại ghế'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  const SizedBox(height: 24),
                  const Text(
                    'Đang xử lý thanh toán...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vui lòng không tắt ứng dụng',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTicketSummary(primaryColor, isDark),
                  const SizedBox(height: 24),
                  _buildPaymentMethods(primaryColor, isDark),
                  const SizedBox(height: 32),
                  SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _processPayment,
                        child: const Text(
                          'THANH TOÁN NGAY',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTicketSummary(Color primaryColor, bool isDark) {
    final date = widget.selectedDateTime;
    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final formattedDate = '${date.day}/${date.month}/${date.year}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Movie and date info
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.movie.posterUrl,
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                
                // Movie details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.movie.title,
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        Icons.calendar_today_outlined,
                        formattedDate,
                        isDark,
                      ),
                      const SizedBox(height: 4),
                      _buildInfoItem(
                        Icons.access_time_outlined,
                        time,
                        isDark,
                      ),
                      const SizedBox(height: 4),
                      _buildInfoItem(
                        Icons.location_on_outlined,
                        'HNP Cinema',
                        isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
                    
          // Dashed divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                40,
                (index) => Expanded(
                  child: Container(
                    height: 1,
                    color: index % 2 == 0
                        ? Colors.transparent
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          
          // Ticket details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  'Ghế',
                  widget.selectedSeats.join(', '),
                  isDark,
                ),
                _buildDetailRow(
                  'Số lượng',
                  '${widget.selectedSeats.length} vé',
                  isDark,
                ),
                _buildDetailRow(
                  'Giá vé',
                  '${_formatPrice(90000)} VND/vé',
                  isDark,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.grey[800]
                        : primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng',
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_formatPrice(widget.totalAmount)} VND',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(Color primaryColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phương thức thanh toán',
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _paymentMethods.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 70,
              endIndent: 20,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            itemBuilder: (context, index) {
              final isSelected = _selectedPaymentMethod == index;
              
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = index;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: RadioListTile(
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor.withOpacity(0.2)
                                : isDark 
                                    ? Colors.grey[800]
                                    : Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _paymentMethods[index]['icon'],
                            color: isSelected ? primaryColor : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _paymentMethods[index]['name'],
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    value: index,
                    groupValue: _selectedPaymentMethod,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value as int;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
