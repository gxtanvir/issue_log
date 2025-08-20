import 'package:flutter/material.dart';
import 'package:issue_log/screens/auth/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  var _userId = '';
  var _password = '';
  bool _isAuthenticating = false;

  // Submit Method
  void _submit() {
    bool isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    print(_userId);
    print(_password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.01),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/main_logo.png',
                          width: 150,
                          height: 147.26,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.04),
                        Text(
                          'Login',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall!.copyWith(
                            color: const Color.fromARGB(255, 56, 75, 112),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.04),
                      ],
                    ),
                  ),
                  Form(
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
                        SizedBox(height: constraints.maxHeight * 0.006),
                        TextFormField(
                          autocorrect: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.person),
                            hintText: "Enter Your ID",
                          ),
                          validator: (value) {
                            if (value != null &&
                                value.trim().isNotEmpty &&
                                value.trim().length >= 11 &&
                                value.trim().length <= 11) {
                              return null;
                            }
                            return "Enter a valid number";
                          },
                          onSaved: (newValue) => _userId = newValue!,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.016),
                        const Text(
                          'Password',
                          style: TextStyle(
                            color: Color.fromARGB(255, 56, 75, 112),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.006),
                        TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                            hintText: "Enter your password",
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value != null &&
                                value.trim().isNotEmpty &&
                                value.trim().length > 6) {
                              return null;
                            }
                            return "Passwordd should be 6 characteer long";
                          },
                          onSaved: (newValue) => _password = newValue!,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Forgot Passowrd?',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'reset',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Login'),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.08),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have account?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => SignupScreen()),
                          );
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
