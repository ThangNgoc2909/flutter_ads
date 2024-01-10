import 'dart:async';

import 'package:easy_ads_flutter/src/controller/ad_controller.dart';

import '../../easy_ads_flutter.dart';
import '../enums/ad_status.dart';

class BannerAdController extends AdController {
  BannerAdController({
    required super.adId,
    this.adSize,
    this.isCollapsible = false,
    super.highId,
  });

  final bool isCollapsible;
  AdSize? adSize;
  BannerAd? _bannerAd;
  final String controllerId = DateTime.now().microsecondsSinceEpoch.toString();

  BannerAd? get ad => _bannerAd;

  @override
  Future<void> load([String? id]) async {
    if (status.isLoading ||
        status.isLoaded ||
        status.isShown ||
        !EasyAds.instance.hasInternet) {
      return;
    }
    Completer<void> completer = Completer();
    adSize ??= EasyAds.instance.adSize ?? AdSize.banner;
    id ??= highId;
    _bannerAd = BannerAd(
      size: adSize!,
      adUnitId: id ?? adId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _bannerAd = ad as BannerAd?;
          addEvent(AdStatus.loaded);
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) async {
          _bannerAd = null;
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
      request: isCollapsible
          ? AdRequest(
              httpTimeoutMillis: EasyAds.instance.adRequest.httpTimeoutMillis,
              extras: {'collapsible': 'bottom'},
            )
          : EasyAds.instance.adRequest,
    );
    addEvent(AdStatus.loading);
    _bannerAd?.load();
    return completer.future;
  }

  @override
  void reload() {
    disposeAd();
    load();
  }

  @override
  void dispose() {
    disposeAd();
    super.dispose();
  }

  void disposeAd() {
    _bannerAd?.dispose();
    addEvent(AdStatus.init);
  }

  BannerAdController copyWith({
    bool? isCollapsible,
    AdSize? adSize,
    String? adId,
  }) {
    return BannerAdController(
      isCollapsible: isCollapsible ?? this.isCollapsible,
      adSize: adSize ?? this.adSize,
      adId: adId ?? super.adId,
    );
  }
}
