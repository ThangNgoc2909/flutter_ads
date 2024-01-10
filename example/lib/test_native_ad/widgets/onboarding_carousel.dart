part of '../onboarding_screen.dart';

class OnboardingCarousel extends StatelessWidget {
  const OnboardingCarousel({
    super.key,
    required PageController pageController,
    required this.valueNotifier,
  }) : _pageController = pageController;

  final PageController _pageController;
  final ValueNotifier valueNotifier;

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      onPageChanged: (int page) {
        valueNotifier.value = page;
      },
      children: <Widget>[
        Container(
          width: 100,
          height: 100,
          color: Colors.red,
        ),
        Container(
          width: 100,
          height: 100,
          color: Colors.blue,
        ),
        Container(
          width: 100,
          height: 100,
          color: Colors.green,
        ),
      ],
    );
  }
}
