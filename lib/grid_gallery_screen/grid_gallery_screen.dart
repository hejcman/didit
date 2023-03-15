import 'dart:io';

import 'package:didit/common/tagWidget.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Globals
import '../globals.dart' as globals;

// Storage
import '../storage/adapters.dart';
import '../storage/schema.dart';

// Photo detail
import '../photo_detail/photo_detail.dart';

// Platformization
import '../common/platformization.dart';

//Localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GridGalleryScreen extends StatefulWidget {
  const GridGalleryScreen({super.key, required this.box, required this.tag});

  final Box<Memory> box;
  final LifetimeTag tag;

  @override
  State<GridGalleryScreen> createState() => _GridGalleryScreenState();
}

class _GridGalleryScreenState extends State<GridGalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(getBackArrowIcon()),
            onPressed: () async {
              Navigator.pop(context);
            }),
        title: tagWidget(tag: widget.tag),
      ),
      body: ValueListenableBuilder(
          valueListenable: globals.box.listenable(),
          builder: (BuildContext context, Box<Memory> box, _) {
            final List<Memory> memories;
            if (Platform.isIOS) {
              memories = getMemories(widget.tag, reversed: false);
            } else {
              memories = getMemories(widget.tag);
            }

            if (box.isEmpty || memories.isEmpty) {
              return Center(
                  child: Text(AppLocalizations.of(context)!.no_images));
            }

            return GridView.builder(
                scrollDirection: Axis.vertical,
                itemCount: memories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4),
                itemBuilder: (BuildContext context, index) {
                  Memory memory = memories[index];
                  return CustomPhotoTile(
                      memory: memory, memories: memories, index: index);
                });
          }),
    );
  }
}

class CustomPhotoTile extends StatelessWidget {
  const CustomPhotoTile(
      {super.key,
      required this.memory,
      required this.memories,
      required this.index});

  final Memory memory;
  final List<Memory> memories;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PhotoDetail(
                  index: index, memories: [for (final m in memories) m.key])));
        },
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.memory(
                  memory.pictureBytes,
                  fit: BoxFit.cover,
                ))));
  }
}
