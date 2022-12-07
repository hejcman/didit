import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'color_schemes.g.dart';

StatelessWidget getAlertDialog(String title, List<Widget> actions) {
  if (Platform.isIOS) {
    return CupertinoAlertDialog(title: Text(title), actions: actions);
  } else {
    return AlertDialog(title: Text(title), actions: actions);
  }
}

IconData getCameraIcon() {
  if (Platform.isIOS) {
    return CupertinoIcons.camera_fill;
  } else {
    return Icons.camera_alt;
  }
}

IconData getArrowForwardIcon() {
  if (Platform.isIOS) {
    return CupertinoIcons.arrow_right;
  } else {
    return Icons.arrow_forward;
  }
}

IconData getBackArrowIcon() {
  if (Platform.isIOS) {
    return CupertinoIcons.back;
  } else {
    return Icons.arrow_back;
  }
}

IconData getShareIcon() {
  if (Platform.isIOS) {
    return CupertinoIcons.share;
  } else {
    return Icons.share;
  }
}

IconData getDeleteIcon() {
  if (Platform.isIOS) {
    return CupertinoIcons.delete;
  } else {
    return Icons.delete;
  }
}

IconData getFlagIcon() {
  if (Platform.isIOS) {
    return CupertinoIcons.flag_fill;
  } else {
    return Icons.flag;
  }
}

IconData getSettingsIcon() {
  if (Platform.isIOS) {
    return CupertinoIcons.settings;
  } else {
    return Icons.settings;
  }
}

IconData getCheckIcon() {
    return Platform.isIOS ? CupertinoIcons.check_mark : Icons.check;
}

IconData getPlusIcon() {
  return Platform.isIOS ? CupertinoIcons.add : Icons.add;
}

IconData getListIcon() {
  return Platform.isIOS ? CupertinoIcons.list_number : Icons.format_list_numbered;
}

IconData getMinusIcon() {
  return Platform.isIOS ? CupertinoIcons.minus_circle : Icons.remove_circle_outline;
}

IconData getSaveIcon() {
  return Platform.isIOS ? CupertinoIcons.floppy_disk : Icons.save;
}

IconData getReloadIcon() {
  return Platform.isIOS ? CupertinoIcons.arrow_2_circlepath : Icons.repeat;
}

Widget loadingIndicator(BuildContext context) {

  Color color = context.isDarkMode ? darkColorScheme.primary : lightColorScheme.primary;

  if (Platform.isIOS) {
    return CupertinoActivityIndicator(color: color);
  } else {
    return CircularProgressIndicator(color: color);
  }
}
