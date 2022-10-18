import 'dart:typed_data';

import 'package:didit/storage/adapters.dart';
import 'package:didit/storage/schema.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:photo_view/photo_view.dart';

import 'globals.dart';

class PhotoDetail extends StatefulWidget {
  final Uint8List photo;

  PhotoDetail({Key? key, required this.photo}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PhotoDetailState();
}

class GetPhotoIndex {}

class PhotoDetailState extends State<PhotoDetail> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoView(
      imageProvider: MemoryImage(widget.photo),
      maxScale: PhotoViewComputedScale.contained * 4,
      minScale: PhotoViewComputedScale.contained * 0.8,
    ));
  }
}
