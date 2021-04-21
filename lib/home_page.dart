import 'package:flutter/material.dart';
import 'package:haiku/haiku.dart';
import 'package:haiku/haiku_bloc.dart';
import 'package:haiku/haiku_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Haiku>(
      initialData: HaikuBloc.of(context).currentHaiku,
      stream: HaikuBloc.of(context).stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final haiku = snapshot.data;

          Color backgroundColor;
          switch (Theme.of(context).brightness) {
            case Brightness.dark:
              int index = haiku.seed % _darkBackgroundColors.length;
              backgroundColor = _darkBackgroundColors[index];
              break;
            case Brightness.light:
              int index = haiku.seed % _lightBackgroundColors.length;
              backgroundColor = _lightBackgroundColors[index];
              break;
          }

          return Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(64.0),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: HaikuWidget(haiku: haiku),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: HaikuBloc.of(context).generateHaiku,
              child: Icon(Icons.refresh),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}

final _lightBackgroundColors = [
  Colors.amber[50],
  Colors.blue[50],
  Colors.brown[50],
  Colors.cyan[50],
  Colors.deepOrange[50],
  Colors.deepPurple[50],
  Colors.green[50],
  Colors.indigo[50],
  Colors.lightBlue[50],
  Colors.lightGreen[50],
  Colors.lime[50],
  Colors.orange[50],
  Colors.pink[50],
  Colors.purple[50],
  Colors.red[50],
  Colors.teal[50],
  Colors.yellow[50],
];

final _darkBackgroundColors = [
  Colors.black,
];
