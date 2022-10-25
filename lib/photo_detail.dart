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

class PhotoDetail extends StatefulWidget {
  final Box<Memory> box;
  final int index;

  PhotoDetail({Key? key, required this.box, required this.index})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => PhotoDetailState();
}

class PhotoDetailState extends State<PhotoDetail> {
  @override
  Widget build(BuildContext context) {
    // using page controller when you open first detail, instead of first photo you see choosen one
    PageController _pageController = PageController(initialPage: widget.index);
    Memory? memory = widget.box.getAt(widget.index);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                Navigator.pop(context);
              }),
          actions: <Widget>[
            // Rotating flash button
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                final directory = (await getExternalStorageDirectory())?.path;
                File imgFile = new File('${directory}assets/screenshot.png');
                imgFile.writeAsBytes(memory!.pictureBytes);
                await Share.shareXFiles(
                    [XFile('${directory}assets/screenshot.png')],
                    text: 'Look what I made.');

                //TODO: delete photo that I store
                //Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                //TODO: delete from db
                deleteMemory(memory!);
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: Container(
            child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          pageController: _pageController,
          builder: (BuildContext context, int index) {
            memory = widget.box.getAt(index);

            // TODO: fix null memory
            // if (memory == null) {
            //   return PhotoViewGalleryPageOptions(
            //       imageProvider: AssetImage("assets/images/1.jpg"));
            // }

            return PhotoViewGalleryPageOptions(
              imageProvider: MemoryImage(memory!.pictureBytes),
              heroAttributes: PhotoViewHeroAttributes(tag: index),
              maxScale: PhotoViewComputedScale.covered * 3,
              minScale: PhotoViewComputedScale.contained * 0.8,
            );
          },

          // TODO: rotation? only for the time you are touching the display
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
