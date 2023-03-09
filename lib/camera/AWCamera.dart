import 'dart:io';
import 'dart:math';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/generated/i18n.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:didit/camera/widgets.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:camerawesome/src/orchestrator/analysis/analysis_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:didit/camera/AWButtons/AWFlashButton.dart';
import 'package:didit/camera/AWButtons/AWSwitchButton.dart';
import 'package:didit/camera/AWButtons/AWCaptureButton.dart';

// Common widgets
import '../common/platformization.dart';

// Storage
import '../storage/adapters.dart';
import '../storage/schema.dart';

// Globals
import '../globals.dart';

import 'package:vibration/vibration.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  // Camera Controllers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.custom(
        builder: (cameraState, previewSize, previewRect) {
          return cameraState.when(
            onPreparingCamera: (state) =>
                const Center(child: CircularProgressIndicator()),
            onPhotoMode: (state) => PhotoCameraUI(state),
            onVideoMode: (state) {},
            onVideoRecordingMode: (state) {},
          );
        },
        previewFit: CameraPreviewFit.contain,
        saveConfig: SaveConfig.photo(pathBuilder: () async {
          final Directory extDir = await getTemporaryDirectory();
          final testDir =
              await Directory('${extDir.path}/test').create(recursive: true);
          return '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        }),
        // saveConfig: SaveConfig.photo(pathBuilder: () async {
        //   // try {
        //   //   // Attempt to take a picture
        //   //   final image = await _cameraController!.takePicture();

        //   //   // Create memory from the image
        //   //   final memory = Memory(await image.lastModified(),
        //   //       await image.readAsBytes(), lifetimeTag);
        //   //   // Save Memory to database
        //   //   createMemory(memory);
        //   //   await File(image.path).delete();
        //   // } catch (e) {
        //   //   log("$e");
        //   // }
        //   return "some/path.jpg";
        // }),
      ),
    );
  }
}

class PhotoCameraUI extends StatelessWidget {
  final PhotoCameraState state;

  const PhotoCameraUI(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      SafeArea(
          child: Align(
        alignment: AlignmentDirectional.topCenter,
        child: createTopButtonRow(context, state),
      )),
      SafeArea(
          child: Align(
        alignment: AlignmentDirectional.bottomCenter,
        child: createBottomButtonRow(state),
      ))
    ]);
  }
}

Widget createTopButtonRow(BuildContext context, CameraState state) {
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
      AWFlashButton(state: state)
    ],
  );
}

Widget createBottomButtonRow(CameraState state) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      //TagButton(onPressed: incrementLifetimeTag),
      Column(
        children: [
          AwesomeSensorTypeSelector(state: state),
          AWCaptureButton(state: state)
        ],
      ),
      AWSwitchButton(state: state),
    ],
  );
}
// Widget createCaptureButton() {
//   return OrientationWidget(
//       child: MaterialButton(
//     color: Colors.white,
//     onPressed: () async {
//       try {
//         if (Platform.isAndroid) {
//           Vibration.vibrate(duration: 60);
//         } else if (Platform.isIOS) {
//           Vibration.vibrate(duration: 30);
//         }
//         // Attempt to take a picture
//         final image = await _cameraController!.takePicture();

//         // Create memory from the image
//         final memory = Memory(await image.lastModified(),
//             await image.readAsBytes(), lifetimeTag);
//         // Save Memory to database
//         createMemory(memory);
//         await File(image.path).delete();
//       } catch (e) {
//         log("$e");
//       }
//     },
//     padding: const EdgeInsets.all(22),
//     shape: const CircleBorder(),
//     child: Icon(getCameraIcon()),
//   ));
// }




