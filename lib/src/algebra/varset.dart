import 'dart:math';

import 'package:collection/collection.dart';
import 'package:graphic/src/common/reserveds.dart';

/// Normalizes a varset's expression to a algebracal form.
///
/// The terms will be filled with [Reserveds.unitTag] for missing factors.
Varset _normalize(Varset varset) {
  var maxOrder = 0;
  for (var term in varset.form) {
    maxOrder = max(maxOrder, term.length);
  }
  for (var term in varset.form) {
    if (term.length < maxOrder) {
      term
        ..length = maxOrder
        ..fillRange(term.length, maxOrder, Reserveds.unitTag);
    }
  }
  return varset;
}

/// The term composing algebracal forms.
///
/// The list items are tags representing the factor variables.
///
/// See also:
///
/// - [AlgForm], composed of terms.
typedef AlgTerm = List<String>;

/// The algebracal form storing the expression of a varset.
///
/// A form is an algebra expression whose all items have same orders. Operators
/// of [Varset] guarantee the results are forms.
///
/// List wrapping is `form[term[tag]]]`.
///
/// See also:
///
/// - [Varset], which uses a form to store its expression.
typedef AlgForm = List<AlgTerm>;

extension AlgFormExt on AlgForm {
  /// Gets variables in list of dimensions.
  List<List<String>> get variablesByDim {
    final rst = <List<String>>[];
    for (var term in this) {
      for (var i = 0; i < term.length; i++) {
        if (rst.length < term.length) {
          rst.add([]);
        }
        rst[i].add(term[i]);
      }
    }
    return rst;
  }
}

/// To define a varset.
///
/// Varset means variable set in graphic algebra. Varsets, connected with operators,
/// create an algebra expression. The algebra expression specifies how variable
/// values are assigned to position dimensions. There are 2 operators for now:
///
/// - [*], called **cross**, which assigns variables to different dimensions (Usually
/// x and y) in order.
///
/// - [+], called **blend**, which assigns variables to a same dimension in order.
/// The meaning of the variables respectively in that dimension is determined by
/// geometory type.
///
/// For example:
///
/// A `name` variable for x and a `score` varable for y:
///
/// ```dart
/// Varset('name') * Varset('score')
/// ```
///
/// A `date` variable for x, and y is a bar between minimum price (variable `min`)
/// and maximum price (variable `max`):
///
/// ```dart
/// Varset('date') * (Varset('min') + Varset('max'))
/// ```
///
/// The two operators are associative and distributive, but not commutative (Because
/// the assigning is in order):
///
/// ```dart
/// Varset('date') * (Varset('min') + Varset('max')) == Varset('date') * Varset('min') + Varset('date') * Varset('max')
/// Varset('name') * Varset('score') != Varset('score') * Varset('name')
/// Varset('min') + Varset('max') != Varset('max') + Varset('min')
/// ```
///
/// Return type of the two operators is also [Varset], thus a whole algebra expression
/// is also [Varset] type.
///
/// Note that this algebra is derived from the Grammer of Graphics. For easy understanding,
/// explainations above are not strict definitions. Because facets are not supported
/// for now, the nest([/]) operator is not provided.
class Varset {
  /// Creates a varset with the variable name.
  Varset(String tag)
      : form = [
          [tag]
        ];

  /// Creates a unity varset.
  ///
  /// A unity varset is a placeholder in dimension assigning, it represents no variable.
  Varset.unity()
      : form = [
          [Reserveds.unitTag]
        ];

  /// Creates a same varset from another one.
  Varset._from(Varset source)
      : form = source.form
            .map(
              (term) => [...term],
            )
            .toList();

  /// Creates an empty varset.
  Varset._empty() : form = [];

  /// The storage of the algebra expression.
  ///
  /// The operators guarantee that the expression is an algebracal form.
  final AlgForm form;

  @override
  bool operator ==(Object other) =>
      other is Varset && DeepCollectionEquality().equals(form, other.form);

  /// The blend operator.
  Varset operator +(Varset other) {
    // The result is a new varset instance.
    final rst = Varset._from(this);
    // Apends all terms.
    rst.form.addAll(other.form);

    // Normalize the result to guarentee a form.
    return _normalize(rst);
  }

  /// The cross operator.
  Varset operator *(Varset other) {
    // The result is a new varset instance.
    final rst = Varset._empty();
    // Cartisien production of two froms, which is also a form.
    for (var a in form) {
      for (var b in other.form) {
        rst.form.add([...a, ...b]);
      }
    }

    return rst;
  }
}
