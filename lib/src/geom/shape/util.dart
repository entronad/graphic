import 'dart:ui' show Offset;

List<Offset> splitPoints(List<double> x, List<double> y) {
  final points = <Offset>[];
  for (var i = 0; i < y.length; i++) {
    final xValue = x.length > 1 ? x[i] : x.first;
    points.add(Offset(xValue, y[i]));
  }
  return points;
}

List<List<Map<String, Object>>> spliteArray(
  List<Map<String, Object>> data,
  String yField,
  bool connectNulls,
) {
  if (data.isEmpty) {
    return [];
  }
  final arr = <List<Map<String, Object>>>[];
  var tmp = <Map<String, Object>>[];
  List<Object> yValue;
  for (var obj in data) {
    final origin = obj['_origin'] as Map<String, Object>;
    yValue = origin != null ? origin[yField] : obj[yField];
    if (connectNulls) {
      if (yValue == null) {
        tmp.add(obj);
      }
    } else {
      if (yValue == null || yValue.first == null) {
        if (tmp.isNotEmpty) {
          arr.add(tmp);
          tmp = [];
        }
      } else {
        tmp.add(obj);
      }
    }
  }

  if (tmp.isNotEmpty) {
    arr.add(tmp);
  }

  return arr;
}
