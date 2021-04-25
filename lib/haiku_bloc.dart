import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:haiku/haiku.dart';

class HaikuBloc extends StatefulWidget {
  final Dictionary dictionary;
  final Widget child;

  HaikuBloc({@required this.child, @required this.dictionary});

  @override
  HaikuBlocState createState() => HaikuBlocState();

  static HaikuBlocState of(BuildContext context) {
    return context.findAncestorStateOfType<HaikuBlocState>();
  }
}

class HaikuBlocState extends State<HaikuBloc> {
  final _stream = StreamController<Haiku>.broadcast();
  Stream<Haiku> get stream => _stream.stream;

  @override
  void initState() {
    super.initState();

    _currentHaiku =
        Haiku(DateTime.now().millisecondsSinceEpoch, this.widget.dictionary);
  }

  Haiku _currentHaiku;
  Haiku get currentHaiku => _currentHaiku;

  void generateHaiku([int seed]) {
    _currentHaiku = Haiku(
        seed ?? DateTime.now().millisecondsSinceEpoch, this.widget.dictionary);
    _stream.add(_currentHaiku);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    this._stream.close();
    super.dispose();
  }
}
