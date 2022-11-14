import 'dart:typed_data';
import 'package:didit/camera/camera.dart';
import 'package:didit/storage/adapters.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../storage/schema.dart';

import '../globals.dart';

import '../storage/schema.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Color> flagColors = [Colors.deepPurple.shade300, Colors.deepPurple.shade500,Colors.deepPurple.shade700, Colors.deepPurple.shade800];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                final List<LifetimeTag> categories = lifetimeTags.keys.toList();
                lifetimeTags.values.toList();
                return ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: categories.length,
                    itemBuilder: (BuildContext context, int index) {
                      final memories = getMemories(categories[index]);
                      return OneCategory(
                        categoryName: "${lifetimeTags[categories[index]]}",
                        memories: memories,
                        flagColor: flagColors[index],
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
  final String categoryName;
  final List<Memory>? memories;
  Color flagColor;

  OneCategory({super.key, required this.categoryName, this.memories, this.flagColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    if (memories == null) {
      return Text("error");
    }

    return Column(children: [
      Row(
        children: [
          Icon(
            Icons.flag,
            color: flagColor,
          ),
          Text(categoryName)
        ],
      ),
      Container(
        height: 200,
        child: GridView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: memories?.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemBuilder: (BuildContext context, index) {
              Memory memory = memories![index];

              return CustomPhotoTile(memory: memory);
            }),
      )
    ]);
  }
}

class CustomPhotoTile extends StatelessWidget {
  CustomPhotoTile({super.key, required this.memory});

  Memory memory;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
        width: 100,
        height: 100,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.memory(
              memory.pictureBytes,
              fit: BoxFit.fill,
            )));
  }
}
