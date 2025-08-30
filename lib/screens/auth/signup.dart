import 'package:flutter/material.dart';
import 'login.dart';
import 'package:issue_log/services/api_service.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

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
  List<String> _selectedCompanies = [];
  List<String> _selectedModules = [];
  bool _isAuthenticating = false;

  // Dropdown values
  final List<String> companies = [
    "GMS Composite",
    "GMS Textile",
    "GMS Trims",
    "GMS Testing Laboratory",
  ];

  final List<String> modules = [
    'MM',
    'TNA',
    'Plan',
    'Commercial',
    'SCM',
    'Inventory',
    'Prod',
    'S.Con',
    'Printing',
    'AOP',
    "Wash",
    "Embroidery",
    "Laboratory",
  ];

  // Submit Method
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedCompanies.isEmpty || _selectedModules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Company and Modules")),
      );
      return;
    }

    setState(() => _isAuthenticating = true);

    bool success = await ApiService.signup(
      _userName,
      _enteredId,
      _enteredPassword,
      _selectedCompanies,
      _selectedModules,
    );

    setState(() => _isAuthenticating = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful! Please login.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration failed! Try again.")),
      );
    }
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
                          'Registration',
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
                        // Name
                        const Text(
                          "Name",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color.fromARGB(255, 56, 75, 112),
                          ),
                        ),
                        SizedBox(height: 5),
                        TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                            ),
                            hintText: "Enter your full name",
                          ),
                          validator:
                              (value) =>
                                  value != null && value.trim().length >= 4
                                      ? null
                                      : "Name must be 4 characters long",
                          onSaved: (newValue) => _userName = newValue!,
                        ),
                        SizedBox(height: 16),

                        // User ID
                        const Text(
                          "User ID",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color.fromARGB(255, 56, 75, 112),
                          ),
                        ),
                        SizedBox(height: 5),
                        TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.smartphone_outlined),
                            hintText: "Enter your ID",
                          ),
                          validator:
                              (value) =>
                                  value != null &&
                                          value.trim().length >= 4 &&
                                          value.trim().length < 16
                                      ? null
                                      : "Id length must remain between 4-15",
                          onSaved: (newValue) => _enteredId = newValue!.trim().toUpperCase(),
                        ),
                        SizedBox(height: 16),

                        // Password
                        const Text(
                          "Password",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color.fromARGB(255, 56, 75, 112),
                          ),
                        ),
                        SizedBox(height: 5),
                        TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                            hintText: "Enter your password",
                          ),
                          validator:
                              (value) =>
                                  value != null && value.trim().length >= 6
                                      ? null
                                      : "Password must be at least 6 characters",
                          onSaved: (newValue) => _enteredPassword = newValue!,
                        ),
                        SizedBox(height: 16),

                        // Compnay Multi Select Custom Dropdown
                        const Text(
                          "Company",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color.fromARGB(255, 56, 75, 112),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomDropdown.multiSelect(
                          decoration: CustomDropdownDecoration(
                            closedBorder: Border.all(
                              color: Colors.grey.shade600,
                              width: 1,
                            ),
                            closedBorderRadius: BorderRadius.circular(10),
                            closedFillColor: Colors.white,
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(
                              Icons.business,
                              color: Colors.grey,
                            ),
                            closedSuffixIcon: const Icon(Icons.arrow_drop_down),
                          ),
                          items: companies,
                          hintText: 'Select Company',
                          onListChanged: (value) {
                            _selectedCompanies = value;
                          },
                        ),

                        SizedBox(height: 16),

                        //Module Dropdown MultiSlect
                        const Text(
                          "Modules",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color.fromARGB(255, 56, 75, 112),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomDropdown.multiSelect(
                          decoration: CustomDropdownDecoration(
                            closedBorder: Border.all(
                              color: Colors.grey.shade600,
                              width: 1,
                            ),
                            closedBorderRadius: BorderRadius.circular(10),
                            closedFillColor: Colors.white,
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(
                              Icons.apps,
                              color: Colors.grey,
                            ),
                            closedSuffixIcon: const Icon(Icons.arrow_drop_down),
                          ),
                          items: modules,
                          hintText: 'Select Module',
                          onListChanged: (value) {
                            _selectedModules = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  if (_isAuthenticating)
                    const Center(child: CircularProgressIndicator()),
                  if (!_isAuthenticating)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 56, 75, 112),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                      ),
                      onPressed: _submit,
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have account?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
