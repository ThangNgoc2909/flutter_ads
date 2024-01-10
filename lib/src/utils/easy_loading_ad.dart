import 'package:flutter/cupertino.dart';

class EasyLoadingAd extends StatelessWidget {
  const EasyLoadingAd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CupertinoActivityIndicator(),
    );
  }
}
