class Parameters {
  final Map<String, Object> _values = {};
  final Map<String, int> _mod = {};

  Map<String, Object> get values => _values;

  Parameters set(
    String name,
    Object value,
    [bool force = false]
  ) {
    final v = _values[name];
    if (v != value || force) {
      _values[name] = value;
      _mod[name] = (value is List) ? 1 + value.length : -1;
    }
    
    return this;
  }

  Parameters setListItem(
    String name,
    int index,
    Object value,
    [bool force = false]
  ) {
    final v = _values[name] as List;
    if (v[index] != value || force) {
      v[index] = value;
      _mod['$index:$name'] = -1;
      _mod[name] = -1;
    }

    return this;
  }

  bool get modifiedAny => _mod.isNotEmpty;

  bool modified(String name) => _mod.keys.contains(name);

  bool modifiedListItem(String name, int index) {
    assert(index >= 0);
    final v = _mod[name];
    if (v == null) {
      return false;
    }
    return index + 1 < v || _mod.keys.contains('$index:$name');
  }

  Parameters clear() {
    _mod.clear();
    return this;
  }
}
