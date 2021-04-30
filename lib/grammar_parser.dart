class StateMachine<T> {
  int _state;
  static const _START_STATE = 0;

  Map<int, Map<T, int>> _statesAndTransitions = {
    _START_STATE: {},
  };

  StateMachine.parseGrammar(String grammar, Map<String, T> terminalMappings) {
    int state = _START_STATE;
    bool recordStarts = true;
    var starts = <int, T>{};
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
          recordStarts = false;
        }
        if (recordStarts) {
          starts[state] = terminal;
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
        recordStarts = true;
        if (previousTerminal == null) {
          context = context.union(previousStates);
          previousStates = {...context};
        } else {
          context.add(state);
          previousStates = <int>{state};
        }
      } else if (symbol != ' ') {
        throw new Exception('symbol ($symbol) not recognized ( $progress )');
      }
    });
    previousStates.union(context).forEach((finalState) {
      starts.forEach((state, terminal) {
        _statesAndTransitions[finalState][terminal] = state;
      });
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
