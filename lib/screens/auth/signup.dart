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
  var _enteredEmail = '';
  var _enteredPassword = '';

  List<int> _selectedCompanyIds = [];
  List<int> _selectedModuleIds = [];
  bool _isAuthenticating = false;

  // Data from API
  List<Map<String, dynamic>> companies = [];
  List<Map<String, dynamic>> modules = [];
  bool _isLoadingDropdowns = true;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final companyList = await ApiService.fetchCompanies();
      final moduleList = await ApiService.fetchModules();
      setState(() {
        companies = companyList;
        modules = moduleList;
        _isLoadingDropdowns = false;
      });
    } catch (e) {
      setState(() => _isLoadingDropdowns = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load dropdown data: $e")),
      );
    }
  }

  // Submit Method
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedCompanyIds.isEmpty || _selectedModuleIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Company and Modules")),
      );
      return;
    }

    setState(() => _isAuthenticating = true);

    bool success = await ApiService.signup(
      _userName,
      _enteredId,
      // _enteredEmail,
      _enteredPassword,
      _selectedCompanyIds,
      _selectedModuleIds,
    );

    setState(() => _isAuthenticating = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful! Please login.")),
      );
      Navigator.of(context).pop();
      Navigator.push(
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
                  if (_isLoadingDropdowns)
                    const Center(child: CircularProgressIndicator())
                  else
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
                          const SizedBox(height: 5),
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
                          const SizedBox(height: 16),

                          // User ID
                          const Text(
                            "User ID",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color.fromARGB(255, 56, 75, 112),
                            ),
                          ),
                          const SizedBox(height: 5),
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
                            onSaved:
                                (newValue) =>
                                    _enteredId = newValue!.trim().toUpperCase(),
                          ),
                          const SizedBox(height: 16),

                          // // Email
                          // const Text(
                          //   "Email",
                          //   style: TextStyle(
                          //     fontWeight: FontWeight.bold,
                          //     fontSize: 18,
                          //     color: Color.fromARGB(255, 56, 75, 112),
                          //   ),
                          // ),
                          // const SizedBox(height: 5),
                          // TextFormField(
                          //   decoration: InputDecoration(
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(10),
                          //     ),
                          //     prefixIcon: const Icon(Icons.smartphone_outlined),
                          //     hintText: "Enter your Email",
                          //   ),
                          //   validator:
                          //       (value) =>
                          //           value != null && value.contains("@")
                          //               ? null
                          //               : "Enter a valid email address",
                          //   onSaved:
                          //       (newValue) => _enteredEmail = newValue!.trim(),
                          // ),
                          // const SizedBox(height: 16),

                          // Password
                          const Text(
                            "Password",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color.fromARGB(255, 56, 75, 112),
                            ),
                          ),
                          const SizedBox(height: 5),
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
                          const SizedBox(height: 16),

                          // Company Dropdown
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
                              closedSuffixIcon: const Icon(
                                Icons.arrow_drop_down,
                              ),
                            ),
                            items:
                                companies
                                    .map((c) => c['name'].toString())
                                    .toList(),
                            hintText: 'Select Company',
                            onListChanged: (selectedNames) {
                              _selectedCompanyIds =
                                  companies
                                      .where(
                                        (c) =>
                                            selectedNames.contains(c['name']),
                                      )
                                      .map<int>((c) => c['id'] as int)
                                      .toList();
                            },
                          ),
                          const SizedBox(height: 16),

                          // Module Dropdown
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
                              closedSuffixIcon: const Icon(
                                Icons.arrow_drop_down,
                              ),
                            ),
                            items:
                                modules
                                    .map((m) => m['name'].toString())
                                    .toList(),
                            hintText: 'Select Module',
                            onListChanged: (selectedNames) {
                              _selectedModuleIds =
                                  modules
                                      .where(
                                        (m) =>
                                            selectedNames.contains(m['name']),
                                      )
                                      .map<int>((m) => m['id'] as int)
                                      .toList();
                            },
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (_isAuthenticating)
                    const Center(child: CircularProgressIndicator())
                  else
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
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => const LoginScreen(),
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
