
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'helpers.dart' as camera_helpers;

////////////////////////////////////////////////////////////////////////////////
// FLASH BUTTON

/// NOTE: Currently unused, probably unnecessary
class FlashButton extends StatefulWidget {
  const FlashButton({super.key});

  @override
  State<FlashButton> createState() => _FlashButtonState();
}

class _FlashButtonState extends State<FlashButton> {

  // Selecting the first flash mode
  FlashMode flashMode = FlashMode.values[0];

  FlashMode incrementFlashMode() {
    final nextIndex = (flashMode.index + 1) % FlashMode.values.length;
    return FlashMode.values[nextIndex];
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(camera_helpers.getFlashIcon(flashMode)),
      onPressed: () {
        setState(() {
          flashMode = incrementFlashMode();
        });
      },
    );
  }
}
