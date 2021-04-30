import 'dart:math';
import 'package:haiku/haiku_configs.dart';
import 'package:haiku/extensions.dart';

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
        // get possible transitions from the state machine
        final transitions = config.reader.transitions;

        // get the book we want to select a word from
        final book = config.dictionary.books
            // get books where syllables are within the required range
            // and parts of speech contains at least one potential transition
            .where((b) =>
                b.syllables <= syllables &&
                b.partsOfSpeech.intersection(transitions).isNotEmpty)
            // convert to list...
            .toList(growable: false)
            // sort by syllable count so order is known to be the same
            .chainedSort((a, b) => a.syllables.compareTo(b.syllables))
            // get a random weighted element from the list
            // weight is determined by the number of words in a given book
            // books are categorized by syllable count
            .getRandomWeightedElement(prng);

        // decide on a part of speech to select
        final partOfSpeech = book.partsOfSpeech
            // only bother with potential transitions
            .intersection(transitions)
            // convert to list...
            .toList()
            // sort by index so that order is known to be the same for each seed
            .chainedSort((a, b) => a.index.compareTo(b.index))
            // get a random element from the list
            .getRandomElement(prng);

        // add a random word with our selected part of speech to the line
        line += book[partOfSpeech].getRandomElement(prng);

        // we have consumed some syllables
        syllables -= book.syllables;

        // we have also selected a part of speech so we should transition to the next state
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
