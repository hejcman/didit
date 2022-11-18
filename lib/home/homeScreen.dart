import 'dart:typed_data';
import 'package:didit/camera/camera.dart';
import 'package:didit/storage/adapters.dart';
import 'package:didit/grid_gallery_screen/gridGalleryScreen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../photo_detail/photo_detail.dart';
import '../storage/schema.dart';

import '../globals.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Image.asset(
          "assets/logo/didit_logo_light.png",
          height: 35,
        ),
      ),
      body: SafeArea(
          child: FutureBuilder(
        future: Hive.openBox<Memory>(Globals.dbName),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }
          return ValueListenableBuilder(
              valueListenable: Hive.box<Memory>(Globals.dbName).listenable(),
              builder: (BuildContext context, Box<Memory> box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text("No images to show."));
                }

                deleteOutdatedMemories();
                final List<LifetimeTag> categories = LifetimeTag.values;
                return ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: categories.length,
                    itemBuilder: (BuildContext context, int index) {
                      final memories = getMemories(categories[index]);
                      return OneCategory(
                        tag: categories[index],
                        memories: memories,
                        box: box,
                      );
                    });
              });
        },
      )),
      floatingActionButton: CaptureButton(),
    );
  }
}

class CaptureButton extends StatelessWidget {
  CaptureButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CameraScreen()));
      },
      label: const Text('Capture'),
      icon: const Icon(Icons.camera_alt),
    );
  }
}

class OneCategory extends StatelessWidget {
  final LifetimeTag tag;
  final List<Memory> memories;
  final Box<Memory> box;

  OneCategory(
      {super.key,
      required this.tag,
      required this.memories,
      required this.box});

  @override
  Widget build(BuildContext context) {
    if (memories == null) {
      return Text("error");
    }

    return Column(children: [
      Row(
        children: [
          tag.iconWidget(textColor: Theme.of(context).colorScheme.onBackground),
          const Spacer(),
          TextButton(
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => GridGalleryScreen(
                        box: box,
                        tag: tag,
                      )));
            },
            child: Row(
              children: [
                Text(
                  "all",
                ),
                Icon(Icons.arrow_forward, size: 15),
              ],
            ),
          )
        ],
      ),
      Container(
        height: 200,
        child: GridView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: memories!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemBuilder: (BuildContext context, index) {
              Memory memory = memories![index];
              return CustomPhotoTile(
                  memory: memory, box: box, memories: memories, index: index);
            }),
      )
    ]);
  }
}

class CustomPhotoTile extends StatelessWidget {
  CustomPhotoTile(
      {super.key,
      required this.memory,
      required this.box,
      required this.memories,
      required this.index});

  Memory memory;
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
