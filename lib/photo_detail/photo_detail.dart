import 'dart:io';

import 'package:didit/common/platformization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toggle_switch/toggle_switch.dart';

// Storage
import '../storage/adapters.dart';
import '../storage/schema.dart';

class PhotoDetail extends StatefulWidget {
  final List<dynamic> memories;
  final int index;

  const PhotoDetail(
      {Key? key,
      required this.index,
      required this.memories})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => PhotoDetailState();
}

class PhotoDetailState extends State<PhotoDetail> {
  // default current index is from PhotoDetail class
  late int curIndex;
  late ValueNotifier<String> timeToExpire;
  late Memory cachedMemory;
  late Box<Memory> memoryBox;

  PhotoDetailState();

  // variables I don't want to change in build method with calling setState
  //Menu? _selectedMenu;
  PhotoViewScaleStateController scaleStateController =
      PhotoViewScaleStateController();

  @override
  void initState() {
    super.initState();
    memoryBox = getMemoryBox();
    curIndex = widget.index;
    updateMemoryCache();
    timeToExpire = ValueNotifier(cachedMemory.getTimeToExpire());
  }

  Memory updateMemoryCache() {
    debugPrint("Caching new memory");
    cachedMemory = memoryBox.get(widget.memories[curIndex])!;
    debugPrint("New memory cached");
    return cachedMemory;
  }

  @override
  Widget build(BuildContext context) {
    // initial index is taken from PhotoDetail class
    PageController pageController = PageController(initialPage: curIndex);
    int popScreenCount = 0;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).colorScheme.onBackground,
              onPressed: () async {
                Navigator.pop(context);
              }),
          actions: <Widget>[
            FittedBox(
              child: ToggleSwitch(
                // Indexing the buttons
                initialLabelIndex:
                    LifetimeTag.values.indexOf(cachedMemory.lifetimeTag),
                totalSwitches: LifetimeTag.values.length,
                // Styling
                animate: true,
                radiusStyle: true,
                cornerRadius: 25,
                inactiveFgColor: Colors.white,
                borderWidth: 10.0,
                labels: [for (final tag in LifetimeTag.values) tag.tagName()],
                activeBgColors: [
                  for (final tag in LifetimeTag.values) [tag.tagColor()]
                ],
                // Callback
                onToggle: (index) {
                  if (LifetimeTag.values[index!] != cachedMemory.lifetimeTag) {
                    updateMemoryTag(cachedMemory, LifetimeTag.values[index]);
                    updateMemoryCache();
                    cachedMemory.lifetimeTag = LifetimeTag.values[index];
                    timeToExpire.value = cachedMemory.getTimeToExpire();
                  }
                },
              ),
            ),
            IconButton(
                icon: Icon(getShareIcon()),
                color: Theme.of(context).colorScheme.onBackground,
                onPressed: () async {
                  final directory = (await getExternalStorageDirectory())?.path;
                  File imgFile = File('${directory}assets/screenshot.png');
                  imgFile.writeAsBytes(cachedMemory.pictureBytes);
                  await Share.shareXFiles(
                      [XFile('${directory}assets/screenshot.png')]);
                  imgFile.delete();
                }),
            IconButton(
                icon: Icon(getDeleteIcon()),
                color: Theme.of(context).colorScheme.onBackground,
                onPressed: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Do you want to delete this photo?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            deleteMemory(cachedMemory);
                            // two pop
                            Navigator.of(context)
                                .popUntil((_) => popScreenCount++ >= 2);
                            popScreenCount = 0;
                          },
                          child: const Text('Delete'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  );
                }),
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
                        ? event.cumulativeBytesLoaded / memoryBox.length
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
                        print("Text updated!");
                        return Text("Deleted in: ${timeToExpire.value}",
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
