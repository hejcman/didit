
import 'dart:io' show Platform;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../storage/schema.dart';

/// Select the platform appropriate camera icon based on the direction
IconData getCameraIcon(CameraLensDirection direction) {
  switch(direction) {
    case CameraLensDirection.back:
      if (Platform.isIOS) {
        return CupertinoIcons.switch_camera;
      } else {
        return Icons.switch_camera_outlined;
      }
    case CameraLensDirection.front:
      if (Platform.isIOS) {
        return CupertinoIcons.switch_camera_solid;
      } else {
        return Icons.switch_camera;
      }
    case CameraLensDirection.external:
      if (Platform.isIOS) {
        return CupertinoIcons.photo_camera;
      } else {
        return Icons.photo_camera;
      }
  }
}

/// Select the platform appropriate flash icon based on the mode
IconData getFlashIcon(FlashMode flashMode) {
  switch(flashMode) {
    case FlashMode.off:
      if (Platform.isIOS) {
        return CupertinoIcons.bolt_slash_fill;
      } else {
        return Icons.flash_off;
      }
    case FlashMode.auto:
      if (Platform.isIOS) {
        return CupertinoIcons.bolt_badge_a_fill;
      } else {
        return Icons.flash_auto;
      }
    case FlashMode.always:
      if (Platform.isIOS) {
        return CupertinoIcons.bolt_fill;
      } else {
        return Icons.flash_on;
      }
    case FlashMode.torch:
      if (Platform.isIOS) {
        return CupertinoIcons.bolt_circle_fill;
      } else {
        return Icons.flashlight_on;
      }
  }
}

/// Select the text appropriate to the tag
/// TODO: This is temporary, we should make custom icons
Text getTagText(LifetimeTag lifetimeTag) {
  switch (lifetimeTag) {
    case LifetimeTag.oneDay:
      return const Text("1");
    case LifetimeTag.sevenDays:
      return const Text("7");
    case LifetimeTag.thirtyDays:
      return const Text("30");
  }
}