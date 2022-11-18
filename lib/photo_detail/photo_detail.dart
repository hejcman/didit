import 'dart:io';

import 'package:camera/camera.dart';
import 'package:didit/photo_detail/photo_detail_service.dart';
import 'package:didit/storage/adapters.dart';
import 'package:didit/storage/schema.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';

import '../globals.dart';

class PhotoDetail extends StatefulWidget {
  final Box<Memory> box;
  final List<Memory> memories;
  final int index;

  PhotoDetail(
      {Key? key,
      required this.box,
      required this.index,
      required this.memories})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => PhotoDetailState(curIndex: this.index);
}

class PhotoDetailState extends State<PhotoDetail> {
  // default current index is from PhotoDetail class
  int curIndex;
  PhotoDetailState({required this.curIndex});

  // variables I don't want to change in build method with calling setState
  //Menu? _selectedMenu;
  PhotoViewScaleStateController scaleStateController =
      PhotoViewScaleStateController();

  @override
  Widget build(BuildContext context) {
    // initial index is taken from PhotoDetail class
    PageController _pageController = PageController(initialPage: curIndex);
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
            PopupMenuButton<Menu>(
                onSelected: (Menu item) {
                  // only when you change tag
                  if (mapToTag(item) != widget.memories[curIndex].lifetimeTag) {
                    setState(() {
                      //_selectedMenu = item;
                      updateMemoryTag(
                          widget.memories[curIndex], mapToTag(item));
                      Navigator.pop(context);
                    });
                  }
                },
                icon: widget.memories[curIndex].lifetimeTag.shortIconWidget(
                    color: Theme.of(context).colorScheme.onBackground),
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
                color: Theme.of(context).colorScheme.onBackground,
                onPressed: () async {
                  final directory = (await getExternalStorageDirectory())?.path;
                  File imgFile = new File('${directory}assets/screenshot.png');
                  imgFile.writeAsBytes(widget.memories[curIndex].pictureBytes);
                  await Share.shareXFiles(
                      [XFile('${directory}assets/screenshot.png')]);
                  imgFile.delete();
                }),
            IconButton(
                icon: const Icon(Icons.delete),
                color: Theme.of(context).colorScheme.onBackground,
                onPressed: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Do you want to delete this photo?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            deleteMemory(widget.memories[curIndex]);
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
            Container(
                child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              pageController: _pageController,
              onPageChanged: (int index) {
                setState(() {
                  curIndex = index;
                });
              },
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                    imageProvider:
                        MemoryImage(widget.memories[index].pictureBytes),
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
            )),
            SafeArea(
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: Container(
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.black87.withOpacity(0.5),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Deleted in: ${widget.memories[curIndex].getTimeToExpire()}",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w300),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
