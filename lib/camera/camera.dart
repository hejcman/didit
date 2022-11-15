import 'dart:developer';

import 'package:didit/camera/widgets.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// Camera helpers
import 'helpers.dart' as camera_helpers;

// Common widgets
import '../common/orientation_widget.dart';

// Storage
import '../storage/adapters.dart';
import '../storage/schema.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController cameraController;
  late Future<void> cameraControllerFuture;
  late List<CameraDescription> cameras;
  late int currentCameraIndex;

  FlashMode flashMode = FlashMode.values[0];
  LifetimeTag lifetimeTag = LifetimeTag.values[0];

  Future initCamera(CameraDescription cameraDescription) async {
    cameraController = CameraController(
        cameraDescription, ResolutionPreset.veryHigh,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
    // cameraController.addListener(() {
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });

    // TODO: Present error and go back to the home screen
    if (cameraController.value.hasError) {
      print(cameraController.value.errorDescription);
    }

    try {
      cameraControllerFuture = cameraController.initialize();
    } catch (e) {
      print("Problem initializing the camera.");
    }
  }

  @override
  void initState() {
    super.initState();
    // Get the list of cameras that are available to use
    availableCameras().then((List<CameraDescription> c) {
      // No cameras available
      // TODO: Present error and go back to the home screen
      if (c.isEmpty) {
        print("No cameras available!");
      }
      // Initialize the cameras
      cameras = c;
      setState(() {
        currentCameraIndex = 0;
      });
      initCamera(cameras[currentCameraIndex]);
    }).catchError((e) {
      FlutterError.presentError(e);
    });
  }

  /// Increment camera index with overflow check
  void switchCamera() {
    // Select the next camera
    if (currentCameraIndex < cameras.length - 1) {
      currentCameraIndex += 1;
    } else {
      currentCameraIndex = 0;
    }
    // Initialize it
    initCamera(cameras[currentCameraIndex]);
  }

  /// Loop through the flash modes.
  void incrementFlashMode() {
    log("Updating the flash mode, current state: ${flashMode.name}");
    // Modulo allows for looping back to the first value
    final nextIndex = (flashMode.index + 1) % FlashMode.values.length;
    flashMode = FlashMode.values[nextIndex];
    cameraController.setFlashMode(flashMode);
    log("Flash mode updated, new state: ${flashMode.name}");
  }

  void incrementLifetimeTag() {
    log("Updating the lifetime tag, current state: ${lifetimeTag.name}");
    final nextIndex = (lifetimeTag.index + 1) % LifetimeTag.values.length;
    lifetimeTag = LifetimeTag.values[nextIndex];
    log("Lifetime tag updated, new state: ${lifetimeTag.name}");
  }

  /// Set the current camera zoom
  Future<void> setCameraZoom(double zoom) async {
    double minZoomLevel = await cameraController.getMinZoomLevel();
    double maxZoomLevel = await cameraController.getMaxZoomLevel();

    // If the minimum zoom level is larger than the supplied zoom level,
    // zoom the camera out as much as possible.
    if (zoom < minZoomLevel) {
      cameraController.setZoomLevel(minZoomLevel);

      // If we are within the bounds of allowed zoomed levels, just set the zoom
      // level.
    } else if (zoom < maxZoomLevel) {
      cameraController.setZoomLevel(zoom);

      // If we exceed the maximum zoom level, set it.
    } else {
      cameraController.setZoomLevel(maxZoomLevel);
    }
  }

  Widget createCameraView() {
    return FutureBuilder<void>(
        future: cameraControllerFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          // Camera is not ready, show the loading indicator
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          // Camera is ready, show the preview
          // Camera is ready, show the screen
          return Expanded(
              child: GestureDetector(
                  onScaleUpdate: (details) async {
                    setCameraZoom(details.scale);
                  },
                  child: CameraPreview(cameraController)));
        });
  }

  Widget createBackButton() {
    return OrientationWidget(
        child: MaterialButton(
            child: Icon(
              Icons.arrow_back,
              color: Colors.black87,
            ),
            color: Colors.white,
            padding: EdgeInsets.all(10),
            shape: CircleBorder(),
            onPressed: () async {
              Navigator.pop(context);
            }));
  }

  Widget createFlashbackButton() {
    return OrientationWidget(
      child: FlashButton(
        parentCallback: incrementFlashMode,
      ),
    );
  }

  Widget createTagButton() {
    return OrientationWidget(
        child: TagButton(parentCallback: incrementLifetimeTag));
  }

  Widget createSwitchCameraButton() {
    return OrientationWidget(
        child: MaterialButton(
      color: Theme.of(context).colorScheme.primaryContainer,
      onPressed: switchCamera,
      padding: EdgeInsets.all(10),
      shape: CircleBorder(),
      child: Icon(camera_helpers
          .getCameraIcon(cameras[currentCameraIndex].lensDirection)),
    ));
  }

  Widget createCaptureButton() {
    return OrientationWidget(
        child: MaterialButton(
      color: Colors.white,
      onPressed: () async {
        try {
          // Ensure the camera is initialized
          await cameraControllerFuture;
          // Attempt to take a picture
          final image = await cameraController.takePicture();
          // Create memory from the image
          final memory = Memory(await image.lastModified(),
              await image.readAsBytes(), lifetimeTag);
          // Save Memory to database
          createMemory(memory);
        } catch (e) {
          print(e);
        }
      },
      padding: EdgeInsets.all(22),
      shape: CircleBorder(),
      child: Icon(Icons.camera),
    ));
  }

  Widget createBottomButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        createTagButton(),
        createCaptureButton(),
        createSwitchCameraButton(),
      ],
    );
  }

  Widget createTopButtonRow() {
    return Row(
      children: [createBackButton(), createFlashbackButton()],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black12,
        body: Stack(
          children: [
            Align(
                alignment: AlignmentDirectional.center,
                child: createCameraView()),
            SafeArea(
                child: Align(
              alignment: AlignmentDirectional.topCenter,
              child: createTopButtonRow(),
            )),
            SafeArea(
                child: Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: createBottomButtonRow(),
            ))
          ],
        ));
  }
}

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
