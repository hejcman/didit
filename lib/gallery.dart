import 'package:didit/photo_detail.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'globals.dart';

// Camera
import 'camera/camera.dart';

// Storage
import 'storage/schema.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Display the Picture'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add_a_photo),
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CameraScreen()));
              },
            )
          ],
        ),
        body: FutureBuilder(
          future: Hive.openBox<Memory>(Globals.dbName),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            // Show loading icon until the box is open
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }
            // Rebuild the gallery on changes in the database
            return ValueListenableBuilder(
                valueListenable: Hive.box<Memory>(Globals.dbName).listenable(),
                builder: (BuildContext context, Box<Memory> box, _) {
                  // If there are no images, return info text.
                  if (box.values.isEmpty) {
                    return const Center(child: Text("No images to show."));
                  }
                  return GridView.builder(
                    itemCount: box.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                    itemBuilder: (BuildContext context, index) {
                      Memory memory = box.getAt(index) as Memory;
                      return InkWell(
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  PhotoDetail(photo: memory.pictureBytes)));
                        },
                        child: Image.memory(memory.pictureBytes),
                      );
                    },
                  );
                });
          },
        ));
  }
}
