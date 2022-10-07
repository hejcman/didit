
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Camera
import 'camera/camera.dart';

// Storage
import 'storage/schema.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  GalleryScreenState createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen> {

  late Box<Memory> memoryBox;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display the Picture'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const CameraScreen()
                )
              );
            },
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Memory>("memories").listenable(),
        builder: (BuildContext context, Box<Memory> box, _) {
          // If there are no images, return info text.
          if (box.values.isEmpty) {
             return const Center(child: Text("No images to show."));
          }
          return GridView.builder(
            itemCount: box.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2
            ),
            itemBuilder: (BuildContext context, index) {
              Memory memory = box.getAt(index) as Memory;
              return Image.memory(memory.pictureBytes);
            }
          );
        }
      )
    );
  }
}

