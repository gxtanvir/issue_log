import 'package:flutter/material.dart';

ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    elevation: 0,
    backgroundColor: const Color.fromARGB(255, 114, 125, 179),
    foregroundColor: Colors.white,
    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);
