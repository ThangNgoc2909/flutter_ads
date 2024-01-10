import 'dart:io';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';

import 'widgets/indicator.dart';

part 'widgets/action_row.dart';

part 'widgets/onboarding_carousel.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({
    super.key,
  });

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();

  final ValueNotifier<int> valueNotifier = ValueNotifier(0);
  final adId = Platform.isAndroid
      ? "ca-app-pub-3940256099942544/2247696110"
      : "ca-app-pub-3940256099942544/3986624511";
  final adId2 = Platform.isAndroid
      ? "ca-app-pub-3940256099942544/1044960115"
      : "ca-app-pub-3940256099942544/3986624511";

  late final controller1 = NativeAdController(
    adId: adId,
    highId: adId2,
    factoryId: 'Native_Common',
  );
  late final controller2 = NativeAdController(
    adId: adId,
    highId: adId2,
    factoryId: 'Native_Common',
  );
  late final controller3 = NativeAdController(
    adId: adId,
    highId: adId2,
    factoryId: 'Native_Common',
  );

  @override
  void initState() {
    controller1.load();
    controller2.load();
    controller3.load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: valueNotifier,
          builder: (context, value, child) {
            return const SizedBox.shrink();
            // return switch (value) {
            //   0 => _buildAd(controller1),
            //   1 => _buildAd(controller2),
            //   _ => _buildAd(controller3),
            // };
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: OnboardingCarousel(
                pageController: _pageController,
                valueNotifier: valueNotifier,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ValueListenableBuilder(
                valueListenable: valueNotifier,
                builder: (context, value, child) => ActionRow(
                  pageController: _pageController,
                  valueNotifier: valueNotifier,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAd(NativeAdController controller) {
    return EasyNativeAd(
      controller: controller,
      height: 272,
    );
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
