import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:haiku/extensions.dart';
import 'package:haiku/haiku_configs.dart';

class Dictionary {
  final List<Book> books;

  Dictionary._(this.books);

  /// filenames
  ///
  static Future<Dictionary> load(Map<int, String> filenames,
      [Map<String, List<PartOfSpeech>> partOfSpeechMapping =
          _PART_OF_SPEECH_MAPPING]) async {
    final splitter = LineSplitter();

    // iterate through each tagged word file organized by number of syllables
    final books = <Book>[];

    await Future.forEach(filenames.entries, (entry) async {
      final syllables = entry.key;
      final filename = entry.value;
      var wordCount = 0;

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
          for (final pos in partOfSpeechMapping[symbol]) {
            // if the part-of-speech doesn't exist in the dictionary, assign a new array as it's value
            if (!definitions.containsKey(pos)) {
              definitions[pos] = [];
            }

            // this block is required to not count the same part-of-speech -> word mapping twice
            if (!definitions[pos].contains(word)) {
              definitions[pos].add(word);
              ++wordCount;
            }
          }
        }
      }
      books.add(Book(
        syllables: syllables,
        definitions: definitions,
        wordCount: wordCount,
      ));
    });

    return Dictionary._(books);
  }
}

class Book implements WeightedItem {
  final int syllables;
  final int wordCount;
  final Map<PartOfSpeech, List<String>> _definitions;
  List<String> operator [](PartOfSpeech pos) => _definitions[pos];

  int get weight => wordCount;

  Set<PartOfSpeech> get partsOfSpeech {
    return _definitions.keys.toSet();
  }

  Book({
    @required this.syllables,
    @required Map<PartOfSpeech, List<String>> definitions,
    @required this.wordCount,
  }) : _definitions = definitions;
}

/// the keys here represent the possible parts of speech of each word
/// these keys were obtained from the assets/data/x-syllable-words-tagged.txt files
/// the values represent their mapping to the internal system used in this app
/// the internal system "rounds" each part of speech to a broader category
const _PART_OF_SPEECH_MAPPING = {
  "noun": [PartOfSpeech.noun],
  "plural": [PartOfSpeech.noun],
  "noun_phrase": [PartOfSpeech.noun],
  "nominative": [PartOfSpeech.noun],
  "pronoun": [PartOfSpeech.noun],
  "verb_participle": [PartOfSpeech.verb, PartOfSpeech.adjective],
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
