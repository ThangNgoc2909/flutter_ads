import 'package:easy_ads_flutter/easy_ads_flutter.dart';

class EasyAdmobAppOpenAd extends EasyAdBase {
  final AdRequest _adRequest;
  final int _orientation;

  EasyAdmobAppOpenAd(super.adUnitId, this._adRequest, this._orientation);

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdLoadedFailed = false;

  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  @override
  AdUnitType get adUnitType => AdUnitType.appOpen;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  bool get isAdLoading => _isAdLoading;

  @override
  bool get isAdLoadedFailed => _isAdLoadedFailed;

  @override
  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isAdLoadedFailed = false;
    _isAdLoaded = false;
    _isAdLoading = false;
  }

  @override
  Future<void> load() async {
    if (isAdLoaded || isAdLoading || !EasyAds.instance.hasInternet) return;
    _isAdLoading = true;
    onAdLoading?.call(adNetwork, adUnitType, null);
    return AppOpenAd.load(
      adUnitId: adUnitId,
      request: _adRequest,
      orientation: _orientation,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
          _appOpenAd?.onPaidEvent =
              (ad, valueMicros, precision, currencyCode) => onPaidEvent?.call(
                  adNetwork,
                  adUnitType,
                  ad,
                  valueMicros,
                  precision,
                  currencyCode);
          _isAdLoaded = true;
          _isAdLoading = false;
          _isAdLoadedFailed = false;
          onAdLoaded?.call(adNetwork, adUnitType, ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _appOpenAd = null;
          _isAdLoaded = false;
          _isAdLoading = false;
          _isAdLoadedFailed = true;
          onAdFailedToLoad?.call(
              adNetwork, adUnitType, error, error.toString());
        },
      ),
    );
  }

  @override
  show() async {
    if (!isAdLoaded) {
      await load();
      return;
    }

    if (_isShowingAd) {
      onAdFailedToShow?.call(adNetwork, adUnitType, null,
          'Tried to show ad while already showing an ad.');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (AppOpenAd ad) {
        _isShowingAd = true;

        onAdShowed?.call(adNetwork, adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        _isShowingAd = false;

        onAdDismissed?.call(adNetwork, adUnitType, ad);
        ad.dispose();
        // _appOpenAd = null;
        // load();
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        _isShowingAd = false;

        onAdFailedToShow?.call(adNetwork, adUnitType, ad, error.toString());

        ad.dispose();
        // _appOpenAd = null;
        // load();
      },
    );

    _appOpenAd!.show();
    _appOpenAd = null;
    _isShowingAd = false;
    _isAdLoaded = false;
  }
}
