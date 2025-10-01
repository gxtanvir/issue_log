import 'package:flutter/material.dart';

ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
    elevation: 0,
    backgroundColor: const Color.fromARGB(255, 56, 75, 112),
    foregroundColor: Colors.white,
    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
