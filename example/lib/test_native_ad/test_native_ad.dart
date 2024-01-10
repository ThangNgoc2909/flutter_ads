import 'dart:io';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'onboarding_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyAds.instance.initialize(
    adIdManager,
    Image.asset('app_icon'),
    unityTestMode: true,
    adMobAdRequest: const AdRequest(httpTimeoutMillis: 30000),
    admobConfiguration: RequestConfiguration(),
    navigatorKey: navigatorKey,
  );
  await EasyAds.instance.initAdmob(
    appOpenAdUnitId: Platform.isAndroid
        ? "ca-app-pub-3940256099942544/3419835294"
        : "ca-app-pub-3940256099942544/5662855259",
  );

  runApp(const MyApp2());
}

class MyApp2 extends StatelessWidget {
  const MyApp2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Easy Ads Example',
      navigatorKey: navigatorKey,
      home: const OnBoardingScreen(),
    );
  }
}
