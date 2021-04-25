// the base grammatical format of a haiku representing as a regular grammar
const GRAMMAR = "(a*p?r?a*n + d*vv*d* + i + c)*";
const SYLLABLE_PATTERN = [5, 7, 5];

const PUNCTUATION_WEIGHTS = {
  '-': 3,
  '!': 3,
  '?': 3,
  '.': 15,
  ',': 15,
  '': 50,
};

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
// """""""""""""""""""""""""""""""""""""" \ """"""""
//                                         \
//                                          \    /""\       ,
//                                             <>^   L_____/|
//           _________________________________   `) /`    , /   _____________________
//          |\                                    \ `---'  /                       / |
//           \\    ####    ####    ####    ####     `'";\)`        ####    ####   / /
//            \\                                    _/_Y                         / /
//             \\_______________________________________________________________/ /
//              \|______________________________________________________________|/

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
        PUNCTUATION_WEIGHTS.values.reduce((a, b) => a + b);
  }
  return _punctuationWeightTotal;
}

const _TERMINAL_MAPPINGS = {
  "n": PartOfSpeech.noun,
  "v": PartOfSpeech.noun,
  "a": PartOfSpeech.adjective,
  "d": PartOfSpeech.adverb,
  "p": PartOfSpeech.preposition,
  "c": PartOfSpeech.conjunction,
  "r": PartOfSpeech.article,
  "i": PartOfSpeech.interjection,
};

const STANDARD_DICTIONARY = {
  1: 'assets/data/1-syllable-words-tagged.txt',
  2: 'assets/data/2-syllable-words-tagged.txt',
  3: 'assets/data/3-syllable-words-tagged.txt',
  4: 'assets/data/4-syllable-words-tagged.txt',
  5: 'assets/data/5-syllable-words-tagged.txt',
  6: 'assets/data/6-syllable-words-tagged.txt',
  7: 'assets/data/7-syllable-words-tagged.txt',
};
