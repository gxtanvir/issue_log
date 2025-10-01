import 'package:flutter/material.dart';
import 'package:issue_log/screens/admin/home.dart';
import 'package:issue_log/screens/auth/forgot_password_screen.dart';
import 'package:issue_log/screens/auth/signup.dart';
import 'package:issue_log/screens/home/issue_list.dart';
import 'package:issue_log/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userId = '';
  String _password = '';
  bool _isAuthenticating = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isAuthenticating = true);

    final success = await ApiService.login(_userId, _password);

    setState(() => _isAuthenticating = false);

    if (success) {
      final isAdmin = await ApiService.getIsAdminFromPrefs();
      final destination =
          isAdmin == true ? const AdminSummaryScreen() : IssueListScreen();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed: check ID/password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          final maxWidth = isWide ? 500.0 : double.infinity;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLogoAndTitle(),
                    const SizedBox(height: 30),
                    _buildForm(),
                    const SizedBox(height: 20),
                    _isAuthenticating
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text('Login'),
                        ),
                    const SizedBox(height: 30),
                    _buildForgotPassword(context),
                    const SizedBox(height: 10),
                    _buildSignup(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Column(
      children: [
        Image.asset('assets/images/main_logo.png', width: 150, height: 147),
        const SizedBox(height: 30),
        Text(
          'Login',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: const Color.fromARGB(255, 56, 75, 112),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User ID',
            style: TextStyle(
              color: Color.fromARGB(255, 56, 75, 112),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            autocorrect: false,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.smartphone_outlined),
              hintText: "Enter your ID",
            ),
            validator: (value) {
              if (value != null && value.trim().length >= 4) {
                return null;
              }
              return "Enter a valid ID";
            },
            onSaved: (val) => _userId = val!.trim().toUpperCase(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Password',
            style: TextStyle(
              color: Color.fromARGB(255, 56, 75, 112),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: "Enter your password",
            ),
            obscureText: true,
            validator: (val) {
              if (val != null && val.trim().length >= 6) {
                return null;
              }
              return "Password should be at least 6 characters";
            },
            onSaved: (val) => _password = val!.trim(),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Forgot Password?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
            );
          },
          child: const Text(
            'Reset',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSignup(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignupScreen()),
            );
          },
          child: const Text(
            'Register',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
