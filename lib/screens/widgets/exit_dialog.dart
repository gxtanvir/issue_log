import 'package:flutter/material.dart';

class ExitConfirmation extends StatelessWidget {
  final Widget child;
  const ExitConfirmation({super.key, required this.child});

  Future<bool> _onWillPop(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Exit App"),
            content: const Text("Do you really want to close the app?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 9, 153, 45),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Yes"),
              ),
            ],
          ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () => _onWillPop(context), child: child);
  }
}
