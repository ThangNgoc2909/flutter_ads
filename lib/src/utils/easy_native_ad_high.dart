import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:easy_ads_flutter/src/utils/easy_logger.dart';
import 'package:flutter/material.dart';

class EasyNativeAdHigh extends StatefulWidget {
  final AdNetwork adNetwork;
  final String factoryId;
  final String adId;
  final String adIdHigh;
  final double height;
  final Widget? loadingWidget;

  const EasyNativeAdHigh({
    this.adNetwork = AdNetwork.admob,
    required this.factoryId,
    required this.adId,
    required this.adIdHigh,
    required this.height,
    this.loadingWidget,
    super.key,
  });

  @override
  State<EasyNativeAdHigh> createState() => _EasyNativeAdHighState();
}

class _EasyNativeAdHighState extends State<EasyNativeAdHigh> {
  EasyAdBase? _ad;

  @override
  void initState() {
    super.initState();
    initHighAd();
  }

  void initHighAd() async {
    if (!EasyAds.instance.hasInternet) {
      return;
    }

    final EasyAdBase? nativeAdHigh = EasyAds.instance.createNative(
      adNetwork: widget.adNetwork,
      factoryId: widget.factoryId,
      adId: widget.adIdHigh,
      height: widget.height,
      loadingWidget: widget.loadingWidget,
    );

    nativeAdHigh?.onAdFailedToLoad =
        (adNetwork, adUnitType, data, errorMessage) => initNormalAd();

    nativeAdHigh?.onAdLoaded = (adNetwork, adUnitType, data) {
      _ad = nativeAdHigh;
      EasyLogger().logInfo('Load native high success');
      if (mounted) {
        setState(() {});
      }
    };

    nativeAdHigh?.load();
  }

  void initNormalAd() {
    final EasyAdBase? nativeAd = EasyAds.instance.createNative(
      adNetwork: widget.adNetwork,
      factoryId: widget.factoryId,
      adId: widget.adId,
      height: widget.height,
      loadingWidget: widget.loadingWidget,
    );

    nativeAd?.onAdFailedToLoad = (adNetwork, adUnitType, data, errorMessage) {
      EasyLogger().logInfo('Load native ad failed');
      if (mounted) {
        setState(() {});
      }
    };

    nativeAd?.onAdLoaded = (adNetwork, adUnitType, data) {
      _ad = nativeAd;
      EasyLogger().logInfo('Load native success');
      if (mounted) {
        setState(() {});
      }
    };

    nativeAd?.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ad?.show() ??
        SizedBox(
          child: EasyAds.instance.hasInternet ? widget.loadingWidget : null,
        );
  }
}
