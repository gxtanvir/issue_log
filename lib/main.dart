import 'package:flutter/material.dart';
import 'package:issue_log/screens/home/issue_add.dart';
import 'package:issue_log/screens/home/splash_screen.dart';
import 'package:issue_log/theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Issue Log",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(context),
      home: SplashScreen(),
      routes: {'/add': (_) => IssueAddScreen()},
    );
  }
}
