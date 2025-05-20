import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import '../utils/auth_provider.dart';
import '../models/user.dart';
import 'login_screen.dart';
import 'favorite_screen.dart';
import 'change_password_screen.dart';
import 'ticket_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final User? user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        backgroundColor: Colors.red,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 16),
            _buildMenuSection(context),
            const SizedBox(height: 16),
            _buildAccountSection(context, themeProvider, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.red,
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              'https://randomuser.me/api/portraits/men/31.jpg',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.email.split('@')[0] ?? 'Tài khoản',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text(
                  'Thành viên',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.confirmation_number_outlined,
        'title': 'Vé của tôi',
        'subtitle': 'Xem vé đã đặt và lịch sử',
      },
      {
        'icon': Icons.favorite_border,
        'title': 'Phim yêu thích',
        'subtitle': 'Danh sách phim đã lưu',
      },
      {
        'icon': Icons.notifications_none,
        'title': 'Thông báo',
        'subtitle': 'Cập nhật phim mới & khuyến mãi',
      },
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: menuItems.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return ListTile(
            leading: Icon(item['icon'] as IconData, color: Colors.red),
            title: Text(item['title'] as String),
            subtitle: Text(item['subtitle'] as String),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              switch (item['title']) {
                case 'Vé của tôi':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TicketScreen()),
                  );
                  break;
                case 'Phim yêu thích':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoriteScreen()),
                  );
                  break;
                default:
                  break;
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildAccountSection(
    BuildContext context,
    ThemeProvider themeProvider,
    AuthProvider authProvider,
  ) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SwitchListTile(
            title: const Text('Chế độ tối'),
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.red,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (_) {
              themeProvider.toggleTheme();
            },
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.grey),
                title: const Text('Chỉnh sửa hồ sơ'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen()),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  authProvider.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
