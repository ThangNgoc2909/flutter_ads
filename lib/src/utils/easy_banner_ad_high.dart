import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';

class EasyBannerAdHigh extends StatefulWidget {
  final AdNetwork adNetwork;
  final AdSize? adSize;
  final String adId;
  final String adIdHigh;
  final bool isCollapsible;
  final Widget? loadingWidget;

  const EasyBannerAdHigh({
    this.adNetwork = AdNetwork.admob,
    this.adSize,
    required this.adId,
    this.isCollapsible = false,
    Key? key,
    this.loadingWidget,
    required this.adIdHigh,
  }) : super(key: key);

  @override
  State<EasyBannerAdHigh> createState() => _EasyBannerAdHighState();
}

class _EasyBannerAdHighState extends State<EasyBannerAdHigh>
    with WidgetsBindingObserver {
  EasyAdBase? _ad;
  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _initAd();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!(EasyAds.instance.appLifecycleReactor?.isExcludeScreen ?? false)) {
      if (!EasyAds.instance.isFullscreenAdShowing) {
        if (state == AppLifecycleState.paused && widget.isCollapsible) {
          _ad?.dispose();
          _ad = null;
          adSize = null;
        }
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isCollapsible) {
      return _ad?.show() ?? _buildLoading();
    }
    return StreamBuilder<bool>(
      initialData: true,
      stream: CollapseBannerAdStream.instance.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!) {
            _initAd();
            return _ad?.show() ?? _buildLoading();
          }
        }
        _ad?.dispose();
        _ad = null;
        adSize = null;
        return _buildLoading();
      },
    );
  }

  SizedBox _buildLoading() {
    return SizedBox(
      child: EasyAds.instance.hasInternet ? widget.loadingWidget : null,
    );
  }

  AdSize? adSize;

  Future<void> _initAd([String? adId]) async {
    if (adSize != null || !EasyAds.instance.hasInternet) {
      return;
    }
    if (widget.adSize != null) {
      adSize = widget.adSize!;
    } else {
      adSize = EasyAds.instance.adSize;
    }

    final bannerAd = EasyAds.instance.createBanner(
      adNetwork: widget.adNetwork,
      adSize: adSize,
      adId: adId ?? widget.adIdHigh,
      isCollapsible: widget.isCollapsible,
      loadingWidget: widget.loadingWidget,
    );

    bannerAd?.onAdFailedToLoad = (adNetwork, adUnitType, data, errorMessage) {
      adSize = null;
      _initAd(widget.adId);
    };
    bannerAd?.onAdLoaded = (adNetwork, adUnitType, data) {
      _ad = bannerAd;
      _initSubscription();
      if (mounted) {
        setState(() {});
      }
    };
    bannerAd?.load();
  }

  void _initSubscription() {
    _streamSubscription = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitType == AdUnitType.banner) {
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _ad?.dispose();
    _streamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
