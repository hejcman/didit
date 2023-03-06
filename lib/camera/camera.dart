import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

// Camera helpers
import 'widgets.dart';
import 'helpers.dart' as camera_helpers;

// Common widgets
import '../common/orientation_widget.dart';
import '../common/platformization.dart';

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

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  // The controller for the currently selected camera
  CameraController? _cameraController;

  // The index of the currently selected camera
  int _currentCameraIndex = 0;

  // The state of the currently selected controller
  bool _cameraControllerInitialized = false;

  bool _enableVibration = false;

  FlashMode flashMode = FlashMode.values[0];
  LifetimeTag lifetimeTag = LifetimeTag.values[0];

  double currentScale = 1.0;
  double baseScale = 1.0;
  double minAvailableZoom = 1.0;
  double maxAvailableZoom = 5.0;
  int pointers = 0;

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /// OVERRIDES
  ///
  @override
  void initState() {
    super.initState();
    // If we have no cameras, return home
    if (cameras.isEmpty) returnHome();

    // Get the permission to use a camera
    if (!Platform.isIOS) {
      obtainCameraPermission();
    }

    Vibration.hasVibrator().then((value) {
      // If we don't get anything, leave it as false
      if (value == null) return;

      // Check whether we have the proper settings value
      bool? userPref = prefs.getBool(Settings.enableVibration.key);
      userPref ??= true; // if null, assume true

      _enableVibration = userPref && value;
    });

    initCamera();
  }

  @override
  void dispose() {
    _cameraController!.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cam = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cam == null || !cam.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cam.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /// INITS

  /// Initialize the passed CameraDescription.
  void initCamera() async {
    final previousCameraController = _cameraController;
    // Create a new camera controller
    CameraController newCameraController = CameraController(
        cameras[_currentCameraIndex],
        ResolutionPreset.values[prefs.getInt(Settings.cameraQuality.key)!],
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg);

    // Set the camera to uninitialized to make sure we don't access a disposed controller.
    if (mounted) {
      setState(() {
        _cameraControllerInitialized = false;
        _cameraController = newCameraController;
      });
    }

    // Dispose the controller
    await previousCameraController?.dispose();

    // Update the UI if the controller is updated
    newCameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // TODO: Present error and go back to the home screen
    if (_cameraController!.value.hasError) {
      log("${_cameraController!.value.errorDescription}");
    }

    try {
      await newCameraController.initialize();
      //flashMode = newCameraController.value.flashMode;
    } catch (e) {
      debugPrint("Problem initializing the camera.");
    }

    if (mounted) {
      setState(() {
        _cameraControllerInitialized = _cameraController!.value.isInitialized;
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

  /// Loop through all the camera indexes.
  void incrementCamera() {
    log("Updating the currently selected camera, current index: $_currentCameraIndex/${cameras.length}");
    final nextIndex = (_currentCameraIndex + 1) % cameras.length;
    _currentCameraIndex = nextIndex;
    initCamera();
    log("The updated camera index: $_currentCameraIndex/${cameras.length}");
  }

  /// Loop through the flash modes.
  void incrementFlashMode() {
    log("Updating the flash mode, current state: ${flashMode.name}");
    // Modulo allows for looping back to the first value
    final nextIndex = (flashMode.index + 1) % FlashMode.values.length;
    flashMode = FlashMode.values[nextIndex];
    _cameraController!.setFlashMode(flashMode);
    log("Flash mode updated, new state: ${flashMode.name}");
  }

  /// Loop through all the lifetime tags.
  void incrementLifetimeTag() {
    log("Updating the lifetime tag, current state: ${lifetimeTag.name}");
    final nextIndex = (lifetimeTag.index + 1) % LifetimeTag.values.length;
    lifetimeTag = LifetimeTag.values[nextIndex];
    log("Lifetime tag updated, new state: ${lifetimeTag.name}");
  }

  /// Set the current camera zoom
  Future<void> setCameraZoom(double zoom) async {
    double minZoomLevel = await _cameraController!.getMinZoomLevel();
    double maxZoomLevel = await _cameraController!.getMaxZoomLevel();

    // If the minimum zoom level is larger than the supplied zoom level,
    // zoom the camera out as much as possible.
    if (zoom < minZoomLevel) {
      _cameraController!.setZoomLevel(minZoomLevel);

      // If we are within the bounds of allowed zoomed levels, just set the zoom
      // level.
    } else if (zoom < maxZoomLevel) {
      _cameraController!.setZoomLevel(zoom);

      // If we exceed the maximum zoom level, set it.
    } else {
      _cameraController!.setZoomLevel(maxZoomLevel);
    }
  }

  /// Set the focus point of the current camera.
  setCameraFocus(TapDownDetails details, BoxConstraints constraints) {
    final offset = Offset(details.localPosition.dx / constraints.maxWidth,
        details.localPosition.dy / constraints.maxHeight);
    _cameraController!.setFocusPoint(offset);
    _cameraController!.setExposurePoint(offset);
  }

  void handleScaleStart(ScaleStartDetails details) {
    baseScale = currentScale;
  }

  Future<void> handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (pointers != 2) {
      return;
    }

    currentScale =
        (baseScale * details.scale).clamp(minAvailableZoom, maxAvailableZoom);

    await _cameraController!.setZoomLevel(currentScale);
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /// WIDGETS

  Widget createCameraView() {
    // Camera is not ready, show the loading indicator
    if (!_cameraControllerInitialized) {
      return Center(child: loadingIndicator(context));
    }
    // If the camera is ready, we can show it
    return Listener(
      onPointerDown: (_) => pointers++,
      onPointerUp: (_) => pointers--,
      child: CameraPreview(
        _cameraController!,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: handleScaleStart,
                onScaleUpdate: handleScaleUpdate,
                onTapDown: (details) => setCameraFocus(details, constraints));
          },
        ),
      ),
    );
  }

  Widget createCaptureButton() {
    return OrientationWidget(
        child: MaterialButton(
      color: Colors.white,
      onPressed: () async {
        try {
          if (Platform.isAndroid) {
            Vibration.vibrate(duration: 60);
          } else if (Platform.isIOS) {
            Vibration.vibrate(duration: 30);
          }
          // Attempt to take a picture
          final image = await _cameraController!.takePicture();

          // Create memory from the image
          final memory = Memory(await image.lastModified(),
              await image.readAsBytes(), lifetimeTag);
          // Save Memory to database
          createMemory(memory);
          await File(image.path).delete();
        } catch (e) {
          log("$e");
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
          onPressed: incrementCamera,
          child: Icon(camera_helpers
              .getCameraIcon(cameras[_currentCameraIndex].lensDirection)),
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
