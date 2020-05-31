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
