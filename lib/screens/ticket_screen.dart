import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/ticket_provider.dart';
import '../utils/auth_provider.dart';
import '../models/ticket.dart';
import 'main_screen.dart';
import 'ticket_detail_screen.dart';

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
    
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  const SizedBox(height: 16),
                  const Text(
                    'Đang tải vé của bạn...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // Custom App Bar with status bar padding
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: primaryColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vé của tôi',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        '${allTickets.length} vé đã đặt',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  centerTitle: false,
                  expandedHeight: 120,
                  // Add top padding to account for status bar
                  toolbarHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      // Adjust padding to account for status bar
                      padding: EdgeInsets.fromLTRB(
                        16, 
                        80 + MediaQuery.of(context).padding.top, 
                        16, 
                        0
                      ),
                      child: _buildFilterSection(primaryColor, isDark),
                    ),
                  ),
                ),

                // Ticket List
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: tickets.isEmpty
                      ? SliverFillRemaining(
                          child: _buildEmptyState(primaryColor),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final ticket = tickets[index];
                              return _buildTicketCard(
                                context,
                                ticket,
                                getTicketStatus(ticket),
                                primaryColor,
                                isDark,
                              );
                            },
                            childCount: tickets.length,
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterSection(Color primaryColor, bool isDark) {
    final statusList = ['Tất cả', 'Sắp chiếu', 'Đã xem', 'Đã huỷ'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statusList.length,
        itemBuilder: (context, index) {
          final status = statusList[index];
          final isSelected = _filterStatus == status;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: FilterChip(
                label: Text(status),
                selected: isSelected,
                checkmarkColor: Colors.white,
                selectedColor: primaryColor,
                backgroundColor: isDark 
                    ? Colors.grey[800] 
                    : Colors.grey.withOpacity(0.1),
                elevation: isSelected ? 3 : 0,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (_) {
                  setState(() => _filterStatus = status);
                },
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
    final message = _filterStatus == 'Tất cả'
        ? 'Bạn chưa đặt vé nào'
        : 'Không có vé $_filterStatus';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Khi bạn đặt vé, chúng sẽ hiển thị ở đây',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainScreen(initialIndex: 0),
                ),
              );
            },
            icon: Icon(Icons.movie_outlined, color: primaryColor),
            label: Text(
              'Khám phá phim',
              style: TextStyle(color: primaryColor),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              side: BorderSide(color: primaryColor),
                                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    Ticket ticket,
    String status,
    Color primaryColor,
    bool isDark,
  ) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'Đã huỷ':
        statusColor = Colors.grey;
        statusIcon = Icons.cancel_outlined;
        break;
      case 'Đã xem':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      default:
        statusColor = Colors.amber;
        statusIcon = Icons.access_time;
    }

    // Format date and time
    final day = ticket.dateTime.day.toString().padLeft(2, '0');
    final month = ticket.dateTime.month.toString().padLeft(2, '0');
    final year = ticket.dateTime.year;
    final hour = ticket.dateTime.hour.toString().padLeft(2, '0');
    final minute = ticket.dateTime.minute.toString().padLeft(2, '0');
    final formattedDate = '$day/$month/$year';
    final formattedTime = '$hour:$minute';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailScreen(ticket: ticket),
          ),
        ).then((cancelled) {
          // Refresh the list if ticket was cancelled in the detail screen
          if (cancelled == true) {
            _loadTickets();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
                                child: Column(
                                  children: [
            // Header with movie info
                                    Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                      child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                  // Movie poster
                                          ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              ticket.posterUrl,
                      width: 70,
                      height: 100,
                                              fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 70,
                          height: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                  
                  // Movie info
                                          Expanded(
                                            child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ticket.movieTitle,
                          style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                          formattedTime,
                          isDark,
                                                ),
                                                const SizedBox(height: 4),
                        _buildInfoItem(
                          Icons.event_seat_outlined,
                          'Ghế: ${ticket.seats.join(', ')}',
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
            
            // Footer with status and price
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                                            ),
                                        ],
                                      ),
                                    ),
                  
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                      Text(
                        'Tổng tiền',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                                            '${ticket.totalAmount.toStringAsFixed(0)} VND',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                                      ),
                                    ),
                                  ],
                  ),
                ],
              ),
            ),
            
            // Cancel button
            if (status == 'Sắp chiếu')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: OutlinedButton.icon(
                  onPressed: () => _confirmCancelTicket(context, ticket),
                  icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                  label: Text(
                    'Hủy vé',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red[700]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
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

  Future<void> _confirmCancelTicket(BuildContext context, Ticket ticket) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận huỷ vé'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn có chắc muốn huỷ vé này không?'),
            const SizedBox(height: 12),
            Text(
              'Phim: ${ticket.movieTitle}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Ngày chiếu: ${ticket.dateTime.day}/${ticket.dateTime.month}/${ticket.dateTime.year}'),
            Text('Giờ chiếu: ${ticket.dateTime.hour}:${ticket.dateTime.minute.toString().padLeft(2, '0')}'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('HUỶ BỎ'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('XÁC NHẬN'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final email = context.read<AuthProvider>().user?.email ?? '';
      await context.read<TicketProvider>().cancelTicket(ticket.id!, email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã huỷ vé thành công'),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  String getTicketStatus(Ticket ticket) {
    if (ticket.status == 'cancelled') return 'Đã huỷ';
    return DateTime.now().isAfter(ticket.dateTime) ? 'Đã xem' : 'Sắp chiếu';
  }
}
