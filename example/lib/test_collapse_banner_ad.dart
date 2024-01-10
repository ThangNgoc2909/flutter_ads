import 'dart:io';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'main.dart';

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
        ? "ca-app-pub-3940256099942544/9257395921"
        : "ca-app-pub-3940256099942544/5575463023",
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
      home: const CollapseBannerScreen(),
    );
  }
}

class CollapseBannerScreen extends StatefulWidget {
  const CollapseBannerScreen({super.key});

  @override
  State<CollapseBannerScreen> createState() => _CollapseBannerScreenState();
}

class _CollapseBannerScreenState extends State<CollapseBannerScreen> {
  bool hidden = false;
  final adId = Platform.isAndroid
      ? "ca-app-pub-3940256099942544/2014213617"
      : "ca-app-pub-3940256099942544/2435281174";
  final adId2 = Platform.isAndroid
      ? "ca-app-pub-3940256099942544/9214589741"
      : "ca-app-pub-3940256099942544/2435281174";

  late final controller = BannerAdController(
    adId: adId,
    highId: adId2,
    isCollapsible: true,
  );

  @override
  void initState() {
    controller.load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
                onPressed: () async {
                  setState(() {});
                },
                child: const Text('setState')),
            FilledButton(
                onPressed: () async {
                  controller.reload();
                },
                child: const Text('Reload')),
            FilledButton(
                onPressed: () async {
                  EasyAds.instance.appLifecycleReactor
                      ?.setIsExcludeScreen(true);
                  final XFile? image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                },
                child: const Text('Pick Image')),
            FilledButton(
              onPressed: () async {
                EasyAds.instance.disposeCollapsibleBannerAd();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OtherScreen(),
                    ));
                EasyAds.instance.initCollapsibleBannerAd();
              },
              child: const Text('Next Screen'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: EasyBannerAd(
        controller: controller,
      ),
      // bottomNavigationBar: EasyBannerAdHigh(
      //   adId: adId,
      //   adIdHigh: adId,
      //   isCollapsible: true,
      //   adSize: AdSize(
      //       width: MediaQuery.of(context).size.width.toInt(), height: 50),
      // ),
    );
  }
}

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: FilledButton(
        onPressed: () async {
          EasyAds.instance.disposeCollapsibleBannerAd();
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OtherScreen(),
              ));
          EasyAds.instance.initCollapsibleBannerAd();
        },
        child: const Text('Next Screen'),
      ),
    ));
  }
}

class Other2Screen extends StatelessWidget {
  const Other2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Placeholder());
  }
}
