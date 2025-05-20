import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/auth_provider.dart';
import '../database/auth_database.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  String? _message;

  Future<void> _changePassword() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = authProvider.user?.email ?? '';

    final user = await AuthDatabase.login(
      email,
      _currentPassController.text.trim(),
    );

    if (user != null) {
      await AuthDatabase.updatePassword(
        email,
        _newPassController.text.trim(),
      );
      setState(() => _message = 'Đổi mật khẩu thành công!');
    } else {
      setState(() => _message = 'Mật khẩu hiện tại không đúng!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đổi mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _currentPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu hiện tại',
              ),
            ),
            TextField(
              controller: _newPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Xác nhận'),
            ),
            const SizedBox(height: 20),
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(
                  color: _message!.contains('thành công')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
