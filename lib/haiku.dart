import 'dart:math';

import 'package:haiku/haiku_configs.dart';

class Haiku {
  final _lines = <String>[];
  final int seed;
  operator [](int i) => _lines[i];

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
      final entry = dictionary[syllableIndex];
      final partOfSpeech =
          entry.keys.toList(growable: false)[prng.nextInt(entry.length)];
      final int word = prng.nextInt(entry[partOfSpeech].length);

      line += entry[partOfSpeech][word];
      syllables -= syllableIndex + 1;

      if (syllables < 1) {
        int punctuation = prng.nextInt(100);
        if (punctuation < 3) {
          line += '-';
        } else if (punctuation < 6) {
          line += '!';
        } else if (punctuation < 9) {
          line += '?';
        } else if (punctuation < 20) {
          line += '.';
        } else if (punctuation < 35) {
          line += ',';
        }
      } else {
        line += ' ';
      }
    }
    return line;
  }
}
