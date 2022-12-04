
import 'package:flutter/material.dart';

class OrientationWidget extends StatefulWidget {
  /// Creates a new orientation widget which keeps the child rotated with the orientation of the device.
  const OrientationWidget({super.key, required this.child});

  /// The child widget which will be kept aligned with orientation.
  final Widget child;

  @override
  State<StatefulWidget> createState() => _OrientationWidgetState();
}

class _OrientationWidgetState extends State<OrientationWidget> with TickerProviderStateMixin {
  // late AnimationController _animationController;

  @override
  Widget build(BuildContext context) {

    return widget.child;

    // int turns = 0;
    //
    // return NativeDeviceOrientationReader(
    //     useSensor: true,
    //     builder: (BuildContext context) {
    //       final orientation = NativeDeviceOrientationReader.orientation(context);
    //       switch (orientation) {
    //         case NativeDeviceOrientation.portraitUp:
    //           break;
    //         case NativeDeviceOrientation.portraitDown:
    //           turns = 2;
    //           break;
    //         case NativeDeviceOrientation.landscapeLeft:
    //           turns = 1;
    //           break;
    //         case NativeDeviceOrientation.landscapeRight:
    //           turns = 3;
    //           break;
    //         case NativeDeviceOrientation.unknown:
    //           break;
    //       }
    //
    //       return Transform.rotate(
    //         angle: (turns+1)*(math.pi/2),
    //         child: widget.child
    //       );
  }
}
