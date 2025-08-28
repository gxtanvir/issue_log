import 'package:flutter/material.dart';
import 'package:issue_log/screens/home/issue_list.dart';
import 'package:issue_log/screens/auth/login.dart';
import 'package:issue_log/services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    String? token = await ApiService.getToken();

    if (token != null) {
      // Token exists, navigate to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) =>  IssueListScreen()),
      );
    } else {
      // No token, go to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}