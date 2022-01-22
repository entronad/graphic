import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:graphic/src/interaction/signal.dart';

import 'dataflow.dart';

/// The base class of operators.
///
/// An operator is a processing node in a dataflow graph. Each operator stores a
/// value of type [V]. Operators can accept a map of named parameters. Parameter
/// values can either be direct or indirect (other operators whose values will be
/// pulled dynamically). Operators included as parameters will have this operator
/// added as a target.
abstract class Operator<V> {
  Operator([
    Map<String, dynamic>? params,
    this.value,
  ]) {
    if (params != null) {
      for (var name in params.keys) {
        final source = params[name];
        if (source is Operator) {
          // An inderect operator parameter will be registered in sources and have
          // this operator added as a target.

          source.targets.add(this);
          sources[name] = source;
        } else {
          // A direct parameter will be stored in params.

          this.params[name] = source;
        }
      }
    }
  }

  /// The operator value.
  /// 
  /// Whether the operator value is nullable should be included in the generic [V].
  /// This property is nullable for it may not be initialized.
  @protected
  V? value;

  /// Whether this operator needs a initial touch when added.
  /// 
  /// Some operators have inital value or can't be touched.
  bool get needInitialTouch => true;

  /// Parameter values set directly or pulled inderectly.
  @protected
  final params = <String, dynamic>{};

  /// Souce operators that the inderect parameters depend on.
  ///
  /// When a source operator is modified, this operator will reevaluate.
  final Map<String, Operator> sources = {};

  /// Target operators that accept this operator's [value] as a parameter.
  ///
  /// When this operator is modifiend, target operators will reevaluate.
  final Set<Operator> targets = {};

  /// The rank of this operator in the [Dataflow]'s evaluation heap.
  ///
  /// It is the order of added to [Dataflow].
  int rank = -1;

  /// Whether the [value] should be consumed after this pulse.
  ///
  /// It is usefull for transient values like [Signal]s.
  bool get consume => false;

  /// Whether this operator has evaluated in this pulse.
  bool runed = false;

  /// The channel binded to this operator.
  StreamController<V?>? channel;

  /// Pulls parameter values from source operators.
  void _marshall() {
    for (var name in sources.keys) {
      final op = sources[name]!;
      params[name] = op.value;
    }
  }

  /// Runs this operator and returns whether the [value] is modified.
  bool run() {
    if (runed) {
      return false;
    }

    _marshall();
    final modified = update(evaluate());
    if (channel != null && modified) {
      // Only the updates caused by operator.run will emit to it's channel sink.
      // For now, singal channels are noticed by the view, while the selection channel
      // is noticed by it's binded operator.
      channel!.sink.add(value);
    }
    runed = true;
    return modified;
  }

  /// Evaluates the new [value].
  ///
  /// Subclasses should mainly implement this method.
  @protected
  V evaluate();

  /// Checks whether the new [value]s is modifed to the old one.
  ///
  /// This method should be determind by the trait of [V], not the role of this operator.
  @protected
  bool equalValue(V a, V b) => a == b;

  /// Update the operator [value] and returns whether the [value] is modified.
  ///
  /// An operator can only updated by [run] or a Dataflow._update.
  bool update(V newValue) {
    if (value != null && equalValue(value!, newValue)) {
      return false;
    }
    value = newValue;
    return true;
  }
}
