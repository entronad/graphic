import 'dart:math';

import 'package:graphic/src/common/reserveds.dart';
import 'package:graphic/src/util/collection.dart';

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

  /// Normalizes this form.
  ///
  /// The terms will be filled with [Reserveds.unitTag] for missing factors.
  void _normalize() {
    var maxOrder = 0;
    for (var term in this) {
      maxOrder = max(maxOrder, term.length);
    }
    for (var term in this) {
      if (term.length < maxOrder) {
        term
          ..length = maxOrder
          ..fillRange(term.length, maxOrder, Reserveds.unitTag);
      }
    }
  }
}

/// To define a varset.
///
/// Varset means variable set in graphics algebra. Varsets, connected with operators,
/// create an algebra expression.
///
/// The algebra specifies how variable sets construct the plane frame, such as how
/// they are assigned to dimensions and how tuples are grouped.
///
/// There are three operators in graphics algebra:
///
/// - [*], called **cross**, which assigns varsets to different dimensions (Usually
/// x and y) in order.
///
/// - [+], called **blend**, which assigns varsets to a same dimension in order.
/// The meaning of the variables respectively in that dimension is determined by
/// geometry type.
///
/// - [/], called **nest**, which groups all tuples by the right varset. Grouping
/// is used for faceting, collision modifiers, or seperating lines or areas. The
/// nesting variables should be discrete.
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
/// A line chart of `sales` in every `day`, but different `category`s in different
/// lines:
///
/// ```dart
/// Varset('day') * Varset('sales') / Varset('category')
/// ```
///
/// The operators are associative and distributive, but not commutative (Because
/// the assigning is in order):
///
/// ```dart
/// Varset('x') * Varset('y') * Varset('z') == Varset('x') * (Varset('y') * Varset('z'))
/// Varset('x') + Varset('y') + Varset('z') == Varset('x') + (Varset('y') + Varset('z'))
/// Varset('x') / Varset('y') / Varset('z') == Varset('x') / (Varset('y') / Varset('z'))
///
/// Varset('x') * (Varset('y') + Varset('z')) == Varset('x') * Varset('y') + Varset('x') * Varset('z')
/// (Varset('x') + Varset('y')) * Varset('z') == Varset('x') * Varset('z') + Varset('y') * Varset('z')
/// Varset('x') / (Varset('y') + Varset('z')) == Varset('x') / Varset('y') + Varset('x') / Varset('z')
/// (Varset('x') + Varset('y')) / Varset('z') == Varset('x') / Varset('z') + Varset('y') / Varset('z')
///
/// Varset('x') * Varset('y') != Varset('y') * Varset('x')
/// Varset('x') + Varset('y') != Varset('y') + Varset('x')
/// Varset('x') / Varset('y') != Varset('y') / Varset('x')
/// ```
///
/// Return type of the two operators is also [Varset], thus a whole algebra expression
/// is also [Varset] type.
///
/// *Note that this algebra is derived from the Grammer of Graphics. For easy understanding,
/// explainations above are not strict definitions.*
class Varset {
  /// Creates a varset with the variable name.
  Varset(String tag)
      : form = [
          [tag]
        ],
        nested = null,
        nesters = [];

  /// Creates a unity varset.
  ///
  /// A unity varset is a placeholder in dimension assigning, it represents no variable.
  Varset.unity()
      : form = [
          [Reserveds.unitTag]
        ],
        nested = null,
        nesters = [];

  /// Creates a varset with properties.
  Varset._create(
    this.form, [
    this.nested,
    this.nesters = const [],
  ]) : assert((nested == null && nesters.isEmpty) ||
            (nested != null && nesters.isNotEmpty));

  /// The numerator part of the algebra expression.
  ///
  /// The operators guarantee that the expression is an algebracal form.
  final AlgForm form;

  /// The nested part.
  final AlgForm? nested;

  /// The nesters.
  final List<AlgForm> nesters;

  @override
  bool operator ==(Object other) =>
      other is Varset &&
      deepCollectionEquals(form, other.form) &&
      deepCollectionEquals(nested, other.nested) &&
      deepCollectionEquals(nesters, other.nesters);

  /// The nest operator.
  ///
  /// Nesting groups all tuples by the right varset. Grouping is used for faceting,
  /// collision modifiers, or seperating lines or areas. The nesting variables should
  /// be discrete.
  Varset operator /(Varset other) {
    // It creates a factor:
    //
    // - [form], uses the left.
    // - [nested], uses the left.
    // - [nesters], appends all right ones to the left ones, and deduplicates.

    final formRst = form;
    final nestedRst = form;
    final nestersRst = ([...nesters, other.form, ...other.nesters]);
    return Varset._create(
      formRst,
      nestedRst,
      nestersRst,
    );
  }

  /// The cross operator.
  ///
  /// Crossing assigns varsets to different dimensions (Usually x and y) in order.
  Varset operator *(Varset other) {
    // It creates a term:
    //
    // - [form], cartisian products left and right.
    // - [nested], if only one has, uses that one; if both has, throws an error.
    // - [nesters], the same as [nested].

    final AlgForm formRst = [];
    // Cartisien production of two froms, which is also a form.
    for (var a in form) {
      for (var b in other.form) {
        formRst.add([...a, ...b]);
      }
    }

    AlgForm? nestedRst;
    List<AlgForm> nestersRst = [];
    if (nested == null) {
      nestedRst = other.nested;
      nestersRst = other.nesters;
    } else {
      // nested != null.

      if (other.nested == null) {
        nestedRst = nested;
        nestersRst = nesters;
      } else {
        throw ArgumentError('Two nested operands can not cross');
      }
    }

    return Varset._create(
      formRst,
      nestedRst,
      nestersRst,
    );
  }

  /// The blend operator.
  ///
  /// Blending assigns varsets to a same dimension in order. The meaning of the
  /// variables respectively in that dimension is determined by geometry type.
  Varset operator +(Varset other) {
    // It creates a polynomial:
    //
    // - [form], append all right form terms to the left ones, normalizes the form,
    // and deduplicates.
    // - [nested], only for distributivity, if nesteds are same, uses that nested,
    // makes sure two nesters are single, appends the two single nesters, normalizes,
    // and deduplicates; if nested are different, makes sure two nesters are same
    // and uses that nesters, appends two nesteds, nomalizes and deduplicaates.
    // - [nesters], see in [nested].

    final AlgForm formRst = (<AlgTerm>[...form, ...other.form].._normalize())
        .collectionItemDeduplicate();

    AlgForm? nestedRst;
    List<AlgForm> nestersRst = [];
    if (nested == null && other.nested == null) {
      // Does nothing.
    } else if (deepCollectionEquals(nested, other.nested)) {
      // Right distributivity: x / y + x / z = x / (y + z).

      nestedRst = nested;
      final leftNester = nesters.single;
      final rightNester = other.nesters.single;
      nestersRst = [
        ([...leftNester, ...rightNester].._normalize())
            .collectionItemDeduplicate()
      ];
    } else {
      // nested != other.nested

      final leftNester = nesters.single;
      final rightNester = other.nesters.single;
      if (deepCollectionEquals(leftNester, rightNester)) {
        // Left distributivity: x / z + y / z = (x + y) / z.

        nestedRst = ([...nested!, ...other.nested!].._normalize())
            .collectionItemDeduplicate();
        nestersRst = nesters;
      } else {
        throw ArgumentError(
            'Two nested operands without distributivity can not blend');
      }
    }

    return Varset._create(
      formRst,
      nestedRst,
      nestersRst,
    );
  }
}
