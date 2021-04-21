import 'package:flutter/material.dart';
import 'package:haiku/haiku.dart';

class HaikuWidget extends StatelessWidget {
  final Haiku haiku;

  HaikuWidget({@required this.haiku});

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.black;
    if (Theme.of(context).brightness == Brightness.dark) {
      textColor = Colors.white;
    }

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: "Arvo",
        fontSize: 28,
        color: textColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(haiku[0]),
          SizedBox(height: 12),
          Text(haiku[1]),
          SizedBox(height: 12),
          Text(haiku[2]),
        ],
      ),
    );
  }
}
