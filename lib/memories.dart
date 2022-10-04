import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MemoriesPage extends StatelessWidget {
  const MemoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Memories")
      ),
      child: GridView.count(
        primary: false,
        // padding: const EdgeInsets.all(20),
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        crossAxisCount: 2,
        children: const <Widget>[
          Memory(image: Image(image: AssetImage('assets/images/1.jpg'))),
          Memory(image: Image(image: AssetImage('assets/images/2.jpg'))),
          Memory(image: Image(image: AssetImage('assets/images/3.jpg'))),
          Memory(image: Image(image: AssetImage('assets/images/4.jpg'))),
          Memory(image: Image(image: AssetImage('assets/images/5.jpg'))),
          Memory(image: Image(image: AssetImage('assets/images/6.jpg'))),
          Memory(image: Image(image: AssetImage('assets/images/7.jpg'))),
          Memory(image: Image(image: AssetImage('assets/images/8.jpg'))),
        ],
      )
    );
  }
}


class Memory extends StatelessWidget {
  final Image image;

  const Memory({super.key, required this.image});

  @override
  Widget build(BuildContext context) {

    Color background, foreground;
    double lifeLeft = Random().nextDouble();

    if (lifeLeft < 0.2) {
      foreground = Colors.red;
      background = Colors.red.shade100;
    } else if (lifeLeft < 0.8) {
      foreground = Colors.yellow;
      background = Colors.yellow.shade100;
    } else {
      foreground = Colors.green;
      background = Colors.green.shade100;
    }

    return Stack(
      children: [
        Center(child: image),
        const Align(
          alignment: Alignment.topRight,
          child: Icon(
            CupertinoIcons.tag_solid,
            color: Colors.grey
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: LinearProgressIndicator(
            value: lifeLeft,
            backgroundColor: background,
            color: foreground
          ),
        )
      ],
    );
  }
}

