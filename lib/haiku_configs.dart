// the base grammatical format of a haiku
// + means the preceding or following statement could occur
// * denotes the preceding terminal can repeat 0 or more times
// ? denotes the preceding terminal is optional
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:haiku/dictionary.dart';
import 'package:haiku/grammar_parser.dart';

const GRAMMAR = "a*p?r?a*n + d*vv*d* + i + c";

// each number corresponds to the number of syllables each line should have
const SYLLABLE_PATTERN = [5, 7, 5];

// TODO: I would like to build these into the grammar
// {-:3!:3?:3.:15,:15:50} should be equivalent to the following:
/// how much weight to apply to each punctuation character
const _PUNCTUATION_WEIGHTS = {
  '-': 3,
  '!': 3,
  '?': 3,
  '.': 15,
  ',': 15,
  '': 50,
};

/// the keys here represent the possible parts of speech of each word
/// these keys were obtained from the assets/data/x-syllable-words-tagged.txt files
/// the values represent their mapping to the internal system used in this app
/// the internal system "rounds" each part of speech to a broader category
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

//
// the following configs should not be modified    #
// they are meant to be constants                  #
// """"""""""""""""""""""""""""""""""""""" \ """""""
//                                          \
//                                           \   /""\       ,
//                                             <>^   L_____/ |
//   _________________________________________   `)  /`    , /   _____________________
//  |\                                            \ `---'  /                       / |
//   \\    ####    ####    ####    ####    ####     `'";\)`        ####    ####   / /
//    \\                                            _/_Y                         / /
//     \\_______________________________________________________________________/ /
//      \|______________________________________________________________________|/

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

int _punctuationWeightTotal;
get getPunctuationWeightTotal {
  if (_punctuationWeightTotal == null) {
    _punctuationWeightTotal =
        _PUNCTUATION_WEIGHTS.values.reduce((a, b) => a + b);
  }
  return _punctuationWeightTotal;
}

String getPunctuation(int index) {
  for (final weight in _PUNCTUATION_WEIGHTS.entries) {
    index -= weight.value;
    if (index <= 0) {
      return weight.key;
    }
  }
  return "";
}

const STANDARD_DICTIONARY = {
  1: 'assets/data/1-syllable-words-tagged.txt',
  2: 'assets/data/2-syllable-words-tagged.txt',
  3: 'assets/data/3-syllable-words-tagged.txt',
  4: 'assets/data/4-syllable-words-tagged.txt',
  5: 'assets/data/5-syllable-words-tagged.txt',
  6: 'assets/data/6-syllable-words-tagged.txt',
  7: 'assets/data/7-syllable-words-tagged.txt',
};

class HaikuConfig {
  Dictionary dictionary;
  GrammarParser parser;
  List<int> pattern;

  HaikuConfig._({
    @required this.dictionary,
    @required this.parser,
    @required this.pattern,
  });

  static Future<HaikuConfig> init(Map<int, String> dictionaryFiles,
      String grammar, List<int> pattern) async {
    return HaikuConfig._(
      dictionary: await Dictionary.load(dictionaryFiles),
      parser: GrammarParser(grammar),
      pattern: pattern,
    );
  }
}

T getRandomElement<T>(List<T> elements, Random random) {
  return elements[random.nextInt(elements.length)];
}

extension RandomElement<T> on List<T> {
  T getRandomElement(Random random) {
    return this[random.nextInt(this.length)];
  }
}
