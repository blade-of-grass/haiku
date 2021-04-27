import 'package:haiku/haiku_configs.dart';

class GrammarParser {
  int _state;
  static const _START_STATE = 0;

  Map<int, Map<PartOfSpeech, int>> _statesAndTransitions = {};

  GrammarParser(String grammar) {
    int state = _START_STATE;

    String lastReadTerminal = "";
    grammar.runes.forEach((rune) {
      String char = String.fromCharCode(rune);
      if (_TERMINAL_MAPPINGS.containsKey(char)) {
        // TODO: we found a terminal
        lastReadTerminal = char;
      } else if (char == '*') {
        checkValidity(lastReadTerminal, '*');
      } else if (char == '?') {
        checkValidity(lastReadTerminal, '?');
      } else if (char == '+') {
        checkValidity(lastReadTerminal, '+');
        lastReadTerminal = null;
      } else if (char != ' ') {
        throw new Exception(
            "unsupported character ($char) found while parsing grammar");
      }
    });
  }

  void reset() {
    _state = _START_STATE;
  }

  Set<PartOfSpeech> get transitions =>
      _statesAndTransitions[_state].keys.toSet();

  void transition(PartOfSpeech input) {
    _state = _statesAndTransitions[_state][input];
  }
}

void checkValidity(String lastReadTerminal, String op) {
  if (lastReadTerminal == null) {
    throw new Exception(
        "unexpected ($op), this symbol must be preceded by a terminal");
  }
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
