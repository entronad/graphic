import 'typed_map_mixin.dart';

List<Map<String, Object>> flattern(List<List<Map<String, Object>>> dataArray) {
  final rst = <Map<String, Object>>[];
  for (var data in dataArray) {
    rst.addAll(data);
  }
  return rst;
}

Map<String, List<Map<String, Object>>> groupToMap(List<Map<String, Object>> data, [List<String> fields]) {
  if (fields == null) {
    return {
      '0': data,
    };
  }

  final callback = (Map<String, Object> row) {
    var unique = '_';
    for (var i = 0, l = fields.length; i < l; i++) {
      unique += row[fields[i]]?.toString();
    }
    return unique;
  };

  final groups = <String, List<Map<String, Object>>>{};
  for (var i = 0, len = data.length; i < len; i++) {
    final row = data[i];
    final key = callback(row);
    if (groups[key] != null) {
      groups[key].add(row);
    } else {
      groups[key] = [row];
    }
  }

  return groups;
}

List<List<Map<String, Object>>> group(
  List<Map<String, Object>> data,
  [List<String> fields,
  Map<String, List<Object>> appendConditions = const <String, List<Object>>{}]
) {
  if (fields == null) {
    return [data];
  }
  final groups = groupToMap(data, fields);
  final array = <List<Map<String, Object>>>[];
  if (fields?.length == 1 && (appendConditions[fields[0]] != null)) {
    final values = appendConditions[fields[0]];
    values.forEach((value) {
      value = '_' + value.toString();
      array.add(groups[value]);
    });
  } else {
    for (var i in groups.keys) {
      array.add(groups[i]);
    }
  }

  return array;
}

List<T> uniq<T>(List<T> arr) {
  final rst = <T>[];
  for (var item in arr) {
    if (!rst.contains(item)) {
      rst.add(item);
    }
  }
  return rst;
}

void deepMix(Map dist, Map src, [int level = 0]) {
  const maxLevel = 5;
  for (final key in src.keys) {
    final value = src[key];
    if (value is Map) {
      if (!(dist[key] is Map)) {
        dist[key] = {};
      }
      if (level < maxLevel) {
        deepMix(dist[key], value, level + 1);
      } else {
        dist[key] = src[key];
      }
    } else if(value is TypedMapMixin) {
      dist[key] = dist[key].deepMix(value);
    } else if(value is List) {
      dist[key] = [...value];
    } else if(value != null) {
      dist[key] = value;
    }
  }
}

Object firstValue(List<Map<String, Object>> data, String name) {
  Object rst;
  for (var obj in data) {
    final value = obj[name];
    if (value != null) {
      if (value is List) {
        rst = value.first;
      } else {
        rst = value;
      }
      break;
    }
  }
  return rst;
}

List values(List<Map<String, Object>> data, String name) {
  final rst = [];
  final tmpMap = <Object, bool>{};
  for (var obj in data) {
    final value = obj[name];
    if (value != null) {
      if (!tmpMap[value]) {
        rst.add(value);
        tmpMap[value] = true;
      }
    } else {
      for (var val in value) {
        if (!tmpMap[val]) {
          rst.add(val);
          tmpMap[val] = true;
        }
      }
    }
  }
  return rst;
}
