import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:didit/camera/widgets.dart';

import 'package:camerawesome/camerawesome_plugin.dart';

class AWSwitchButton extends StatelessWidget {
  final CameraState state;

  const AWSwitchButton({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    return AwesomeOrientedWidget(
        child: ActionButton(
      onPressed: state.switchCameraSensor,
      child: Icon(getCameraIcon()),
    ));
  }

  static IconData getCameraIcon() {
    if (Platform.isIOS) {
      return CupertinoIcons.switch_camera;
    } else {
      return Icons.switch_camera;
    }
  }
}
