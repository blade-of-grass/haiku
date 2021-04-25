import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:haiku/haiku_configs.dart';

class Haiku {
  final _lines = <String>[];
  final int seed;
  operator [](int i) => _lines[i];

  Haiku(int seed, Dictionary dictionary) : this.seed = seed {
    final prng = Random(seed);
    final pattern = SYLLABLE_PATTERN;

    for (int syllables in pattern) {
      String line = "";
      while (syllables > 0) {
        final books = dictionary.getBooks(maxSyllableCount: syllables);
        final book = books[prng.nextInt(books.length)];

        final partsOfSpeech = book.partsOfSpeech;
        final partOfSpeech = partsOfSpeech[prng.nextInt(partsOfSpeech.length)];

        final int word = prng.nextInt(book[partOfSpeech].length);

        line += book[partOfSpeech][word];
        syllables -= book.syllables;

        // once we reach the end of the line consider adding punctuation
        if (syllables == 0) {
          int punctuation = prng.nextInt(getPunctuationWeightTotal);
          for (final weight in PUNCTUATION_WEIGHTS.entries) {
            punctuation -= weight.value;
            if (punctuation <= 0) {
              line += weight.key;
              break;
            }
          }
        } else {
          line += ' ';
        }
      }
      _lines.add(line);
    }
  }
}

class Book {
  final int syllables;
  final Map<PartOfSpeech, List<String>> _definitions;
  operator [](PartOfSpeech pos) => _definitions[pos];

  List<PartOfSpeech> get partsOfSpeech {
    return _definitions.keys.toList(growable: false);
  }

  Book(this.syllables, Map<PartOfSpeech, List<String>> definitions)
      : _definitions = definitions;
}

class Dictionary {
  final List<Book> _books;

  /// get the number of books in the dictionary
  /// books are separated by syllable count
  /// provide a maxSyllableCount to get the number of books less than the provided count
  List<Book> getBooks({int maxSyllableCount}) {
    if (maxSyllableCount == null) {
      return _books;
    } else {
      // only return pages where the number of syllables
      // is less than or equal to the number provided
      return _books
          .where((book) => book.syllables <= maxSyllableCount)
          .toList(growable: false);
    }
  }

  Dictionary._(List<Book> books) : _books = books;

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
