import 'dart:math';

import 'package:collection/collection.dart';

/// The reversed tag for unity varset.
const _unityTag = '1';

Varset _normalize(Varset varset) {
  var maxOrder = 0;
  for (var term in varset.form) {
    maxOrder = max(maxOrder, term.length);
  }
  for (var term in varset.form) {
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
typedef AlgTerm = List<String>;

/// Expressions(monomial or polynomial) will be automatically convert to forms when calculated.
/// tag -> term -> form
typedef AlgForm = List<AlgTerm>;

/// Since faciting is not supported, nest operator is not supported.
class Varset {
  Varset(String tag)
    : assert(tag != _unityTag),
      form = [[tag]];

  Varset.unity() : form = [[_unityTag]];

  Varset._from(Varset source)
    : form = source.form.map(
      (term) => [...term],
    ).toList();

  Varset._empty() : form = [];

  final AlgForm form;

  @override
  bool operator ==(Object other) =>
    other is Varset &&
    DeepCollectionEquality().equals(form, other.form);

  /// The blend operator in the graphics algebra.
  /// Append all terms and normalize the orders.
  /// This will generate a new Varset.
  Varset operator +(Varset other) {
    final rst = Varset._from(this);
    rst.form.addAll(other.form);

    return _normalize(rst);
  }

  /// The corss operator in the graphics algebra.
  /// Cartisien production of two froms.
  /// This will generate a new Varset.
  Varset operator *(Varset other) {
    final rst = Varset._empty();
    for (var a in form) {
      for (var b in other.form) {
        rst.form.add([...a, ...b]);
      }
    }

    // A form cross another form is a form.
    return rst;
  }
}
