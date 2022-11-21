import 'dart:async';

import 'package:didit/common/platformization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globals.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  late PageController _pageController;
  int _pageIndex = 0;
  bool _lastPage = false;

  Future<void> changeFirstVisit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Settings.showOnboarding.key, false);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: onBoardingSlidesData.length,
                  controller: _pageController,
                  onPageChanged: changePageIndex,
                  itemBuilder: (context, index) => OnBoardingSlide(
                    lottie: onBoardingSlidesData[index].lottie,
                    title: onBoardingSlidesData[index].title,
                    description: onBoardingSlidesData[index].description,
                  ),
                ),
              ),
              Row(
                children: [
                  ...List.generate(
                      onBoardingSlidesData.length,
                      (index) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: DotIndicator(
                              isActive: index == _pageIndex,
                            ),
                          )),
                  const Spacer(),
                  SizedBox(
                      height: 60,
                      width: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          nextPageButtonPress();
                        },
                        // style: ElevatedButton.styleFrom(shape: const CircleBorder()),
                        style: ButtonStyle(
                          //backgroundColor: MaterialStateProperty.all<Color?>(Colors.teal[700]),
                          shape: MaterialStateProperty.all<CircleBorder?>(const CircleBorder()),
                        ),
                        child: Icon(_lastPage ? getCameraIcon() : getArrowForwardIcon()),
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void nextPageButtonPress() {
    if (_lastPage) {
      changeFirstVisit();

      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      return;
    }
    _pageController.nextPage(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 300),
    );
  }

  void changePageIndex(index) {
    setState(() {
      _pageIndex = index;
      _lastPage = index == onBoardingSlidesData.length - 1;
    });
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    Key? key,
    this.isActive = false,
  }) : super(key: key);

  final bool isActive;
  final int sizeSmall = 8;
  final int sizeActive = 16;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isActive ? sizeActive.toDouble() : sizeSmall.toDouble(),
      width: isActive ? sizeActive.toDouble() : sizeSmall.toDouble(),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}

class Onboard {
  final String lottie, title, description;

  Onboard({required this.lottie, required this.title, required this.description});
}

final List<OnBoardingSlide> onBoardingSlidesData = [
  const OnBoardingSlide(
    lottie: 'assets/lottie/take-a-photo.json',
    title: "Capture images of things you often forget about",
    description: "Did I turn my stove off ?! We've all been there"
        "...just take a picture and have a solid proof for your future self!",
  ),
  const OnBoardingSlide(
    lottie: 'assets/lottie/time.json',
    title: "How long to store those temporary photos?",
    description: "You can select 1 day, a week or whole month. "
        "It's just up to you.",
  ),
  const OnBoardingSlide(
    lottie: 'assets/lottie/trash.json',
    title: "After set expiration, expired photos will get deleted automatically!",
    description: "So you don't need to worry about storage space anymore. "
        "You can store your photos prior to the expiration.",
  ),
  const OnBoardingSlide(
    lottie: 'assets/lottie/lets-begin.json',
    title: "Lets begin using the App!",
    description: "Are you ready? I am.",
  ),
];

class OnBoardingSlide extends StatelessWidget {
  const OnBoardingSlide({
    Key? key,
    required this.lottie,
    required this.title,
    required this.description,
  }) : super(key: key);

  final String lottie, title, description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        /*if (!kDebugMode) ...[
          Lottie.asset(lottie),
        ],*/
        Lottie.asset(lottie),
        const Spacer(),
        Text(
          title,
          textAlign: TextAlign.center,
          // style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.w500),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 24),
        Text(description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 20.0,
            )),
        const Spacer(),
      ],
    );
  }
}
