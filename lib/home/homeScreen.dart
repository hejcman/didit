import 'dart:io';

import 'package:didit/camera/AWCamera.dart';
import 'package:didit/common/platformization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Globals
import '../globals.dart' as globals;

// Camera
import '../camera/camera.dart';

// Storage
import '../storage/adapters.dart';
import '../storage/schema.dart';

// Photo detail
import '../grid_gallery_screen/grid_gallery_screen.dart';
import '../photo_detail/photo_detail.dart';

// Settings
import 'package:didit/home/homeScreenDrawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: const CaptureButton(),
        drawer: const HomeScreenDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: Image.asset("assets/logo/didit_logo_light.png", height: 35),
        ),
        body: SafeArea(
            child: ValueListenableBuilder(
                valueListenable: globals.box.listenable(),
                builder: (BuildContext context, Box<Memory> box, _) {
                  final isForeground = TickerMode.of(context);
                  if (!isForeground || box.isEmpty) {
                    return const Center(child: Text("No images to show."));
                  }

                  deleteOutdatedMemories();
                  const List<LifetimeTag> categories = LifetimeTag.values;
                  return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: categories.length,
                      itemBuilder: (BuildContext context, int index) {
                        final List<Memory> memories;
                        if (Platform.isIOS) {
                          memories =
                              getMemories(categories[index], reversed: false);
                        } else {
                          memories = getMemories(categories[index]);
                        }
                        return OneCategory(
                          tag: categories[index],
                          memories: memories,
                          box: box,
                        );
                      });
                })));
  }
}

class CaptureButton extends StatelessWidget {
  const CaptureButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CameraScreen()));
        //await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CameraPage())); //FIXME:
      },
      label: const Text('Capture'),
      icon: Icon(getCameraIcon()),
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
              children: <Widget>[
                const Text("all"),
                Icon(getArrowForwardIcon(), size: 15),
              ],
            ),
          )
        ],
      ),
      SizedBox(
        height: 200,
        child: GridView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: memories!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemBuilder: (BuildContext context, index) {
              Memory memory = memories![index];
              return CustomPhotoTile(
                  memory: memory, memories: memories, index: index);
            }),
      )
    ]);
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
