import 'package:flutter/material.dart';

class TopScreenImage extends StatelessWidget {
  const TopScreenImage({super.key, required this.screenImageName});
  final String screenImageName;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 0,
      child: Container(
        child: Image(
          fit: BoxFit.contain,
          height: 198,
          width: 198,
          image: AssetImage('assets/images/$screenImageName'),
        ),
      ),
    );
  }
}
