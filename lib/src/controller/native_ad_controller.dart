import 'dart:async';

import 'package:easy_ads_flutter/src/controller/ad_controller.dart';

import '../../easy_ads_flutter.dart';
import '../enums/ad_status.dart';

class NativeAdController extends AdController {
  NativeAdController({
    required super.adId,
    required this.factoryId,
    super.highId,
  });

  final String factoryId;

  NativeAd? _nativeAd;
  final String controllerId = DateTime.now().microsecondsSinceEpoch.toString();

  NativeAd? get ad => _nativeAd;

  @override
  Future<void> load([String? id]) async {
    if (status.isLoading ||
        status.isLoaded ||
        status.isShown ||
        !EasyAds.instance.hasInternet) {
      return;
    }
    Completer<void> completer = Completer();
    id ??= highId;
    _nativeAd = NativeAd(
      adUnitId: id ?? adId,
      factoryId: factoryId,
      request: EasyAds.instance.adRequest,
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          _nativeAd = ad as NativeAd?;
          addEvent(AdStatus.loaded);
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) async {
          _nativeAd = null;
          addEvent(AdStatus.loadFailed);
          ad.dispose();
          if (highId != null) {
            await load(adId);
          }
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      ),
    );
    addEvent(AdStatus.loading);
    _nativeAd?.load();
    return completer.future;
  }

  @override
  void reload() {
    disposeAd();
    load();
  }

  void disposeAd() {
    _nativeAd?.dispose();
    addEvent(AdStatus.init);
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }
}
