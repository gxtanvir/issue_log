import 'package:flutter/material.dart';
import 'package:issue_log/services/api_service.dart';
import 'login.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String code;
  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _password = '';
  bool _loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);
    bool success = await ApiService.resetPassword(
      widget.email,
      widget.code,
      _password,
    );
    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successful!")),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to reset password")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: LayoutBuilder(
        builder: (context, constrains) {
          final isWidth = constrains.maxHeight >= 600;
          final maxWidth = isWidth ? 500.0 : double.infinity;
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    const Text(
                      'Enter your new password',
                      style: TextStyle(
                        color: Color.fromARGB(255, 56, 75, 112),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: "New Password",
                        ),
                        validator:
                            (val) =>
                                val != null && val.length >= 6
                                    ? null
                                    : "At least 6 characters",
                        onSaved: (val) => _password = val!,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size.fromHeight(50),
                          ),
                          onPressed: _submit,
                          child: const Text("Reset Password"),
                        ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
