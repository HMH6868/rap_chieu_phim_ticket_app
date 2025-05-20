import 'package:flutter/material.dart';
import '../database/auth_database.dart';
import '../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _message;

  Future<void> _register() async {
    final newUser = User(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    final result = await AuthDatabase.register(newUser);
    setState(() {
      _message = result > 0
          ? 'Đăng ký thành công! Hãy đăng nhập.'
          : 'Email đã tồn tại!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            if (_message != null)
              Text(_message!, style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Đăng ký'),
            ),
          ],
        ),
      ),
    );
  }
}
