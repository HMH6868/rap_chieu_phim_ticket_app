import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/auth_database.dart';
import '../utils/auth_provider.dart';
import '../utils/ticket_provider.dart';
import '../utils/favorite_provider.dart';
import 'main_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final user = await AuthDatabase.login(email, password);
    if (user != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final ticketProvider =
          Provider.of<TicketProvider>(context, listen: false);
      final favoriteProvider =
          Provider.of<FavoriteProvider>(context, listen: false);

      authProvider.login(user);
      await ticketProvider.loadTickets(email);
      await favoriteProvider.loadFavorites(email);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      setState(() => _error = 'Sai email hoặc mật khẩu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text('Chưa có tài khoản? Đăng ký'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen()),
                );
              },
              child: const Text('Quên mật khẩu?'),
            ),
          ],
        ),
      ),
    );
  }
}
