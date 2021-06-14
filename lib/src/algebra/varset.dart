import 'dart:math';
import 'package:collection/collection.dart';

import 'package:graphic/src/parse/spec.dart';

/// The reversed tag for unity varset.
const _unityTag = '1';

Varset _normalize(Varset varset) {
  var maxOrder = 0;
  for (var term in varset._form) {
    maxOrder = max(maxOrder, term.length);
  }
  for (var term in varset._form) {
    if (term.length < maxOrder) {
      term
        ..length = maxOrder
        ..fillRange(term.length, maxOrder, _unityTag);
    }
  }
  return varset;
}

/// To store the tags.
/// The term is directly composed of tags, whitch are numerators of factors.
/// Nesting denominators is not supported now.
typedef _Term = List<String>;

/// Expressions(monomial or polynomial) will be automatically convert to forms when calculated.
/// tag -> term -> form
typedef _Form = List<_Term>;

/// Since faciting is not supported, nest operator is not supported.
class Varset extends Spec {
  Varset(String tag) : _form = [[tag]];

  Varset.unity() : _form = [[_unityTag]];

  Varset._from(Varset source)
    : _form = source._form.map(
      (term) => [...term],
    ).toList();

  Varset._empty() : _form = [];

  final _Form _form;

  List<List<String>> get variablesByDim {
    final rst = <List<String>>[];
    for (var term in _form) {
      for (var i = 0; i < term.length; i++) {
        if (rst.length < term.length) {
          rst.add([]);
        }
        rst[i].add(term[i]);
      }
    }
    return rst;
  }

  bool operator ==(Object other) =>
    other is Varset &&
    DeepCollectionEquality().equals(_form, other._form);

  /// The blend operator in the graphics algebra.
  /// Append all terms and normalize the orders.
  /// This will generate a new Varset.
  Varset operator +(Varset other) {
    final rst = Varset._from(this);
    rst._form.addAll(other._form);

    return _normalize(rst);
  }

  /// The corss operator in the graphics algebra.
  /// Cartisien production of two froms.
  /// This will generate a new Varset.
  Varset operator *(Varset other) {
    final rst = Varset._empty();
    for (var a in _form) {
      for (var b in other._form) {
        rst._form.add([...a, ...b]);
      }
    }

    // A form cross another form is a form.
    return rst;
  }
}
