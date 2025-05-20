import 'package:flutter/material.dart';
import '../database/auth_database.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  String? _message;

  Future<void> _resetPassword() async {
    final user =
        await AuthDatabase.getUserByEmail(_emailController.text.trim());
    if (user != null) {
      await AuthDatabase.updatePassword(
          _emailController.text.trim(), _newPasswordController.text.trim());
      setState(() => _message = 'Đặt lại mật khẩu thành công!');
    } else {
      setState(() => _message = 'Email không tồn tại!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu')),
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
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
              obscureText: true,
            ),
            if (_message != null)
              Text(_message!, style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      ),
    );
  }
}
