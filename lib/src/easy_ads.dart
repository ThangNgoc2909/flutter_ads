import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:easy_ads_flutter/src/easy_admob/easy_admob_interstitial_ad.dart';
import 'package:easy_ads_flutter/src/easy_admob/easy_admob_rewarded_ad.dart';
import 'package:easy_ads_flutter/src/utils/easy_event_controller.dart';
import 'package:easy_ads_flutter/src/utils/easy_logger.dart';
import 'package:easy_ads_flutter/src/utils/easy_reward_ad.dart';
import 'package:easy_ads_flutter/src/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'easy_admob/easy_admob_native_ad.dart';
import 'utils/easy_app_open_ad.dart';

class EasyAds {
  EasyAds._easyAds();

  static const maxRetry = 3;

  static final EasyAds instance = EasyAds._easyAds();

  AppLifecycleReactor? appLifecycleReactor;

  /// Google admob's ad request
  AdRequest _adRequest = const AdRequest();

  AdRequest get adRequest => _adRequest;
  late final IAdIdManager adIdManager;

  /// True value when there is exist an Ad and false otherwise.
  bool _isFullscreenAdShowing = false;

  void setFullscreenAdShowing(bool value) => _isFullscreenAdShowing = value;

  bool get isFullscreenAdShowing => _isFullscreenAdShowing;

  final _eventController = EasyEventController();

  Stream<AdEvent> get onEvent => _eventController.onEvent;

  List<EasyAdBase> get _allAds => [..._interstitialAds, ..._rewardedAds];

  /// All the interstitial ads will be stored in it
  final List<EasyAdBase> _appOpenAds = [];

  /// All the interstitial ads will be stored in it
  final List<EasyAdBase> _interstitialAds = [];

  /// All the rewarded ads will be stored in it
  final List<EasyAdBase> _rewardedAds = [];

  /// [_logger] is used to show Ad logs in the console
  final EasyLogger _logger = EasyLogger();
  AdSize? adSize;

  bool hasInternet = true;

  /// Initializes the Google Mobile Ads SDK.
  ///
  /// Call this method as early as possible after the app launches
  /// [adMobAdRequest] will be used in all the admob requests. By default empty request will be used if nothing passed here.
  /// [fbTestingId] can be obtained by running the app once without the testingId.
  Future<void> initialize(
    IAdIdManager manager,
    Image appIconImage, {
    bool unityTestMode = false,
    AdRequest? adMobAdRequest,
    RequestConfiguration? admobConfiguration,
    bool enableLogger = true,
    String? fbTestingId,
    bool fbiOSAdvertiserTrackingEnabled = false,
    int appOpenAdOrientation = AppOpenAd.orientationPortrait,
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    await _checkingInternet();
    if (enableLogger) _logger.enable(enableLogger);
    adIdManager = manager;
    if (adMobAdRequest != null) {
      _adRequest = adMobAdRequest;
    }

    if (manager.admobAdIds?.appId != null) {
      final response = await MobileAds.instance.initialize();

      final status = response.adapterStatuses.values.firstOrNull?.state;
      if (admobConfiguration != null) {
        await MobileAds.instance.updateRequestConfiguration(admobConfiguration);
      }

      _eventController.fireNetworkInitializedEvent(
          AdNetwork.admob, status == AdapterInitializationState.ready);
      if (navigatorKey != null) {
        appLifecycleReactor = AppLifecycleReactor(
            navigatorKey: navigatorKey, appIconImage: appIconImage);
        appLifecycleReactor!.listenToAppStateChanges();
      }

      if (navigatorKey?.currentContext != null) {
        adSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(navigatorKey!.currentContext!).size.width.round());
        print(adSize);
      }
    }
  }

  Future<void> _checkingInternet() async {
    hasInternet = await InternetConnectionChecker().hasConnection;
    InternetConnectionChecker().onStatusChange.listen((status) {
      hasInternet = status == InternetConnectionStatus.connected;
    });
  }

  /// Returns [EasyAdBase] if ad is created successfully. It assumes that you have already assigned banner id in Ad Id Manager
  ///
  /// if [adNetwork] is provided, only that network's ad would be created. For now, only unity and admob banner is supported
  /// [adSize] is used to provide ad banner size
  EasyAdBase? createBanner({
    required AdNetwork adNetwork,
    required AdSize? adSize,
    required String adId,
    required bool isCollapsible,
    Widget? loadingWidget,
  }) {
    EasyAdBase? ad;

    switch (adNetwork) {
      case AdNetwork.admob:
        ad = EasyAdmobBannerAd(
          adId,
          adSize: adSize,
          loadingWidget: loadingWidget,
          adRequest: isCollapsible
              ? AdRequest(
                  httpTimeoutMillis: _adRequest.httpTimeoutMillis,
                  extras: {'collapsible': 'bottom'},
                )
              : _adRequest,
        );
        _eventController.setupEvents(ad);
        break;
      default:
        ad = null;
    }
    return ad;
  }

  EasyAdBase? createNative({
    required AdNetwork adNetwork,
    required String factoryId,
    required String adId,
    required double height,
    Widget? loadingWidget,
  }) {
    EasyAdBase? ad;
    ad = EasyAdmobNativeAd(adId, factoryId, height,
        adRequest: _adRequest, loadingWidget: loadingWidget);
    _eventController.setupEvents(ad);
    return ad;
  }

  EasyAdBase? createInterstitial({
    required AdNetwork adNetwork,
    required String adId,
    bool immersiveModeEnabled = true,
  }) {
    EasyAdBase? ad;
    ad = EasyAdmobInterstitialAd(adId, _adRequest, immersiveModeEnabled);
    _eventController.setupEvents(ad);
    return ad;
  }

  EasyAdBase? createReward({
    required AdNetwork adNetwork,
    required String adId,
    bool immersiveModeEnabled = true,
  }) {
    EasyAdBase? ad;
    ad = EasyAdmobRewardedAd(adId, _adRequest, immersiveModeEnabled);
    _eventController.setupEvents(ad);
    return ad;
  }

  EasyAdBase? createAppOpenAd({
    required AdNetwork adNetwork,
    required String adId,
    int orientation = AppOpenAd.orientationPortrait,
  }) {
    EasyAdBase? ad;
    ad = EasyAdmobAppOpenAd(adId, _adRequest, orientation);
    _eventController.setupEvents(ad);
    return ad;
  }

  Future<void> initAdmob({
    String? appOpenAdUnitId,
    int appOpenAdOrientation = AppOpenAd.orientationPortrait,
  }) async {
    appLifecycleReactor?.setShouldShow(true);
    if (appOpenAdUnitId != null &&
        _appOpenAds.doesNotContain(AdNetwork.admob, AdUnitType.appOpen)) {
      final appOpenAdManager =
          EasyAdmobAppOpenAd(appOpenAdUnitId, _adRequest, appOpenAdOrientation);
      _appOpenAds.add(appOpenAdManager);
      _eventController.setupEvents(appOpenAdManager);
      // try {
      //   await appOpenAdManager.load();
      //   // ignore: empty_catches
      // } catch (e) {}
    }
  }

  /// Displays random ad network [adUnitType] ad.
  /// It will randomly display one network and if that network's ad is not loaded, it will try second and so on until it exhaust all the network ads.
  /// Returns bool indicating whether ad has been successfully displayed or not
  ///
  /// [adUnitType] should be mentioned here, only interstitial or rewarded should be mentioned here
  bool showRandomAd(AdUnitType adUnitType) {
    assert(
        adUnitType == AdUnitType.interstitial ||
            adUnitType == AdUnitType.rewarded,
        'Only interstitial and rewarded types should be passed to this method');

    final List<EasyAdBase> ads = (adUnitType == AdUnitType.rewarded
            ? _rewardedAds
            : _interstitialAds)
        .toList(growable: false)
      ..shuffle();

    for (final ad in ads) {
      if (ad.isAdLoaded) {
        ad.show();
        return true;
      } else {
        _logger.logInfo(
            '${ad.adNetwork} ${ad.adUnitType} was not loaded, so called loading');
        ad.load();
      }
    }

    return false;
  }

  /// Displays [adUnitType] ad from [adNetwork]. It will check if first ad it found from list is loaded,
  /// it will be displayed if [adNetwork] is not mentioned otherwise it will load the ad.
  ///
  /// Returns bool indicating whether ad has been successfully displayed or not
  ///
  /// [adUnitType] should be mentioned here, only interstitial or rewarded should be mentioned here
  /// if [adNetwork] is provided, only that network's ad would be displayed
  /// if [random] is true, any random loaded ad would be displayed
  Future<bool> showAd(AdUnitType adUnitType,
      {AdNetwork adNetwork = AdNetwork.any, int count = 0}) async {
    if (count == maxRetry) {
      return false;
    }
    List<EasyAdBase> ads = [];
    if (adUnitType == AdUnitType.rewarded) {
      ads = _rewardedAds;
    } else if (adUnitType == AdUnitType.interstitial) {
      ads = _interstitialAds;
    } else if (adUnitType == AdUnitType.appOpen) {
      ads = _appOpenAds;
    }
    for (final ad in ads) {
      if (ad.isAdLoaded) {
        if (adNetwork == AdNetwork.any || adNetwork == ad.adNetwork) {
          ad.show();
          return true;
        }
      } else {
        _logger.logInfo(
            '${ad.adNetwork} ${ad.adUnitType} was not loaded, so called loading');
        await ad.load();
      }
    }
    await Future.delayed(const Duration(seconds: 1));
    //Retry show ad
    return showAd(adUnitType, adNetwork: adNetwork, count: count + 1);
  }

  /// This will load both rewarded and interstitial ads.
  /// If a particular ad is already loaded, it will not load it again.
  /// Also you do not have to call this method everytime. Ad is automatically loaded after being displayed.
  ///
  /// if [adNetwork] is provided, only that network's ad would be loaded
  void loadAd({AdNetwork adNetwork = AdNetwork.any}) {
    for (final e in _rewardedAds) {
      if (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) {
        e.load();
      }
    }

    for (final e in _interstitialAds) {
      if (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) {
        e.load();
      }
    }
  }

  /// Returns bool indicating whether ad has been loaded
  ///
  /// if [adNetwork] is provided, only that network's ad would be checked
  bool isRewardedAdLoaded({AdNetwork adNetwork = AdNetwork.any}) {
    final ad = _rewardedAds.firstWhereOrNull((e) =>
        (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) &&
        e.isAdLoaded);
    return ad?.isAdLoaded ?? false;
  }

  /// Returns bool indicating whether ad has been loaded
  ///
  /// if [adNetwork] is provided, only that network's ad would be checked
  bool isInterstitialAdLoaded({AdNetwork adNetwork = AdNetwork.any}) {
    final ad = _interstitialAds.firstWhereOrNull((e) =>
        (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) &&
        e.isAdLoaded);
    return ad?.isAdLoaded ?? false;
  }

  /// Returns bool indicating whether ad has been loaded
  ///
  /// if [adNetwork] is provided, only that network's ad would be checked
  bool isAppOpenAdLoaded({AdNetwork adNetwork = AdNetwork.any}) {
    final ad = _appOpenAds.firstWhereOrNull((e) =>
        (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) &&
        e.isAdLoaded);
    return ad?.isAdLoaded ?? false;
  }

  /// This will load app open ads.
  /// If a particular ad is already loaded, it will not load it again.
  /// Also you do not have to call this method everytime. Ad is automatically loaded after being displayed.
  ///
  /// if [adNetwork] is provided, only that network's ad would be loaded
  void loadAppOpenAd({AdNetwork adNetwork = AdNetwork.any}) {
    for (final e in _appOpenAds) {
      if (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) {
        e.load();
      }
    }
  }

  /// Do not call this method until unless you want to remove ads entirely from the app.
  /// Best user case for this method could be removeAds In app purchase.
  ///
  /// After this, ads would stop loading. You would have to call initialize again.
  ///
  /// if [adNetwork] is provided only that network's ads will be disposed otherwise it will be ignored
  /// if [adUnitType] is provided only that ad unit type will be disposed, otherwise it will be ignored
  void destroyAds(
      {AdNetwork adNetwork = AdNetwork.any, AdUnitType? adUnitType}) {
    for (final e in _allAds) {
      if ((adNetwork == AdNetwork.any || adNetwork == e.adNetwork) &&
          (adUnitType == null || adUnitType == e.adUnitType)) {
        e.dispose();
      }
    }
  }

  Future<void> showInterstitialAd(
    BuildContext context, {
    AdNetwork adNetwork = AdNetwork.admob,
    required String adId,
    Function()? onShowed,
    Function()? adDissmissed,
    Function()? onFailed,
    Function()? onNoInternet,
  }) async {
    if (_isFullscreenAdShowing) {
      return;
    }
    if (!hasInternet) {
      onNoInternet?.call();
      return;
    }

    if (context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EasyInterstitialAd(
            adNetwork: adNetwork,
            adId: adId,
            onShowed: onShowed,
            onFailed: onFailed,
            adDismissed: adDissmissed,
          ),
          fullscreenDialog: true,
        ),
      );
    }
  }

  Future<void> showSplashInterstitialAd(
    BuildContext context, {
    AdNetwork adNetwork = AdNetwork.admob,
    required String adId,
    Function()? onShowed,
    Function()? adDissmissed,
    Function()? onFailed,
    Function()? onNoInternet,
  }) async {
    if (_isFullscreenAdShowing) {
      return;
    }
    if (!hasInternet) {
      onNoInternet?.call();
      return;
    }

    late final EasyAdBase? interstitialAd = EasyAds.instance.createInterstitial(
      adNetwork: AdNetwork.admob,
      adId: adId,
    );

    interstitialAd?.load();

    interstitialAd?.onAdLoaded = (adNetwork, adUnitType, data) {
      interstitialAd.show();
    };
    interstitialAd?.onAdShowed =
        (adNetwork, adUnitType, data) => onShowed?.call();

    interstitialAd?.onAdFailedToLoad =
        (adNetwork, adUnitType, data, errorMessage) => onFailed?.call();
    interstitialAd?.onAdFailedToShow =
        (adNetwork, adUnitType, data, errorMessage) => onFailed?.call();

    interstitialAd?.onAdDismissed =
        (adNetwork, adUnitType, data) => adDissmissed?.call();
  }

  void showRewardAd(
    BuildContext context, {
    AdNetwork adNetwork = AdNetwork.admob,
    required String adId,
    Function()? onShowed,
    Function()? adDissmissed,
    Function()? onFailed,
  }) {
    if (_isFullscreenAdShowing) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EasyRewardAd(
          adNetwork: adNetwork,
          adId: adId,
          onShowed: onShowed,
          onFailed: onFailed,
          adDismissed: adDissmissed,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void showAppOpenAd(
    BuildContext context,
    Image appIconImage, {
    AdNetwork adNetwork = AdNetwork.admob,
    Function()? callback,
  }) {
    if (_isFullscreenAdShowing || !EasyAds.instance.hasInternet) {
      return;
    }
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            pageBuilder: (context, _, __) => EasyAppOpenAd(
              adNetwork: adNetwork,
              appIconImage: appIconImage,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            fullscreenDialog: true,
          ),
        )
        .then((value) => callback?.call());
  }

  void disposeCollapsibleBannerAd() => CollapseBannerAdStream.instance.hide();

  void initCollapsibleBannerAd() => CollapseBannerAdStream.instance.show();
}
