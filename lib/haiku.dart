import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

List<List<String>> _dictionary;

class Haiku {
  final _lines = <String>[];
  final int seed;
  operator [](int i) => _lines[i];

  static Future<bool> loadDictionary() async {
    final splitter = LineSplitter();

    _dictionary = [];

    for (int i = 1; i <= 7; ++i) {
      final filename = "assets/data/$i-syllable-words.txt";
      final words = await rootBundle.loadStructuredData<List<String>>(
        filename,
        (file) => Future.value(splitter.convert(file)),
      );

      _dictionary.add(words);
    }

    return true;
  }

  Haiku(int seed) : this.seed = seed {
    final prng = Random(seed);

    _lines.add(Haiku._generateLine(5, prng));
    _lines.add(Haiku._generateLine(7, prng));
    _lines.add(Haiku._generateLine(5, prng));
  }

  static String _generateLine(int syllables, Random prng) {
    String line = "";
    while (syllables > 0) {
      final int syllableIndex = prng.nextInt(syllables);
      final int wordIndex = prng.nextInt(_dictionary[syllableIndex].length);

      line += _dictionary[syllableIndex][wordIndex] + ' ';
      syllables -= syllableIndex + 1;
    }
    return line;
  }
}
