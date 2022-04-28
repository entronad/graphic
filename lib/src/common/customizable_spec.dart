import 'package:flutter/foundation.dart';

/// The base class for Customizable Specifications.
abstract class CustomizableSpec {
  /// Checks the equlity of two specs.
  ///
  /// Equality is very important for specs that a custom spec should override this
  /// method. Usually two specs are equal if they are of the same type and have
  /// same properties.
  ///
  /// It is used by [==].
  @protected
  bool equalTo(Object other);

  @override
  bool operator ==(Object other) => this.equalTo(other);
}
