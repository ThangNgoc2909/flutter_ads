import 'package:flutter/material.dart';

Widget indicator(BuildContext context, bool isActive) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    height: 8,
    width: isActive ? 24 : 8,
    margin: EdgeInsets.only(right: 5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
    ),
  );
}

//Create the indicator list
List<Widget> buildIndicator(
    BuildContext context, int length, int currentIndex) {
  final List<Widget> indicators = <Widget>[];

  for (int i = 0; i < length; i++) {
    if (currentIndex == i) {
      indicators.add(indicator(context, true));
    } else {
      indicators.add(indicator(context, false));
    }
  }
  return indicators;
}
