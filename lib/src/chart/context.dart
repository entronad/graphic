import 'view.dart';

/// To store the parsing results.
class Context {
  Context(this._controller);

  View _controller;

  /// Mount all [Desc]s from a [Scope].
  Context mount(Scope) {
    return this;
  }
}
