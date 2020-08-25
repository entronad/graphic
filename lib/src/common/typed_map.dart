import 'package:graphic/src/util/map.dart' as map_util;

mixin TypedMap {
  final Map<String, Object> _map = {};

  TypedMap mix(TypedMap src) {
    if (src != null) {
      _map.addAll(src._map);
    }
    return this;
  }

  TypedMap deepMix(
    TypedMap src,
    {int maxLevel = map_util.defaultDeepMixMaxLevel,
    int currentLevel = 0,}
  ) {
    if (src == null) {
      return this;
    }

    for (var key in src._map.keys) {
      final value = src._map[key];
      
      if (_map[key] is TypedMap) {
        if (currentLevel < maxLevel) {
          _map[key] = (_map[key] as TypedMap).deepMix(value, maxLevel: maxLevel, currentLevel: currentLevel + 1);
        } else {
          _map[key] = value;
        }
      } else if(_map[key] is Map) {
        if (currentLevel < maxLevel) {
          map_util.deepMix(_map[key], value, maxLevel: maxLevel, currentLevel: currentLevel + 1);
        } else {
          _map[key] = value;
        }
      } else {
        _map[key] = value;
      }
    }

    return this;
  }

  Iterable<String> get keys => _map.keys;

  Object operator [](String k) => _map[k];

  void operator []=(String k, Object v) => v == null ? _map.remove(k) : _map[k] = v;

  void clear() => _map.clear();
}
