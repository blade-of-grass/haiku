class StateMachine<T> {
  int _state;
  static const _START_STATE = 0;

  Map<int, Map<T, int>> _statesAndTransitions = {
    _START_STATE: {},
  };

  StateMachine.parseGrammar(String grammar, Map<String, T> terminalMappings) {
    int state = _START_STATE;
    bool recordStartStates = true;
    var starts = <int, T>{};
    var context = <int>{};
    var previousStates = <int>{_START_STATE};

    T previousTerminal;
    String progress = '';

    grammar.runes.forEach((rune) {
      String symbol = String.fromCharCode(rune);
      progress += symbol;

      // TERMINALS
      if (terminalMappings.containsKey(symbol)) {
        // if the previous terminal isn't null, that means it was required
        // in this case we should clear `previousStates` to all except the required state
        if (previousTerminal != null) {
          previousStates = <int>{state};
          recordStartStates = false;
        }

        // move to the next state, read the terminal associated with the symbol
        ++state;
        T terminal = terminalMappings[symbol];
        _statesAndTransitions[state] = {};

        // create a transition on the read terminal from previous states to the new one
        // we look back at previous states since some may be optional
        // this gives us the capability to "skip" these optional states
        previousStates
            .forEach((s) => _statesAndTransitions[s][terminal] = state);

        // record the current state as a starting state of a production if it is indeed one
        if (recordStartStates) {
          starts[state] = terminal;
        }

        previousTerminal = terminal;
        previousStates.add(state);
      }
      // REPEAT (*) operator
      else if (symbol == '*') {
        checkValidity(previousTerminal, '*', progress);
        _statesAndTransitions[state][previousTerminal] = state;
        previousTerminal = null;
      }
      // OPTIONAL (?) operator
      else if (symbol == '?') {
        checkValidity(previousTerminal, '?', progress);
        previousTerminal = null;
      }
      // OR (+) operator
      else if (symbol == '+') {
        if (previousStates.difference(context).isEmpty) {
          throw new Exception(
              'the (+) operator must be preceded by a production ( $progress )');
        }
        recordStartStates = true;

        // if `previousTerminal` was null then `previousStates` are all optional
        // otherwise, `state` is a required transition to complete the production preceding the (+) operator
        if (previousTerminal == null) {
          // since `previousStates` are optional, we can add them to `context`
          context = context.union(previousStates);
          previousStates = <int>{_START_STATE};
        } else {
          // since `state` is required for the completion of the production, only it is added to context
          context.add(state);
          previousStates = <int>{_START_STATE};
        }
      }
      // unrecognized symbol
      else if (symbol != ' ') {
        throw new Exception('symbol ($symbol) not recognized ( $progress )');
      }
    });

    // after the grammar is fully scanned, merge `previousStates` with `context`
    // iterate through the start states of each production
    // create a transition from each final state to each start state on the input symbol used to reach that start state
    context.union(previousStates).forEach((finalState) {
      starts.forEach((state, terminal) {
        _statesAndTransitions[finalState][terminal] = state;
      });
    });
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
