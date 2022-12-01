import 'package:camera/camera.dart';
import 'package:didit/storage/schema.dart';
import 'package:flutter/material.dart';
import 'package:didit/common/orientation_widget.dart';

import 'helpers.dart' as camera_helpers;

////////////////////////////////////////////////////////////////////////////////
// ACTION BUTTON

class ActionButton extends StatelessWidget {
  const ActionButton(
      {super.key, this.child, required this.onPressed, this.color});

  final VoidCallback? onPressed;
  final Widget? child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return OrientationWidget(
        child: MaterialButton(
      color: color ?? Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.all(10),
      shape: const CircleBorder(),
      onPressed: onPressed,
      child: child,
    ));
  }
}

////////////////////////////////////////////////////////////////////////////////
// FLASH BUTTON

class FlashButton extends StatefulWidget {
  const FlashButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

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
    return OrientationWidget(
        child: ActionButton(
            child: Icon(camera_helpers.getFlashIcon(flashMode)),
            onPressed: () {
              setState(() {
                flashMode = incrementFlashMode();
                widget.onPressed?.call();
              });
            }));
  }
}

////////////////////////////////////////////////////////////////////////////////
// TAG BUTTON

class TagButton extends StatefulWidget {
  const TagButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

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
    return OrientationWidget(
      child: MaterialButton(
        color: Theme.of(context).colorScheme.primaryContainer,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: () {
          setState(() {
            currentTag = incrementCurrentTag();
            widget.onPressed?.call();
          });
        },
        child: currentTag.shortIconWidget(color: Colors.black87),
      ),
    );
  }
}
