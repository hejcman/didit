
import 'package:camera/camera.dart';
import 'package:didit/storage/schema.dart';
import 'package:flutter/material.dart';

import 'helpers.dart' as camera_helpers;

////////////////////////////////////////////////////////////////////////////////
// FLASH BUTTON

class FlashButton extends StatefulWidget {
  const FlashButton({super.key, required this.parentCallback});

  final void Function() parentCallback;

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
          widget.parentCallback();
        });
      },
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// TAG BUTTON

class TagButton extends StatefulWidget {
  const TagButton({super.key, required this.parentCallback});

  final void Function() parentCallback;

  @override
  State<TagButton> createState() => _TagButtonState();
}

class _TagButtonState extends State<TagButton> {

  // Selecting the first tag
  LifetimeTag currentTag = LifetimeTag.values[0];

  LifetimeTag incrementCurrentTag() {
    final nextIndex = (currentTag.index + 1) % LifetimeTag.values.length;
    return LifetimeTag.values[nextIndex];
  }

  @override
  Widget build(BuildContext context) {
   return TextButton(
     onPressed: () {
       setState(() {
         currentTag = incrementCurrentTag();
         widget.parentCallback();
       });
     },
     child: camera_helpers.getTagText(currentTag),
   );
  }
}
