import 'package:easy_ads_flutter/src/enums/ad_network.dart';
import 'package:easy_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class EasyAdBase {
  final String adUnitId;

  /// This will be called for initialization when we don't have to wait for the initialization
  EasyAdBase(this.adUnitId);

  AdNetwork get adNetwork;

  AdUnitType get adUnitType;

  bool get isAdLoaded;

  bool get isAdLoading;

  bool get isAdLoadedFailed;

  void dispose();

  /// This will load ad, It will only load the ad if isAdLoaded is false
  Future<void> load();

  dynamic show();

  EasyAdCallback? onAdLoading;
  EasyAdCallback? onAdLoaded;
  EasyAdCallback? onAdShowed;
  EasyAdCallback? onAdClicked;
  EasyAdFailedCallback? onAdFailedToLoad;
  EasyAdFailedCallback? onAdFailedToShow;
  EasyAdCallback? onAdDismissed;
  EasyAdEarnedReward? onEarnedReward;
  EasyAdOnPaidEvent? onPaidEvent;
}

typedef EasyAdNetworkInitialized = void Function(
    AdNetwork adNetwork, bool isInitialized, Object? data);
typedef EasyAdFailedCallback = void Function(AdNetwork adNetwork,
    AdUnitType adUnitType, Object? data, String errorMessage);
typedef EasyAdCallback = void Function(
    AdNetwork adNetwork, AdUnitType adUnitType, Object? data);
typedef EasyAdEarnedReward = void Function(AdNetwork adNetwork,
    AdUnitType adUnitType, String? rewardType, num? rewardAmount);

typedef EasyAdOnPaidEvent = void Function(
  AdNetwork adNetwork,
  AdUnitType adUnitType,
  Ad ad,
  double valueMicros,
  PrecisionType precision,
  String currencyCode,
);
