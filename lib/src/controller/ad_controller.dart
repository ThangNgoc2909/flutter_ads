import 'dart:async';

import '../enums/ad_status.dart';

typedef AdStatusCallback = void Function(AdStatus status);

abstract class AdController {
  AdController({
    required this.adId,
    this.highId,
  });

  final String adId;
  final String? highId;

  final StreamController<AdStatus> _streamController =
      StreamController.broadcast();

  Stream<AdStatus> get stream => _streamController.stream;
  AdStatus _status = AdStatus.init;

  AdStatus get status => _status;

  FutureOr<void> load([String? id]);

  void reload() {}

  void dispose() {
    _streamController.close();
  }

  void addEvent(AdStatus status) {
    _status = status;
    _streamController.sink.add(status);
  }
}
