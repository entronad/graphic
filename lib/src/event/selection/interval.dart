import 'dart:ui';

import 'package:graphic/src/event/event.dart';

import 'selection.dart';

class IntervalSelection extends Selection {
  IntervalSelection({
    this.color,

    List<String>? variables,
    Set<EventType>? clear,
  }) : super(
    variables: variables,
    clear: clear,
  );

  final Color? color;

  @override
  bool operator ==(Object other) =>
    other is IntervalSelection &&
    super == other &&
    color == other.color;
}
