import 'package:graphic/src/common/typed_map.dart';

const defaultDeepMixMaxLevel = 10;

Map deepMix(
  Map dist,
  Map src,
  {int maxLevel = 5,
  int currentLevel = 0,}
) {
  if (src == null) {
    return dist;
  }

  for (var key in src.keys) {
    final value = src[key];
    if (dist[key] is Map) {
      if (currentLevel < maxLevel) {
        deepMix(dist[key], value, maxLevel: maxLevel, currentLevel: currentLevel + 1);
      } else {
        dist[key] = src[key];
      }
    } else if(dist[key] is TypedMap) {
      if (currentLevel < maxLevel) {
        dist[key] = dist[key].deepMix(value, maxLevel: maxLevel, currentLevel: currentLevel);
      } else {
        dist[key] = src[key];
      }
    } else {
      dist[key] = value;
    }
  }

  return dist;
}
