import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Globals
import '../globals.dart';

// Storage
import '../storage/adapters.dart';
import '../storage/schema.dart';

// Photo detail
import '../photo_detail/photo_detail.dart';

// Platformization
import '../common/platformization.dart';

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
        title: widget.tag
            .iconWidget(textColor: Theme.of(context).colorScheme.onBackground),
      ),
      body: ValueListenableBuilder(
          valueListenable: Hive.box<Memory>(Globals.dbName).listenable(),
          builder: (BuildContext context, Box<Memory> box, _) {
            final List<Memory> memories = getMemories(widget.tag);

            if (box.isEmpty || memories.isEmpty) {
              return const Center(child: Text("No images to show."));
            }

            return GridView.builder(
                scrollDirection: Axis.vertical,
                itemCount: memories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4),
                itemBuilder: (BuildContext context, index) {
                  Memory memory = memories[index];
                  return CustomPhotoTile(
                      memory: memory,
                      box: widget.box,
                      memories: memories,
                      index: index);
                });
          }),
    );
  }
}

class CustomPhotoTile extends StatelessWidget {
  const CustomPhotoTile(
      {super.key,
      required this.memory,
      required this.box,
      required this.memories,
      required this.index});

  final Memory memory;
  final Box<Memory> box;
  final List<Memory> memories;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  PhotoDetail(box: box, index: index, memories: memories)));
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
