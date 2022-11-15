import 'dart:io';

import 'package:camera/camera.dart';
import 'package:didit/storage/adapters.dart';
import 'package:didit/storage/schema.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';

import 'globals.dart';

enum Menu { itemOne, itemTwo, itemThree }

// TODO: where to put these map functions
String mapToText(Menu menuItem) {
  switch (menuItem) {
    case Menu.itemOne:
      return "1";
    case Menu.itemTwo:
      return "7";
    case Menu.itemThree:
      return "30";
  }
}

Menu mapToMenu(LifetimeTag tag) {
  switch (tag) {
    case LifetimeTag.oneDay:
      return Menu.itemOne;
    case LifetimeTag.sevenDays:
      return Menu.itemTwo;
    case LifetimeTag.thirtyDays:
      return Menu.itemThree;
  }
}

LifetimeTag mapToTag(Menu menuItem) {
  switch (menuItem) {
    case Menu.itemOne:
      return LifetimeTag.oneDay;
    case Menu.itemTwo:
      return LifetimeTag.sevenDays;
    case Menu.itemThree:
      return LifetimeTag.thirtyDays;
  }
}

class PhotoDetail extends StatefulWidget {
  final Box<Memory> box;
  final int index;

  PhotoDetail({Key? key, required this.box, required this.index})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => PhotoDetailState(curIndex: this.index);
}

class PhotoDetailState extends State<PhotoDetail> {
  // default current is from PhotoDetail class
  int curIndex;
  PhotoDetailState({required this.curIndex});

  // variables I don't want to change in build method with calling setState
  Menu? _selectedMenu;
  PhotoViewScaleStateController scaleStateController =
      PhotoViewScaleStateController();

  @override
  Widget build(BuildContext context) {
    // initial index is taken from PhotoDetail class
    PageController _pageController = PageController(initialPage: curIndex);
    // memory of current index
    Memory? memory = widget.box.getAt(curIndex);
    int popScreenCount = 0;

    return Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(5),
              child: Container(
                child: Text("Deleted in: ${memory!.getTimeToExpire()}"),
              )),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                Navigator.pop(context);
              }),
          actions: <Widget>[
            PopupMenuButton<Menu>(
                onSelected: (Menu item) {
                  setState(() {
                    _selectedMenu = item;
                    widget.box.getAt(curIndex)!.lifetimeTag = mapToTag(item);
                  });
                },
                icon: Text(mapToText(mapToMenu(memory.lifetimeTag))),
                iconSize: 60.0,
                itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
                      const PopupMenuItem<Menu>(
                        value: Menu.itemOne,
                        child: Text('1 Day'),
                      ),
                      const PopupMenuItem<Menu>(
                        value: Menu.itemTwo,
                        child: Text('7 Days'),
                      ),
                      const PopupMenuItem<Menu>(
                        value: Menu.itemThree,
                        child: Text('30 Days'),
                      ),
                    ]),
            IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  final directory = (await getExternalStorageDirectory())?.path;
                  File imgFile = new File('${directory}assets/screenshot.png');
                  imgFile.writeAsBytes(memory!.pictureBytes);
                  await Share.shareXFiles(
                      [XFile('${directory}assets/screenshot.png')]);
                  //TODO: check if deleted
                  imgFile.delete();
                }),
            IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Do you want to delete this photo?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            deleteMemory(memory!);
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
        body: Container(
            child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          pageController: _pageController,
          onPageChanged: (int index) {
            setState(() {
              curIndex = index;
            });
          },
          builder: (BuildContext context, int index) {
            memory = widget.box.getAt(index);
            return PhotoViewGalleryPageOptions(
                imageProvider: MemoryImage(memory!.pictureBytes),
                heroAttributes: PhotoViewHeroAttributes(tag: curIndex),
                maxScale: PhotoViewComputedScale.covered * 3,
                minScale: PhotoViewComputedScale.contained,
                scaleStateController: scaleStateController,
                // TODO: TEST ME: rotation? only for the time you are touching the display
                gestureDetectorBehavior: HitTestBehavior.deferToChild,
                onScaleEnd: (context, details, controllerValue) =>
                    scaleStateController.scaleState =
                        PhotoViewScaleState.covering);
          },
          enableRotation: true,
          itemCount: widget.box.length,
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 30.0,
              height: 30.0,
              child: CircularProgressIndicator(
                value: event != null
                    ? event.cumulativeBytesLoaded / widget.box.length
                    : 0,
              ),
            ),
          ),
        )));
  }
}
