// import 'package:flutter/material.dart';
// import 'package:issue_log/services/api_service.dart';
// import 'verify_code_screen.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String _email = '';
//   bool _loading = false;

//   void _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     _formKey.currentState!.save();

//     setState(() => _loading = true);
//     bool success = await ApiService.requestPasswordReset(_email);
//     setState(() => _loading = false);

//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Verification code sent to email")),
//       );
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => VerifyCodeScreen(email: _email)),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to send code")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Forgot Password")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const Text("Enter your registered email:"),
//             const SizedBox(height: 20),
//             Form(
//               key: _formKey,
//               child: TextFormField(
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: "Email",
//                 ),
//                 validator: (val) =>
//                     val != null && val.contains("@") ? null : "Invalid email",
//                 onSaved: (val) => _email = val!,
//               ),
//             ),
//             const SizedBox(height: 20),
//             _loading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: _submit, child: const Text("Send Code")),
//           ],
//         ),
//       ),
//     );
//   }
// }
