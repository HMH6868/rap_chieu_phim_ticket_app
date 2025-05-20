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

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final userEmail = context.read<AuthProvider>().user?.email ?? '';

    await context.read<TicketProvider>().addTicket(
          movie: widget.movie,
          selectedSeats: widget.selectedSeats,
          totalAmount: widget.totalAmount,
          userEmail: userEmail,
          dateTime: widget.selectedDateTime,
        );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TicketSuccessScreen(
          movie: widget.movie,
          selectedSeats: widget.selectedSeats,
          totalAmount: widget.totalAmount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Đang xử lý thanh toán...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTicketSummary(),
                  const SizedBox(height: 24),
                  _buildPaymentMethods(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _processPayment,
                      child: const Text(
                        'Thanh toán ngay',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTicketSummary() {
    final date = widget.selectedDateTime;
    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.movie.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${date.day}/${date.month}/${date.year} • $time • CGV Aeon Mall',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 24),
            _buildInfoRow('Ghế', widget.selectedSeats.join(', ')),
            _buildInfoRow('Số lượng', '${widget.selectedSeats.length} vé'),
            _buildInfoRow('Giá vé', '90,000 VND/vé'),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.totalAmount.toStringAsFixed(0)} VND',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phương thức thanh toán',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: List.generate(
              _paymentMethods.length,
              (index) => RadioListTile(
                title: Row(
                  children: [
                    Icon(_paymentMethods[index]['icon']),
                    const SizedBox(width: 16),
                    Text(_paymentMethods[index]['name']),
                  ],
                ),
                value: index,
                groupValue: _selectedPaymentMethod,
                activeColor: Colors.red,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value as int;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
