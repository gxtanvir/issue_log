import 'package:flutter/material.dart';
import 'package:issue_log/services/api_service.dart';
import '../auth/verify_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  bool _loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);
    bool success = await ApiService.requestPasswordReset(_email);
    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification code sent to email")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VerifyCodeScreen(email: _email)),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to send code")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: LayoutBuilder(
        builder: (context, constrains) {
          final isWidth = constrains.maxWidth >= 600;
          final maxwidth = isWidth ? 500.0 : double.infinity;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxwidth),
                child: Column(
                  children: [
                    const Text(
                      'Enter your registered email',
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
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.email),
                          labelText: "Email",
                        ),
                        validator:
                            (val) =>
                                val != null && val.contains("@")
                                    ? null
                                    : "Invalid email",
                        onSaved: (val) => _email = val!,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                          onPressed: _submit,
                          child: const Text("Send Code"),
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
