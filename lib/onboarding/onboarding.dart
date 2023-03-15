import 'dart:async';

import 'package:didit/common/platformization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  List<OnBoardingSlide> onBoardingSlidesData = [];

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
    onBoardingSlidesData = [
      OnBoardingSlide(
        lottie: 'assets/lottie/take-a-photo.json',
        title: AppLocalizations.of(context)!.onboarding_page_1_title,
        description:
            AppLocalizations.of(context)!.onboarding_page_1_description,
      ),
      OnBoardingSlide(
        lottie: 'assets/lottie/time.json',
        title: AppLocalizations.of(context)!.onboarding_page_2_title,
        description:
            AppLocalizations.of(context)!.onboarding_page_2_description,
      ),
      OnBoardingSlide(
        lottie: 'assets/lottie/trash.json',
        title: AppLocalizations.of(context)!.onboarding_page_3_title,
        description:
            AppLocalizations.of(context)!.onboarding_page_3_description,
      ),
      OnBoardingSlide(
        lottie: 'assets/lottie/lets-begin.json',
        title: AppLocalizations.of(context)!.onboarding_page_4_title,
        description:
            AppLocalizations.of(context)!.onboarding_page_4_description,
      ),
    ];

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
                          shape: MaterialStateProperty.all<CircleBorder?>(
                              const CircleBorder()),
                        ),
                        child: Icon(_lastPage
                            ? getCameraIcon()
                            : getArrowForwardIcon()),
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

  Onboard(
      {required this.lottie, required this.title, required this.description});
}

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
            fontSize: 30,
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
