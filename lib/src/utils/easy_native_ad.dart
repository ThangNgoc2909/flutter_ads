import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:easy_ads_flutter/src/enums/ad_status.dart';
import 'package:flutter/material.dart';

import 'easy_loading_ad.dart';

class EasyNativeAd extends StatefulWidget {
  final AdNetwork adNetwork;
  final String? factoryId;
  final String? adId;
  final String? highId;
  final double height;
  final Widget? loadingWidget;
  final NativeAdController? controller;

  const EasyNativeAd({
    super.key,
    this.adNetwork = AdNetwork.admob,
    this.highId,
    this.adId,
    this.factoryId,
    this.controller,
    required this.height,
    this.loadingWidget,
  })  : assert(
          controller == null || (adId == null && factoryId == null),
          'Cannot provide both a controller and (adId, factoryId)\n'
          'To provide both, use "controller: NativeAdController(adId: adId, factoryId: factoryId)".',
        ),
        assert(
          controller != null || (adId != null && factoryId != null),
          'Provide at least a (adId,factoryId) or controller',
        );

  @override
  State<EasyNativeAd> createState() => _EasyNativeAdState();
}

class _EasyNativeAdState extends State<EasyNativeAd> {
  late NativeAdController controller;

  @override
  void didUpdateWidget(covariant EasyNativeAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null) {
      if (oldWidget.controller!.controllerId !=
          widget.controller!.controllerId) {
        controller = widget.controller!;
      }
    } else {
      if (oldWidget.adId != widget.adId) {
        controller = NativeAdController(
          adId: widget.adId!,
          factoryId: widget.factoryId!,
          highId: widget.highId,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initAd();
  }

  void initAd() async {
    if (widget.controller == null) {
      controller = NativeAdController(
        adId: widget.adId!,
        factoryId: widget.factoryId!,
        highId: widget.highId,
      );
    } else {
      controller = widget.controller!;
    }
    if (!EasyAds.instance.hasInternet) {
      return;
    }
    controller.stream.listen((event) {
      if (!event.isInit && mounted) {
        setState(() {});
      }
    });
    if (controller.status.isInit) {
      controller.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.status.isLoading) {
      return SizedBox(
        height: widget.height,
        child: widget.loadingWidget ?? const EasyLoadingAd(),
      );
    }
    if (controller.ad == null || !controller.status.isLoaded) {
      return SizedBox(
        child: EasyAds.instance.hasInternet ? widget.loadingWidget : null,
      );
    }
    return SizedBox(
      key: ValueKey(controller.controllerId),
      height: widget.height,
      child: StatefulBuilder(
        builder: (context, setState) => AdWidget(ad: controller.ad!),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }
}
