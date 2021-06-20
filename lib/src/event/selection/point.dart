import 'package:graphic/src/event/event.dart';

import 'base.dart';

class PointSelection extends Selection {
  PointSelection({
    this.toggle,
    this.nearest,

    List<String>? variables,
    Set<EventType>? on,
    Set<EventType>? clear,
  }) : super(
    variables: variables,
    on: on,
    clear: clear,
  );

  final bool? toggle;

  final bool? nearest;

  @override
  bool operator ==(Object other) =>
    other is PointSelection &&
    super == other &&
    toggle == other.toggle &&
    nearest == other.nearest;
}
