import 'dart:io';

import 'package:didit/common/platformization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toggle_switch/toggle_switch.dart';

// Storage
import '../globals.dart';
import '../storage/adapters.dart';
import '../storage/schema.dart';

// Globals
import '../globals.dart' as globals;

//Localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PhotoDetail extends StatefulWidget {
  final List<dynamic> memories;
  final int index;

  /// A widget for showing a detailed view of a photograph.
  ///
  /// @param this.index The index of the currently selected image in the list of memories.
  /// @param this.memories The keys of all the memories to include in the image view.
  const PhotoDetail({Key? key, required this.index, required this.memories})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => PhotoDetailState();
}

class PhotoDetailState extends State<PhotoDetail> {
  late int curIndex;
  late ValueNotifier<String> timeToExpire;
  late Memory cachedMemory;
  // late Box<Memory> memoryBox;

  PhotoDetailState();

  PhotoViewScaleStateController scaleStateController =
      PhotoViewScaleStateController();

  @override
  void initState() {
    super.initState();
    // memoryBox = getMemoryBox();
    curIndex = widget.index;
    timeToExpire = ValueNotifier("Unknown");
    updateMemoryCache();
  }

  /// Update the cached memory.
  void updateMemoryCache() {
    cachedMemory = globals.box.get(widget.memories[curIndex])!;
    timeToExpire.value = cachedMemory.getTimeToExpire();
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  Widget changeTagToggle() {
    return FittedBox(
      child: ToggleSwitch(
        // Indexing the buttons
        initialLabelIndex: LifetimeTag.values.indexOf(cachedMemory.lifetimeTag),
        totalSwitches: LifetimeTag.values.length,
        // Styling
        animate: true,
        animationDuration: 200,
        curve: Curves.easeInOutCirc,
        radiusStyle: true,
        cornerRadius: 25,
        inactiveFgColor: Colors.white,
        borderWidth: 10.0,
        labels: [
          for (final tag in LifetimeTag.values)
            AppLocalizations.of(context)!.nDays(tag.tagToInt())
        ],
        activeBgColors: [
          for (final tag in LifetimeTag.values) [tag.tagColor()]
        ],
        // Callback
        onToggle: (index) {
          if (LifetimeTag.values[index!] != cachedMemory.lifetimeTag) {
            cachedMemory.lifetimeTag = LifetimeTag.values[index];
            cachedMemory.created = DateTime.now();
            updateMemory(cachedMemory);
            timeToExpire.value = cachedMemory.getTimeToExpire();
          }
        },
      ),
    );
  }

  Widget shareButton() {
    return IconButton(
        icon: Icon(getShareIcon()),
        color: Theme.of(context).colorScheme.onBackground,
        onPressed: () async {
          try {
            Directory? directory;
            if (Platform.isIOS) {
              if (await _requestPermission(Permission.photos)) {}
              final shareResult = await Share.shareXFiles([
                XFile.fromData(
                  cachedMemory.pictureBytes,
                  name: 'flutter_logo.png',
                  mimeType: 'image/png',
                ),
              ]);
            } else if (Platform.isAndroid) {
              await Share.shareXFiles([
                XFile.fromData(cachedMemory.pictureBytes,
                    name: 'did-it-${DateTime.now().toString()}.png',
                    mimeType: 'image/png')
              ]);
            }
          } on PlatformException catch (e) {
            print("Exception while taking screenshot:$e");
          }
        });
  }

  Widget importToGalleryButton() {
    return IconButton(
        icon: Icon(getDownloadIcon()),
        color: Theme.of(context).colorScheme.onBackground,
        onPressed: _savePhoto);
  }

  Widget deleteButton() {
    int popScreenCount = 0;
    return IconButton(
        icon: Icon(getDeleteIcon()),
        color: Theme.of(context).colorScheme.onBackground,
        onPressed: () {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.question_delete),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    deleteMemory(cachedMemory);
                    // two pop
                    Navigator.of(context)
                        .popUntil((_) => popScreenCount++ >= 2);
                    popScreenCount = 0;
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.pink,
                  ),
                  child: Text(AppLocalizations.of(context)!.delete),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
              ],
            ),
          );
        });
  }

  void _savePhoto() async {
    if (Platform.isAndroid) {
      // final path = (await getExternalStorageDirectory())?.path;
      // final imgPath = '$path/assets/${cachedMemory.lifetimeTag}.png';
      // File imgFile = File(
      //     '$path/assets/${cachedMemory.lifetimeTag}.png'); //FIXME: K čemu to je?
      // imgFile.writeAsBytes(cachedMemory.pictureBytes);
      //
      // await FlutterExifRotation.rotateImage(path: imgPath);
      // await ImageGallerySaver.saveFile(imgPath);
      // imgFile.delete(); //FIXME: K čemu to je?
      await ImageGallerySaver.saveImage(cachedMemory.pictureBytes);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Saved into gallery")));
    } else if (Platform.isIOS) {
      if (await _requestPermission(Permission.photos)) {
        await ImageGallerySaver.saveImage(cachedMemory.pictureBytes);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // initial index is taken from PhotoDetail class
    PageController pageController = PageController(initialPage: curIndex);

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).colorScheme.onBackground,
              onPressed: () async {
                Navigator.pop(context);
              }),
          actions: <Widget>[
            changeTagToggle(),
            shareButton(),
            importToGalleryButton(),
            deleteButton(),
          ],
        ),
        body: Stack(
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              pageController: pageController,
              onPageChanged: (int index) {
                setState(() {
                  curIndex = index;
                  updateMemoryCache();
                });
              },
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                    imageProvider: MemoryImage(cachedMemory.pictureBytes),
                    heroAttributes: PhotoViewHeroAttributes(tag: index),
                    maxScale: PhotoViewComputedScale.covered * 3,
                    minScale: PhotoViewComputedScale.contained,
                    scaleStateController: scaleStateController,
                    gestureDetectorBehavior: HitTestBehavior.deferToChild,
                    onScaleEnd: (context, details, controllerValue) =>
                        scaleStateController.scaleState =
                            PhotoViewScaleState.covering);
              },
              enableRotation: true,
              itemCount: widget.memories.length,
              loadingBuilder: (context, event) => Center(
                child: SizedBox(
                  width: 30.0,
                  height: 30.0,
                  child: CircularProgressIndicator(
                    value: event != null
                        ? event.cumulativeBytesLoaded / globals.box.length
                        : 0,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: Colors.black87.withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ValueListenableBuilder<String>(
                      valueListenable: timeToExpire,
                      builder:
                          (BuildContext context, String value, Widget? child) {
                        return Text(
                            AppLocalizations.of(context)!.delete_in +
                                ": ${timeToExpire.value}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300));
                      },
                    )),
              ),
            ),
          ],
        ));
  }
}
