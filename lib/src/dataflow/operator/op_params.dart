/// An Map-like class to store the operator parameters.
/// Can indicate the modifed fields
class OpParams {
  final _payload = <String, dynamic>{};
  final _mod = <String>{};

  dynamic operator [](String key) =>
    _payload[key];

  OpParams set(
    String name,
    dynamic value,
    {bool force = false,}
  ) {
    final v = _payload[name];
    if (v != value || force) {
      _payload[name] = value;
      _mod.add(name);
    }
    
    return this;
  }

  bool modified([String? name]) =>
    name == null
      ? _mod.isNotEmpty
      : _mod.contains(name);

  OpParams clear() {
    _mod.clear();
    return this;
  }
}
