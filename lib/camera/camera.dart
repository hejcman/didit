
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'helpers.dart' as camera_helpers;

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
      cameraDescription,
      ResolutionPreset.veryHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg
    );
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

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
    // Modulo allows for looping back to the first value
    final nextIndex = (flashMode.index + 1) % FlashMode.values.length;
    flashMode = FlashMode.values[nextIndex];
    cameraController.setFlashMode(flashMode);
  }

  void incrementLifetimeTag() {
    final nextIndex = (lifetimeTag.index + 1) % LifetimeTag.values.length;
    lifetimeTag = LifetimeTag.values[nextIndex];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.pop(context);
          }
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(camera_helpers.getFlashIcon(flashMode)),
            onPressed: incrementFlashMode,
          )
        ],
      ),
      body: FutureBuilder<void>(
        future: cameraControllerFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          // Camera is not ready, show the loading indicator
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          // Camera is ready, show the preview
          // Camera is ready, show the screen
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onScaleUpdate: (details) async {setCameraZoom(details.scale);},
                  child: CameraPreview(cameraController)
                )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  // Tag button
                  TextButton(
                    onPressed: incrementLifetimeTag,
                    child: camera_helpers.getTagText(lifetimeTag),
                  ),

                  // Shutter button
                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.camera),
                      onPressed: () async {
                        try {
                          // Ensure the camera is initialized
                          await cameraControllerFuture;
                          // Attempt to take a picture
                          final image = await cameraController.takePicture();
                          // Create memory from the image
                          final memory = Memory(
                              await image.lastModified(),
                              await image.readAsBytes(),
                              LifetimeTag.oneDay
                          );
                          // Save Memory to database
                          createMemory(memory);
                        } catch (e) {
                          print(e);
                        }
                      },
                    ),
                  ),
                  // Lens picker button

                  // Camera switcher
                  IconButton(
                    onPressed: switchCamera,
                    icon: Icon(
                      camera_helpers.getCameraIcon(cameras[currentCameraIndex].lensDirection)
                    )
                  )
                ],
              ),
            ],
          );
        }
      )
    );
  }
}