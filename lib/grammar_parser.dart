class StateMachine<T> {
  int _state;
  static const _START_STATE = 0;

  Map<int, Map<T, int>> _statesAndTransitions = {
    _START_STATE: {},
  };

  StateMachine.parseGrammar(String grammar, Map<String, T> terminalMappings) {
    int state = _START_STATE;
    var context = <int>{state};
    var previousStates = {...context};

    T previousTerminal;
    String progress = '';

    grammar.runes.forEach((rune) {
      String symbol = String.fromCharCode(rune);
      progress += symbol;

      if (terminalMappings.containsKey(symbol)) {
        ++state;
        T terminal = terminalMappings[symbol];
        _statesAndTransitions[state] = {};
        previousStates
            .forEach((s) => _statesAndTransitions[s][terminal] = state);
        if (previousTerminal != null) {
          previousStates.clear();
        }
        previousTerminal = terminal;
        previousStates.add(state);
      } else if (symbol == '*') {
        checkValidity(previousTerminal, '*', progress);
        _statesAndTransitions[state][previousTerminal] = state;
        previousTerminal = null;
      } else if (symbol == '?') {
        checkValidity(previousTerminal, '?', progress);
        previousTerminal = null;
      } else if (symbol == '+') {
        if (previousStates.difference(context).isEmpty) {
          throw new Exception(
              'the (+) operator must be preceded by a statement ( $progress )');
        }
        if (previousTerminal == null) {
          context = previousStates.union(context);
          previousStates = {...context};
        } else {
          context.add(state);
          previousStates = <int>{state};
        }
      } else if (symbol != ' ') {
        throw new Exception('symbol ($symbol) not recognized ( $progress )');
      }

      // String char = String.fromCharCode(rune);
      // progress += char;
      // if (_TERMINAL_MAPPINGS.containsKey(char)) {
      //   if (lastReadTerminal != null) {
      //     if (inputs.length > 0) {
      //       inputs.forEach(
      //           (input) => _statesAndTransitions[state][input] = state + 1);
      //       ++state;
      //       _statesAndTransitions[state] = {};
      //     }
      //     _statesAndTransitions[state][lastReadTerminal] = state + 1;
      //     ++state;
      //     _statesAndTransitions[state] = {};
      //   }
      //   lastReadTerminal = _TERMINAL_MAPPINGS[char];
      // } else {
      //   if (char == '*') {
      //     checkValidity(lastReadTerminal, '*');
      //     inputs.add(lastReadTerminal);
      //     _statesAndTransitions[state][lastReadTerminal] = state;
      //   } else if (char == '?') {
      //     checkValidity(lastReadTerminal, '?');
      //     inputs.add(lastReadTerminal);
      //   } else if (char == '+') {
      //     checkValidity(lastReadTerminal, '+');
      //     inputs.forEach(
      //         (input) => _statesAndTransitions[state][input] = _START_STATE);
      //     inputs.clear();
      //     state = _START_STATE;
      //     lastReadTerminal = null;
      //   } else if (char != ' ') {
      //     throw new Exception(
      //         "unsupported character ($char) found while parsing grammar ($progress)");
      //   }
      // }
    });
    print(_statesAndTransitions);
  }

  void reset() {
    _state = _START_STATE;
  }

  Set<T> get transitions => _statesAndTransitions[_state].keys.toSet();

  void transition(T input) {
    _state = _statesAndTransitions[_state][input];
  }
}

void checkValidity(var lastReadTerminal, String op, String progress) {
  if (lastReadTerminal == null) {
    throw new Exception(
        "the ($op) operator must be preceded by a terminal ( $progress )");
  }
}
