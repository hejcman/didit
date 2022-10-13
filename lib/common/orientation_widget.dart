
import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';


class OrientationWidget extends StatefulWidget {
  /// Creates a new orientation widget which keeps the child rotated with the orientation of the device.
  const OrientationWidget({super.key, required this.child, this.animationDuration = 1000});

  /// The child widget which will be kept aligned with orientation.
  final Widget child;

  /// The duration of the rotation in milliseconds.
  final int animationDuration;

  @override
  State<StatefulWidget> createState() => _OrientationWidgetState();
}

class _OrientationWidgetState extends State<OrientationWidget> with TickerProviderStateMixin {

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animationDuration),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    /// The tween generated doubles in the range <-0.5; 0.5>.
    ///
    /// Therefore, if we don't want to rotate the child, we need to set its
    /// animation to 0.5, which would be in the middle of this tween, which would
    /// result in an angle of 0. Likewise, setting the animation to state 0 would
    /// result in a counterclockwise rotation of 90 degrees.
    Tween<double> tween = Tween(begin: -0.5, end:0.5);

    return NativeDeviceOrientationReader(
        useSensor: true,
        builder: (BuildContext context) {
          final orientation = NativeDeviceOrientationReader.orientation(context);
          switch (orientation) {
            case NativeDeviceOrientation.portraitUp:
              _animationController.animateTo(0.5);
              break;
            case NativeDeviceOrientation.portraitDown:
              _animationController.animateTo(0.0);
              break;
            case NativeDeviceOrientation.landscapeLeft:
              _animationController.animateTo(0.75);
              break;
            case NativeDeviceOrientation.landscapeRight:
              _animationController.animateTo(0.25);
              break;
            case NativeDeviceOrientation.unknown:
              break;
          }

          return RotationTransition(
            turns: tween.animate(_animationController),
            child: widget.child
          );
        }
    );
  }
}


