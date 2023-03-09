import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:didit/camera/widgets.dart';

import 'package:camerawesome/camerawesome_plugin.dart';

class AWFlashButton extends StatelessWidget {
  final CameraState state;

  const AWFlashButton({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SensorConfig>(
      stream: state.sensorConfig$,
      builder: (_, sensorConfigSnapshot) {
        if (!sensorConfigSnapshot.hasData) {
          return const SizedBox.shrink();
        }
        final sensorConfig = sensorConfigSnapshot.requireData;
        return StreamBuilder<FlashMode>(
          stream: sensorConfig.flashMode$,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return _CustomFlashButton.from(
                flashMode: snapshot.requireData,
                onPressed: () => sensorConfig.switchCameraFlash());
          },
        );
      },
    );
  }
}

class _CustomFlashButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const _CustomFlashButton(
      {super.key, required this.onPressed, required this.icon});

  factory _CustomFlashButton.from({
    Key? key,
    required FlashMode flashMode,
    required VoidCallback onPressed,
  }) {
    final IconData icon = getFlashIcon(flashMode);
    return _CustomFlashButton(
      key: key,
      onPressed: onPressed,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AwesomeOrientedWidget(
        child: ActionButton(child: Icon(icon), onPressed: onPressed));
  }

  static IconData getFlashIcon(FlashMode flashMode) {
    switch (flashMode) {
      case FlashMode.none:
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
      case FlashMode.on:
        if (Platform.isIOS) {
          return CupertinoIcons.bolt_circle_fill;
        } else {
          return Icons.flashlight_on;
        }
    }
  }
}
