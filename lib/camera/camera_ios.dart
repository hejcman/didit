import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

class CameraScreenIOS extends StatefulWidget {
  const CameraScreenIOS({super.key});

  @override
  State<CameraScreenIOS> createState() => _CameraScreenIOSState();
}

class _CameraScreenIOSState extends State<CameraScreenIOS> {
  @override
  Widget build(BuildContext context) {
    const String viewType = "plugins.diditapp/flutter_camera_view";
    int i = 0;

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return Stack(
          children: [
            UiKitView(
              viewType: viewType,
              onPlatformViewCreated: _onPlatformViewCreated,
            ),
            MaterialButton(
              onPressed: (() {
                setState(() {
                  i++;
                });
              }),
              color: Colors.red,
            )
          ],
        );
      default:
        return Text(
            '$defaultTargetPlatform is not yet supported by Camera View plugin');
    }
  }

  // Callback method when platform view is created
  void _onPlatformViewCreated(int id) {}
}

class CameraViewController {
  CameraViewController._(int id)
      : _channel = MethodChannel('plugins.diditapp/flutter_camera_view_$id');

  final MethodChannel _channel;

  Future<void> setUrl({required String url}) async {
    return _channel.invokeMethod('setUrl', url);
  }
}
