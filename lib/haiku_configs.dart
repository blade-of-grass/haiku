import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:haiku/haiku_configs.dart';

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

const PART_OF_SPEECH_MAPPING = {
  "noun": [PartOfSpeech.noun],
  "plural": [PartOfSpeech.noun],
  "noun_phrase": [PartOfSpeech.noun],
  "nominative": [PartOfSpeech.noun],
  "pronoun": [PartOfSpeech.noun],
  "verb_participle": [PartOfSpeech.noun, PartOfSpeech.adjective],
  "verb_transitive": [PartOfSpeech.verb],
  "verb_intransitive": [PartOfSpeech.verb],
  "adjective": [PartOfSpeech.adjective],
  "adverb": [PartOfSpeech.adverb],
  "conjunction": [PartOfSpeech.conjunction],
  "preposition": [PartOfSpeech.preposition],
  "interjection": [PartOfSpeech.interjection],
  "indefinite_article": [PartOfSpeech.article],
  "definite_article": [PartOfSpeech.article],
};

const _TERMINAL_MAPPING = {
  "n": PartOfSpeech.noun,
  "v": PartOfSpeech.noun,
  "a": PartOfSpeech.adjective,
  "d": PartOfSpeech.adverb,
  "p": PartOfSpeech.preposition,
  "c": PartOfSpeech.conjunction,
  "r": PartOfSpeech.article,
  "i": PartOfSpeech.interjection,
};

const GRAMMAR = {
  [
    "raan",
    "rnvprn",
    "ind",
  ],
  [
    "rnpn",
    "cpan",
    "rnpn",
  ],
  [
    "rnprn",
    "vvpan",
    "an",
  ],
  [
    "nvvv",
    "vdcn",
    "rnv",
  ],
  [
    "prn",
    "nnvpn",
    "panpn",
  ],
};

// TODO: this should be passed into the bloc rather than being a global
List<Map<PartOfSpeech, List<String>>> _dictionary;
List<Map<PartOfSpeech, List<String>>> get dictionary => _dictionary;

Future<bool> loadDictionary() async {
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
        for (final pos in PART_OF_SPEECH_MAPPING[symbol]) {
          if (!definitions.containsKey(pos)) {
            definitions[pos] = [];
          }
          definitions[pos].add(word);
        }
      }
    }

    _dictionary.add(definitions);
  }

  return true;
}
