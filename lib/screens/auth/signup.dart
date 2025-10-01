import 'package:flutter/material.dart';
import 'package:issue_log/screens/auth/login.dart';
import 'package:issue_log/services/api_service.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  String _userName = '';
  String _enteredId = '';
  String _enteredEmail = '';
  String _enteredPassword = '';
  List<int> _selectedCompanyIds = [];
  List<int> _selectedModuleIds = [];

  bool _isAuthenticating = false;
  bool _isLoadingDropdowns = true;

  List<Map<String, dynamic>> companies = [];
  List<Map<String, dynamic>> modules = [];

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

    final success = await ApiService.signup(
      _userName,
      _enteredId,
      _enteredEmail,
      _enteredPassword,
      _selectedCompanyIds,
      _selectedModuleIds,
    );

    setState(() => _isAuthenticating = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful! Please login.")),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration failed! Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 600;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 600 : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _isLoadingDropdowns
                    ? const CircularProgressIndicator()
                    : _buildForm(),
                const SizedBox(height: 20),
                _isAuthenticating
                    ? const CircularProgressIndicator()
                    : _buildSubmitButton(size.width),
                const SizedBox(height: 30),
                _buildFooterNavigation(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/main_logo.png',
          width: 150,
          height: 147,
        ),
        const SizedBox(height: 24),
        Text(
          'Registration',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: const Color(0xFF384B70),
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
        children: [
          _buildInputField(
            label: "Name",
            hint: "Enter your full name",
            icon: Icons.person_outline,
            validator: (value) =>
                value != null && value.trim().length >= 4
                    ? null
                    : "Name must be at least 4 characters",
            onSaved: (val) => _userName = val!.trim(),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: "User ID",
            hint: "Enter your ID",
            icon: Icons.badge_outlined,
            validator: (value) =>
                value != null && value.trim().length >= 4 && value.length < 16
                    ? null
                    : "ID must be between 4-15 characters",
            onSaved: (val) => _enteredId = val!.trim().toUpperCase(),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: "Email",
            hint: "Enter your email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                value != null && value.contains("@")
                    ? null
                    : "Enter a valid email address",
            onSaved: (val) => _enteredEmail = val!.trim(),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: "Password",
            hint: "Enter your password",
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (value) =>
                value != null && value.length >= 6
                    ? null
                    : "Password must be at least 6 characters",
            onSaved: (val) => _enteredPassword = val!,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: "Company",
            items: companies.map((c) => c['name'].toString()).toList(),
            icon: Icons.business,
            onChanged: (selected) {
              _selectedCompanyIds = companies
                  .where((c) => selected.contains(c['name']))
                  .map<int>((c) => c['id'] as int)
                  .toList();
            },
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: "Modules",
            items: modules.map((m) => m['name'].toString()).toList(),
            icon: Icons.apps,
            onChanged: (selected) {
              _selectedModuleIds = modules
                  .where((m) => selected.contains(m['name']))
                  .map<int>((m) => m['id'] as int)
                  .toList();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF384B70),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: Icon(icon),
            hintText: hint,
          ),
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onSaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required IconData icon,
    required Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF384B70),
          ),
        ),
        const SizedBox(height: 8),
        CustomDropdown.multiSelect(
          decoration: CustomDropdownDecoration(
            closedBorder: Border.all(color: Colors.grey.shade600, width: 1),
            closedBorderRadius: BorderRadius.circular(10),
            closedFillColor: Colors.white,
            prefixIcon: Icon(icon, color: Colors.grey),
            hintStyle: const TextStyle(color: Colors.grey),
            closedSuffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          items: items,
          hintText: 'Select $label',
          onListChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(double width) {
    return SizedBox(
      width: width >= 600 ? 500 : double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: const Text("Sign Up"),
      ),
    );
  }

  Widget _buildFooterNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account?",
          style: TextStyle(fontSize: 16),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: const Text(
            "Login",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
