part of '../onboarding_screen.dart';

class ActionRow extends StatefulWidget {
  const ActionRow({
    super.key,
    required PageController pageController,
    required this.valueNotifier,
  }) : _pageController = pageController;

  final PageController _pageController;
  final ValueNotifier valueNotifier;

  @override
  State<ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<ActionRow> {
  @override
  Widget build(BuildContext context) {
    final int currentIndex = widget.valueNotifier.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: buildIndicator(
            context,
            3,
            currentIndex,
          ),
        ),
        TextButton(
          onPressed: () {
            if (currentIndex < 2) {
              _pressNextButton(currentIndex);
            } else {
              _done();
            }
          },
          child: Text(
            currentIndex > 1 ? 'Start' : 'Next',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _pressNextButton(int currentIndex) {
    if (currentIndex < 2) {
      widget.valueNotifier.value += 1;
      if (currentIndex < 3) {
        widget._pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    }
  }

  Future<void> _done() async {}
}
