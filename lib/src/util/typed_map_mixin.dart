mixin TypedMapMixin {
  final Map<String, Object> _map = {};

  TypedMapMixin mix(TypedMapMixin src) {
    if (src != null) {
      this._map.addAll(src._map);
    }
    return this;
  }

  Iterable<String> get keys => _map.keys;

  Object operator [](String k) => _map[k];

  void operator []=(String k, Object v) => v == null ? _map.remove(k) : _map[k] = v;
}
