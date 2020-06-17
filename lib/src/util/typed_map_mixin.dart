import 'collection.dart' as collection;

mixin TypedMapMixin {
  final Map<String, Object> _map = {};

  TypedMapMixin mix(TypedMapMixin src) {
    if (src != null) {
      _map.addAll(src._map);
    }
    return this;
  }

  TypedMapMixin deepMix(TypedMapMixin src) {
    if (src != null) {
      for (var key in src._map.keys) {
        final value = src._map[key];
        if (_map[key] is TypedMapMixin) {
          _map[key] = (_map[key] as TypedMapMixin).deepMix(value);
        } else if(_map[key] is Map) {
          collection.deepMix(_map[key], value);
        } else {
          _map[key] = value;
        }
      }
    }
    return this;
  }

  Iterable<String> get keys => _map.keys;

  Object operator [](String k) => _map[k];

  void operator []=(String k, Object v) => v == null ? _map.remove(k) : _map[k] = v;
}
