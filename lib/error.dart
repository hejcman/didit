import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

StatelessWidget showError(BuildContext context, String message) {
  if (Platform.isIOS) {
    return CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
              // Go back to the home screen
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text("OK"))
        ]);
  } else {
    return AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
              // Go back to the home screen
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text("OK"))
        ]);
  }
}
