import 'dart:math';
import 'package:haiku/haiku_configs.dart';

class Haiku {
  final _lines = <String>[];
  final int seed;
  operator [](int i) => _lines[i];

  Haiku(int seed, HaikuConfig config) : this.seed = seed {
    final prng = Random(seed);
    final pattern = config.pattern;

    config.parser.reset();

    for (int syllables in pattern) {
      String line = "";
      while (syllables > 0) {
        final transitions = config.parser.transitions;
        final book = config.dictionary.books
            .where((b) => b.syllables <= syllables && transitions.contains(b))
            .toList(growable: false)
            .getRandomElement(prng);

        final partOfSpeech = book.partsOfSpeech.getRandomElement(prng);

        line += book[partOfSpeech].getRandomElement(prng);

        // we have consumed some syllables
        // we have also transitioned to the next state
        syllables -= book.syllables;
        config.parser.transition(partOfSpeech);

        // once we reach the end of the line consider adding punctuation
        if (syllables == 0) {
          line += getPunctuation(prng.nextInt(getPunctuationWeightTotal));
        } else {
          line += ' ';
        }
      }
      _lines.add(line);
    }
  }
}
