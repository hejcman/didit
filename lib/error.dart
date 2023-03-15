import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

StatelessWidget showError(BuildContext context, String message) {
  if (Platform.isIOS) {
    return CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.error),
        content: Text(message),
        actions: [
          TextButton(
              // Go back to the home screen
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: Text(AppLocalizations.of(context)!.ok))
        ]);
  } else {
    return AlertDialog(
        title: Text(AppLocalizations.of(context)!.error),
        content: Text(message),
        actions: [
          TextButton(
              // Go back to the home screen
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: Text(AppLocalizations.of(context)!.ok))
        ]);
  }
}
