import 'dart:async';
import 'dart:io';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';

class EasyAppOpenAd extends StatefulWidget {
  final AdNetwork adNetwork;
  final Image appIconImage;
  const EasyAppOpenAd({
    super.key,
    this.adNetwork = AdNetwork.admob,
    required this.appIconImage,
  });

  @override
  State<EasyAppOpenAd> createState() => _EasyAppOpenAdState();
}

class _EasyAppOpenAdState extends State<EasyAppOpenAd>
    with WidgetsBindingObserver {
  StreamSubscription? _streamSubscription;
  bool shownAd = false;

  Future<void> _showAd() => Future.delayed(
        const Duration(seconds: 1),
        () async {
          if (_appLifecycleState == AppLifecycleState.resumed) {
            if (mounted) {
              final result = await EasyAds.instance.showAd(AdUnitType.appOpen);
              if (result == false) {
                removeLoading();
              }
            }
          } else {
            _adFailedToShow = true;
          }
        },
      );

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    EasyAds.instance.setFullscreenAdShowing(true);
    EasyAds.instance.loadAppOpenAd();
    _showAd();
    _streamSubscription = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitType == AdUnitType.appOpen) {
        switch (event.type) {
          case AdEventType.adShowed:
            setState(() {
              shownAd = true;
            });
            break;
          case AdEventType.adFailedToLoad:
            removeLoading();
            break;
          case AdEventType.adDismissed:
            removeLoading();
            break;
          case AdEventType.adFailedToShow:
            if (_appLifecycleState != AppLifecycleState.resumed) {
              _adFailedToShow = true;
            }
            break;
          default:
            break;
        }
      }
    });
    super.initState();
  }

  void removeLoading() {
    EasyAds.instance.setFullscreenAdShowing(false);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  bool _adFailedToShow = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    if (state == AppLifecycleState.resumed && _adFailedToShow) {
      _showAd();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: shownAd
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _iconView(),
                ],
              ),
      ),
    );
  }

  Widget _iconView() {
    if (Platform.isAndroid) {
      return const Text(
        'Welcome back',
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: widget.appIconImage,
      );
    }
  }
}
