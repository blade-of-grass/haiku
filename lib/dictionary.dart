import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:haiku/haiku_configs.dart';

class Dictionary {
  final List<Book> books;

  Dictionary._(this.books);

  static Future<Dictionary> load(Map<int, String> filenames) async {
    final splitter = LineSplitter();

    // iterate through each tagged word file organized by number of syllables
    final books = <Book>[];
    await Future.forEach(filenames.entries, (entry) async {
      final syllables = entry.key;
      final filename = entry.value;

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
      books.add(Book(syllables, definitions));
    });

    return Dictionary._(books);
  }
}

class Book {
  final int syllables;
  final Map<PartOfSpeech, List<String>> _definitions;
  List<String> operator [](PartOfSpeech pos) => _definitions[pos];

  List<PartOfSpeech> get partsOfSpeech {
    return _definitions.keys.toList(growable: false);
  }

  Book(this.syllables, Map<PartOfSpeech, List<String>> definitions)
      : _definitions = definitions;
}
