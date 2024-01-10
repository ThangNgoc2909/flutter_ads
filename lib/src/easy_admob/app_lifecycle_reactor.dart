// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import '../../easy_ads_flutter.dart';

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor {
  final GlobalKey<NavigatorState> navigatorKey;
  final Image appIconImage;

  bool _onSplashScreen = false;
  bool isExcludeScreen = false;
  bool _shouldShow = false;

  AppLifecycleReactor({required this.navigatorKey, required this.appIconImage});

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
  }

  void setShouldShow(bool value) {
    _shouldShow = value;
  }

  void setOnSplashScreen(bool value) {
    _onSplashScreen = value;
  }

  void setIsExcludeScreen(bool value) {
    isExcludeScreen = value;
  }

  void _onAppStateChanged(AppState appState) async {
    // Show AppOpenAd when back to foreground but do not show on excluded screens
    if (appState == AppState.foreground) {
      if (!_shouldShow) {
        return;
      }
      if (_onSplashScreen) {
        return;
      }
      if (!isExcludeScreen) {
        if (navigatorKey.currentContext != null) {
          if (EasyAds.instance.isFullscreenAdShowing) {
            return;
          }
          EasyAds.instance.showAppOpenAd(
            navigatorKey.currentContext!,
            appIconImage,
            callback: () {
              final bool isShow = CollapseBannerAdStream.instance.state;
              if (isShow) {
                EasyAds.instance.initCollapsibleBannerAd();
              }
            },
          );
        }
      } else {
        isExcludeScreen = false;
      }
    }
  }
}
