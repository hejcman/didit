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

IconData getDownloadIcon() {
  if (Platform.isIOS) {
    return CupertinoIcons.arrow_down_to_line;
  } else {
    return Icons.download;
  }
}

IconData getFeedbackIcon() {
  if (Platform.isIOS) {
    return CupertinoIcons.text_bubble_fill;
  } else {
    return Icons.chat_bubble;
  }
}

IconData getFavouriteIcon() {
  if (Platform.isIOS) {
    return CupertinoIcons.heart_fill;
  } else {
    return Icons.favorite;
  }
}

IconData getListIcon() {
  if (Platform.isIOS) {
    return CupertinoIcons.square_list;
  } else {
    return Icons.list_alt;
  }
}

IconData getImageIcon() {
  if (Platform.isIOS) {
    return CupertinoIcons.camera_on_rectangle;
  } else {
    return Icons.image;
  }
}

IconData getVibrationIcon() {
  if (Platform.isIOS) {
    return CupertinoIcons.waveform;
  } else {
    return Icons.vibration;
  }
}

IconData getRepeatIcon() {
  if (Platform.isIOS) {
    return CupertinoIcons.repeat;
  } else {
    return Icons.repeat;
  }
}

Widget loadingIndicator(BuildContext context) {
  Color color =
      context.isDarkMode ? darkColorScheme.primary : lightColorScheme.primary;

  if (Platform.isIOS) {
    return CupertinoActivityIndicator(color: color);
  } else {
    return CircularProgressIndicator(color: color);
  }
}
