import 'package:flutter/material.dart';
import 'package:haiku/haiku_configs.dart';
import 'package:haiku/haiku_bloc.dart';
import 'package:haiku/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadDictionary(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HaikuBloc(
            child: MaterialApp(
              title: 'Flutter Demo',
              debugShowCheckedModeBanner: false,
              theme: _lightTheme,
              darkTheme: _darkTheme,
              home: HomePage(),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}

ThemeData get _lightTheme => ThemeData.light().copyWith(
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.black12,
      ),
    );

ThemeData get _darkTheme => ThemeData.dark().copyWith(
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.white60,
      ),
    );
