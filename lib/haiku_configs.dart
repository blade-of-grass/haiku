// the base grammatical format of a haiku
// + means the preceding or following statement could occur
// * denotes the preceding terminal can repeat 0 or more times
// ? denotes the preceding terminal is optional

import 'package:flutter/foundation.dart';
import 'package:haiku/dictionary.dart';
import 'package:haiku/state_machine.dart';

// TODO: I would like to build these into the grammar
// {-:3 !:3 ?:3 .:15 ,:15 :50} should be equivalent to the following:
/// how much weight to apply to each punctuation character
const _PUNCTUATION_WEIGHTS = {
  '-': 3,
  '!': 3,
  '?': 3,
  '.': 15,
  ',': 15,
  '': 50,
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

// TODO: remove this punctuation stuff once "weighted terminals" are implemented
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

class HaikuConfig {
  Dictionary dictionary;
  StateMachine<PartOfSpeech> reader;
  List<int> pattern;

  HaikuConfig._({
    @required this.dictionary,
    @required this.reader,
    @required this.pattern,
  });

  static Future<HaikuConfig> init({
    @required Map<int, String> dictionaryFiles,
    @required String grammar,
    @required List<int> pattern,
    Map<String, PartOfSpeech> terminalMappings = _TERMINAL_MAPPINGS,
  }) async {
    return HaikuConfig._(
      dictionary: await Dictionary.load(dictionaryFiles),
      reader: StateMachine.parseGrammar(grammar, terminalMappings),
      pattern: pattern,
    );
  }
}

const _TERMINAL_MAPPINGS = {
  "n": PartOfSpeech.noun,
  "v": PartOfSpeech.verb,
  "a": PartOfSpeech.adjective,
  "d": PartOfSpeech.adverb,
  "p": PartOfSpeech.preposition,
  "c": PartOfSpeech.conjunction,
  "r": PartOfSpeech.article,
  "i": PartOfSpeech.interjection,
};
