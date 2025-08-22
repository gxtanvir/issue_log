import 'package:flutter/material.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  var _userName = '';
  var _enteredId = '';
  var _enteredPassword = '';
  bool _isAuthenticating = false;

  // Submit Method

  void _submit() {
    var isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    print(_userName);
    print(_enteredId);
    print(_enteredPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(builder: (context, constraints) {
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
                        'Registration',
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
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
                        'Name',
                        style: TextStyle(
                            color: Color.fromARGB(255, 56, 75, 112),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.006),
                      TextFormField(
                        keyboardType: TextInputType.name,
                        autocorrect: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          hintText: "Enter your full name",
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.trim().isNotEmpty &&
                              value.trim().length >= 4) {
                            return null;
                          }
                          return "Username must be 4 caracter long";
                        },
                        onSaved: (newValue) => _userName = newValue!,
                      ),
                      SizedBox(height: constraints.maxHeight * 0.016),
                      const Text(
                        'User ID',
                        style: TextStyle(
                            color: Color.fromARGB(255, 56, 75, 112),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.006),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        autocorrect: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.smartphone_outlined),
                          hintText: "Enter your id",
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.trim().isNotEmpty &&
                              value.trim().length <= 6 &&
                              value.trim().length >= 6) {
                            return null;
                          }
                          return "Enter a valid phone number";
                        },
                        onSaved: (newValue) => _enteredId = newValue!,
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
                              value.trim().length >= 6) {
                            return null;
                          }
                          return "Password must be 6 character long";
                        },
                        onSaved: (newValue) => _enteredPassword = newValue!,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Sign Up'),
                ),
                SizedBox(height: constraints.maxHeight * 0.08),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have account?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
