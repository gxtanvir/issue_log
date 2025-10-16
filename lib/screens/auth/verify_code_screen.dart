import 'package:flutter/material.dart';
import 'package:issue_log/services/api_service.dart';
import 'reset_password_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _code = '';
  bool _loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);
    bool success = await ApiService.verifyResetCode(widget.email, _code);
    setState(() => _loading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: widget.email, code: _code),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid code")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Code")),
      body: LayoutBuilder(
        builder: (context, constrains) {
          final isWidht = constrains.maxWidth >= 600;
          final maxWidth = isWidht ? 500.0 : double.infinity;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    Text(
                      """Code sent to ${widget.email}
Please check you Inbox/Spam Folder""",
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
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: "Verification Code",
                        ),
                        validator:
                            (val) =>
                                val != null && val.length == 6
                                    ? null
                                    : "Enter 6 digit code",
                        onSaved: (val) => _code = val!,
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
                          child: const Text("Verify"),
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
