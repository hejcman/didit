
import 'package:flutter/material.dart';

AlertDialog showError(BuildContext context, String message) {
  return AlertDialog(
    title: const Text('Error'),
    content: Text(message),
    actions: [
      TextButton(
        // Go back to the home screen
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        child: const Text("OK")
      )
    ]
  );
}
