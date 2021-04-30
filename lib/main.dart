import 'package:flutter/material.dart';
import 'package:haiku/haiku_bloc.dart';
import 'package:haiku/haiku_configs.dart';
import 'package:haiku/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HaikuConfig>(
      future: HaikuConfig.init(
        // the dictionary used to generate the haikus
        // a mapping from syllable count to file
        dictionaryFiles: {
          1: 'assets/data/1-syllable-words-tagged.txt',
          2: 'assets/data/2-syllable-words-tagged.txt',
          3: 'assets/data/3-syllable-words-tagged.txt',
          4: 'assets/data/4-syllable-words-tagged.txt',
          5: 'assets/data/5-syllable-words-tagged.txt',
          6: 'assets/data/6-syllable-words-tagged.txt',
          7: 'assets/data/7-syllable-words-tagged.txt',
        },
        // a grammar describing the kinds of haikus the generator should create
        grammar: "a*p?r?a*n + d*vv*d* + i + c",
        // each number corresponds to the number of syllables each line should have
        pattern: [5, 7, 5],
      ),
      builder: (context, snapshot) => snapshot.hasData
          ? HaikuBloc(
              config: snapshot.data,
              child: MaterialApp(
                title: 'Flutter Demo',
                debugShowCheckedModeBanner: false,
                theme: _lightTheme,
                darkTheme: _darkTheme,
                home: HomePage(),
              ),
            )
          : SizedBox.shrink(),
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
