import 'package:collection/collection.dart';
import 'package:graphic/src/event/event.dart';


abstract class Selection {
  Selection({
    this.variables,
    this.on,
    this.clear,
  });

  final List<String>? variables;

  final Set<EventType>? on;

  final Set<EventType>? clear;

  @override
  bool operator ==(Object other) =>
    other is Selection &&
    DeepCollectionEquality().equals(variables, other.variables) &&
    DeepCollectionEquality().equals(on, other.on) &&
    DeepCollectionEquality().equals(clear, other.clear);
}
