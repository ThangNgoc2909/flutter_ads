import 'dart:async';

class CollapseBannerAdStream{
  bool state = true;
  CollapseBannerAdStream._();
  static CollapseBannerAdStream instance = CollapseBannerAdStream._();

  StreamController<bool> counterController = StreamController<bool>.broadcast();
  Stream<bool> get stream => counterController.stream;

  void hide(){
    state = false;
    counterController.add(state);
  }
  void show(){
    state = true;
    counterController.add(state);
  }
}