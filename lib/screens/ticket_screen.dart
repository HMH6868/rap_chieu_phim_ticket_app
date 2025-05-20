import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/ticket_provider.dart';
import '../utils/auth_provider.dart';
import '../models/ticket.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  bool _isLoading = true;
  String _filterStatus = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final email = context.read<AuthProvider>().user?.email ?? '';
    await context.read<TicketProvider>().loadTickets(email);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final allTickets = ticketProvider.tickets;
    final tickets = _filterStatus == 'Tất cả'
        ? allTickets
        : allTickets.where((t) => getTicketStatus(t) == _filterStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vé của tôi'),
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Wrap(
                    spacing: 8,
                    children: ['Tất cả', 'Sắp chiếu', 'Đã xem', 'Đã huỷ']
                        .map((status) {
                      return ChoiceChip(
                        label: Text(status),
                        selected: _filterStatus == status,
                        selectedColor: Colors.red,
                        onSelected: (_) {
                          setState(() => _filterStatus = status);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: tickets.isEmpty
                        ? const Center(
                            child: Text(
                              'Không có vé phù hợp',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: tickets.length,
                            itemBuilder: (context, index) {
                              final ticket = tickets[index];
                              final status = getTicketStatus(ticket);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              ticket.posterUrl,
                                              width: 60,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ticket.movieTitle,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${ticket.dateTime.day}/${ticket.dateTime.month}/${ticket.dateTime.year} • ${ticket.dateTime.hour}:${ticket.dateTime.minute.toString().padLeft(2, '0')}',
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  status,
                                                  style: TextStyle(
                                                    color: status == 'Đã huỷ'
                                                        ? Colors.grey[300]
                                                        : status == 'Đã xem'
                                                            ? Colors.greenAccent
                                                            : Colors
                                                                .amberAccent,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (status == 'Sắp chiếu')
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.white),
                                              onPressed: () async {
                                                final confirm =
                                                    await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        'Xác nhận huỷ vé'),
                                                    content: const Text(
                                                        'Bạn có chắc muốn huỷ vé này không?'),
                                                    actions: [
                                                      TextButton(
                                                        child:
                                                            const Text('Không'),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context, false),
                                                      ),
                                                      TextButton(
                                                        child: const Text('Có'),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context, true),
                                                      ),
                                                    ],
                                                  ),
                                                );

                                                if (confirm == true) {
                                                  final email = context
                                                          .read<AuthProvider>()
                                                          .user
                                                          ?.email ??
                                                      '';
                                                  await context
                                                      .read<TicketProvider>()
                                                      .cancelTicket(
                                                          ticket.id!, email);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Đã huỷ vé thành công')),
                                                  );
                                                }
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildInfoRow(
                                              'Ghế:', ticket.seats.join(', ')),
                                          const Divider(),
                                          _buildInfoRow(
                                            'Tổng tiền:',
                                            '${ticket.totalAmount.toStringAsFixed(0)} VND',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  String getTicketStatus(Ticket ticket) {
    if (ticket.status == 'cancelled') return 'Đã huỷ';
    return DateTime.now().isAfter(ticket.dateTime) ? 'Đã xem' : 'Sắp chiếu';
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
