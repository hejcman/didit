import 'package:didit/home/HomeScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'memories.dart';

void main() => runApp(const CupertinoTabBarApp());

class CupertinoTabBarApp extends StatelessWidget {
  const CupertinoTabBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: CupertinoTabBarExample(),
    );
  }
}

class CupertinoTabBarExample extends StatelessWidget {
  const CupertinoTabBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeScreen();
    // CupertinoTabScaffold(
    //   tabBar: CupertinoTabBar(
    //     items: const <BottomNavigationBarItem>[
    //       BottomNavigationBarItem(
    //         icon: Icon(CupertinoIcons.collections),
    //         label: 'Memories',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(CupertinoIcons.list_number),
    //         label: 'Lists',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(CupertinoIcons.camera_fill),
    //         label: 'Create',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(CupertinoIcons.tag),
    //         label: 'Tags',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(CupertinoIcons.settings),
    //         label: 'Settings'
    //       )
    //     ],
    //   ),
    //   tabBuilder: (BuildContext context, int index) {
    //     switch (index) {
    //       case 0:
    //         return const MemoriesPage();
    //       default:
    //         break;
    //     }
    //     return CupertinoTabView(
    //       builder: (BuildContext context) {
    //         return Center(
    //           child: Text('Content of tab $index'),
    //         );
    //       },
    //     );
    //   },
    // );
  }
}
