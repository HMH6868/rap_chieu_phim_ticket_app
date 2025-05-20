import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'ticket_screen.dart';
import 'profile_screen.dart';
import '../utils/ticket_provider.dart';
import '../utils/auth_provider.dart';
import '../utils/favorite_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TicketScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadDataForCurrentUser();
  }

  Future<void> _loadDataForCurrentUser() async {
    final userEmail = context.read<AuthProvider>().user?.email ?? '';
    await context.read<TicketProvider>().loadTickets(userEmail);
    await context.read<FavoriteProvider>().loadFavorites(userEmail);

    if (!mounted) return;
    setState(() {});
  }

  void _onItemTapped(int index) {
    if (!mounted) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Vé của tôi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
    );
  }
}
