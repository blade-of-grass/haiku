import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

enum PartOfSpeech {
  noun,
  verb,
  adjective,
  adverb,
  preposition,
  conjunction,
  article,
  interjection,
}

List<Map<PartOfSpeech, List<String>>> _dictionary;

void _add_word(
  Map<PartOfSpeech, List<String>> definitions,
  PartOfSpeech pos,
  String word,
) {
  if (!definitions.containsKey(pos)) {
    definitions[pos] = [];
  }
  definitions[pos].add(word);
}

class Haiku {
  final _lines = <String>[];
  final int seed;
  operator [](int i) => _lines[i];

  static Future<bool> loadDictionary() async {
    final splitter = LineSplitter();

    _dictionary = [];

    // iterate through each tagged word file organized by number of syllables
    for (int syllables = 1; syllables <= 7; ++syllables) {
      final filename = "assets/data/$syllables-syllable-words-tagged.txt";

      // read each line of the file
      final lines = await rootBundle.loadStructuredData<List<String>>(
        filename,
        (file) => Future.value(splitter.convert(file)),
      );

      // each line starts with its word followed by its potential parts of speech
      final Map<PartOfSpeech, List<String>> definitions = {};
      for (final line in lines) {
        final symbols = line.split(" ");
        final word = symbols[0];
        for (final symbol in symbols.sublist(1)) {
          switch (symbol) {
            case "noun":
            case "plural":
            case "noun_phrase":
            case "nominative":
            case "pronoun":
              _add_word(definitions, PartOfSpeech.noun, word);
              break;
            case "verb_participle":
              _add_word(definitions, PartOfSpeech.noun, word);
              _add_word(definitions, PartOfSpeech.adjective, word);
              break;
            case "verb_transitive":
            case "verb_intransitive":
              _add_word(definitions, PartOfSpeech.verb, word);
              break;
            case "adjective":
              _add_word(definitions, PartOfSpeech.adjective, word);
              break;
            case "adverb":
              _add_word(definitions, PartOfSpeech.adverb, word);
              break;
            case "conjunction":
              _add_word(definitions, PartOfSpeech.conjunction, word);
              break;
            case "preposition":
              _add_word(definitions, PartOfSpeech.preposition, word);
              break;
            case "interjection":
              _add_word(definitions, PartOfSpeech.interjection, word);
              break;
            case "indefinite_article":
            case "definite_article":
              _add_word(definitions, PartOfSpeech.article, word);
              break;
          }
        }
      }

      _dictionary.add(definitions);
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
      final entry = _dictionary[syllableIndex];
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
