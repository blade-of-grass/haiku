import 'dart:math';
import 'package:haiku/haiku_configs.dart';

class Haiku {
  final _lines = <String>[];
  final int seed;
  operator [](int i) => _lines[i];

  Haiku(int seed, HaikuConfig config) : this.seed = seed {
    final prng = Random(seed);

    config.reader.reset();
    for (int syllables in config.pattern) {
      String line = "";
      while (syllables > 0) {
        final transitions = config.reader.transitions;
        final book = config.dictionary.books
            .where((b) =>
                b.syllables <= syllables &&
                transitions.intersection(b.partsOfSpeech).isNotEmpty)
            .toList(growable: false)
            .chainedSort((a, b) => a.syllables.compareTo(b.syllables))
            .getRandomElement(prng);

        final partOfSpeech = transitions
            .intersection(book.partsOfSpeech)
            .toList()
            .chainedSort((a, b) => a.index.compareTo(b.index))
            .getRandomElement(prng);

        line += book[partOfSpeech].getRandomElement(prng);

        // we have consumed some syllables
        // we have also transitioned to the next state
        syllables -= book.syllables;
        config.reader.transition(partOfSpeech);

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
