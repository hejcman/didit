import 'dart:developer';

import 'package:didit/camera/widgets.dart';
import 'package:didit/common/platformization.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

// Camera helpers
import 'helpers.dart' as camera_helpers;

// Common widgets
import '../common/orientation_widget.dart';

// Storage
import '../storage/adapters.dart';
import '../storage/schema.dart';

// Globals
import '../globals.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {

  // The index of the currently selected camera
  int currentCameraIndex = 0;
  // The controller for the currently selected camera
  CameraController? cameraController;
  bool _cameraControllerInitialized = false;

  late bool cameraPermission;

  // Index of the front camera
  late int frontCameraIndex;

  FlashMode flashMode = FlashMode.values[0];
  LifetimeTag lifetimeTag = LifetimeTag.values[0];

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /// OVERRIDES
  ///
  @override
  void initState() {
    super.initState();
    // Get preferences


    // Get the permission to use a camera
    obtainCameraPermission();

    if (cameras.isEmpty) returnHome();

    frontCameraIndex = cameras.indexWhere(
        (element) => element.lensDirection == CameraLensDirection.front
    );

    initCamera(cameras[currentCameraIndex]);
  }

  @override
  void dispose() {
    cameraController!.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cam = cameraController;

    // App state changed before we got the chance to initialize.
    if (cam == null || !cam.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cam.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initCamera(cameras[currentCameraIndex]);
    }
  }


  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /// INITS

  /// Initialize the passed CameraDescription.
  void initCamera(CameraDescription cameraDescription) async {
    final previousCameraController = cameraController;
    // Create a new camera controller
    CameraController newCameraController = CameraController(
        cameraDescription,
        ResolutionPreset.values[prefs.getInt(Settings.cameraQuality.key)!],
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg
    );

    // Set the camera to uninitialized to make sure we don't access a disposed controller.
    if (mounted) {
      setState(() {
        _cameraControllerInitialized = false;
        cameraController = newCameraController;
      });
    }

    // Dispose the controller
    await previousCameraController?.dispose();

    // Update the UI if the controller is updated
    newCameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // TODO: Present error and go back to the home screen
    if (cameraController!.value.hasError) {
      print(cameraController!.value.errorDescription);
    }

    try {
      await newCameraController.initialize();
      flashMode = newCameraController.value.flashMode;
    } catch (e) {
      debugPrint("Problem initializing the camera.");
    }

    if (mounted) {
      setState(() {
        _cameraControllerInitialized = cameraController!.value.isInitialized;
      });
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /// HELPERS

  /// Get permission to use the camera
  void obtainCameraPermission() async {
    await Permission.camera.request();
    PermissionStatus permissionStatus = await Permission.camera.status;

    if (permissionStatus.isGranted) {
      return;
    } else {
      returnHome();
    }
  }

  /// Return home
  void returnHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  /// Increment camera index with overflow check
  void switchCamera() {
    // Select the next camera
    if (currentCameraIndex != 0) {
      setState(() {
        currentCameraIndex = 0;
      });
    } else {
      setState(() {
        currentCameraIndex = frontCameraIndex;
      });
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
    cameraController!.setFlashMode(flashMode);
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
    double minZoomLevel = await cameraController!.getMinZoomLevel();
    double maxZoomLevel = await cameraController!.getMaxZoomLevel();

    // If the minimum zoom level is larger than the supplied zoom level,
    // zoom the camera out as much as possible.
    if (zoom < minZoomLevel) {
      cameraController!.setZoomLevel(minZoomLevel);

      // If we are within the bounds of allowed zoomed levels, just set the zoom
      // level.
    } else if (zoom < maxZoomLevel) {
      cameraController!.setZoomLevel(zoom);

      // If we exceed the maximum zoom level, set it.
    } else {
      cameraController!.setZoomLevel(maxZoomLevel);
    }
  }

  setCameraFocus(TapDownDetails details, BoxConstraints constraints) {
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight
    );
    cameraController!.setFocusPoint(offset);
    cameraController!.setExposurePoint(offset);
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /// WIDGETS

  Widget createCameraView() {
    // Camera is not ready, show the loading indicator
    if (!_cameraControllerInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return CameraPreview(
      cameraController!,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => setCameraFocus(details, constraints)
          );
        },
      ),
    );
  }

  Widget createCaptureButton() {
    return OrientationWidget(
        child: MaterialButton(
      color: Colors.white,
      onPressed: () async {
        try {
          // Attempt to take a picture
          final image = await cameraController!.takePicture();
          // Create memory from the image
          final memory = Memory(await image.lastModified(),
              await image.readAsBytes(), lifetimeTag);
          // Save Memory to database
          createMemory(memory);
        } catch (e) {
          print(e);
        }
      },
      padding: const EdgeInsets.all(22),
      shape: const CircleBorder(),
      child: Icon(getCameraIcon()),
    ));
  }

  Widget createBottomButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TagButton(onPressed: incrementLifetimeTag),
        createCaptureButton(),
        ActionButton(
          onPressed: switchCamera,
          child: Icon(camera_helpers
              .getCameraIcon(cameras[currentCameraIndex].lensDirection)),
        ),
      ],
    );
  }

  Widget createTopButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActionButton(
            color: Colors.white,
            onPressed: () async {
              Navigator.pop(context);
            },
            child: Icon(
              getBackArrowIcon(),
              color: Colors.black87,
            )),
        FlashButton(onPressed: incrementFlashMode)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black12,
        body: Stack(
          fit: StackFit.expand,
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
