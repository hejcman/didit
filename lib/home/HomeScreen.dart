import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<int> categories = [1,7, 30];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child:

      ListView.builder(
          itemCount: categories.length,
          itemBuilder: (BuildContext context, int index) {
            return OneCategory(categoryName: "${categories[index]} ${categories[index] == 1 ? "day": "days"}");
          })),
      floatingActionButton: CaptureButton(),
    );
  }
}

class CaptureButton extends StatelessWidget {
  CaptureButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        // Add your onPressed code here!
      },
      label: const Text('Capture'),
      icon: const Icon(Icons.camera_alt),
      backgroundColor: Colors.blue,
    );
  }
}

class OneCategory extends StatelessWidget {
  OneCategory({super.key, required this.categoryName, this.images});

  final String categoryName;
  final List<Image>? images;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [const Icon(Icons.flag), Text(categoryName)],
      ),
      Container(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          itemBuilder: (BuildContext context, int index) {
            return PhotosColumn();
          },
        ),
      )
    ]);
  }
}

class PhotosColumn extends StatelessWidget {
  PhotosColumn({super.key, this.images});
  final List<Image>? images;
  @override
  Widget build(BuildContext context) {
    return Column(children: [MyPhoto(), MyPhoto()]);
  }
}

class MyPhoto extends StatelessWidget {
  MyPhoto({super.key,this.image1, this.image2});
  Image? image1;
  Image? image2;
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        width: 100,
        height: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),

          child: Image.asset(
            "assets/images/1.jpg",
            fit: BoxFit.fill,
          ),
        ));
  }
}
