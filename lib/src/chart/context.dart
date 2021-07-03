import 'view.dart';

/// To store the parsing results.
class Context {
  Context(this._view);

  View _view;

  /// Mount all [Desc]s from a [Scope].
  Context mount(Scope) {
    return this;
  }
}
