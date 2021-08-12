import 'package:graphic/graphic.dart';

/// Namespace conflication test.
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';

/// https://google.github.io/charts/flutter/example/pie_charts/simple

class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}

final data1 = [
  LinearSales(0, 100),
  LinearSales(1, 75),
  LinearSales(2, 25),
  LinearSales(3, 5),
];

final chart1 = Chart(
  data: {'data': DataSet<LinearSales>(
    source: data1,
    variables: {
      'year': Variable(accessor: (d) => d.year.toString()),
      'sales': Variable(accessor: (d) => d.sales),
    },
    transforms: [Proportion(
      variable: 'sales',
      as: 'salesP',
    )]
  )},
  coord: PolarCoord(dim: 1),
  elements: [IntervalElement(
    position: Varset('salesP'),
  )],
);

/// https://echarts.apache.org/examples/zh/editor.html?c=area-stack-gradient

final data2 = [
  {'day': '周一', 'value': 140, 'group': 1},
  {'day': '周二', 'value': 232, 'group': 1},
  {'day': '周三', 'value': 101, 'group': 1},
  {'day': '周四', 'value': 264, 'group': 1},
  {'day': '周五', 'value': 90, 'group': 1},
  {'day': '周六', 'value': 340, 'group': 1},
  {'day': '周日', 'value': 250, 'group': 1},
  {'day': '周一', 'value': 120, 'group': 2},
  {'day': '周二', 'value': 282, 'group': 2},
  {'day': '周三', 'value': 111, 'group': 2},
  {'day': '周四', 'value': 234, 'group': 2},
  {'day': '周五', 'value': 220, 'group': 2},
  {'day': '周六', 'value': 340, 'group': 2},
  {'day': '周日', 'value': 310, 'group': 2},
  {'day': '周一', 'value': 320, 'group': 3},
  {'day': '周二', 'value': 132, 'group': 3},
  {'day': '周三', 'value': 201, 'group': 3},
  {'day': '周四', 'value': 334, 'group': 3},
  {'day': '周五', 'value': 190, 'group': 3},
  {'day': '周六', 'value': 130, 'group': 3},
  {'day': '周日', 'value': 220, 'group': 3},
  {'day': '周一', 'value': 220, 'group': 4},
  {'day': '周二', 'value': 402, 'group': 4},
  {'day': '周三', 'value': 231, 'group': 4},
  {'day': '周四', 'value': 134, 'group': 4},
  {'day': '周五', 'value': 190, 'group': 4},
  {'day': '周六', 'value': 230, 'group': 4},
  {'day': '周日', 'value': 120, 'group': 4},
  {'day': '周一', 'value': 220, 'group': 5},
  {'day': '周二', 'value': 302, 'group': 5},
  {'day': '周三', 'value': 181, 'group': 5},
  {'day': '周四', 'value': 234, 'group': 5},
  {'day': '周五', 'value': 210, 'group': 5},
  {'day': '周六', 'value': 290, 'group': 5},
  {'day': '周日', 'value': 150, 'group': 5},
];

final chart2 = Chart(
  data: {'data': DataSet<Map>(
    source: data2,
    variables: {
      'day': Variable<Map, String>(
        accessor: (datum) => (datum['day'] as String),
        scale: OrdinalScale(),
      ),
      'value': Variable<Map, num>(
        accessor: (datum) => (datum['value'] as num),
        scale: LinearScale(),
      ),
      'group': Variable<Map, String>(
        accessor: (datum) => (datum['group'].toString()),
        scale: OrdinalScale(),
      ),
    }
  )},
  elements: [AreaElement(
    position: Varset('day') * Varset('value'),
    gradient: GradientAttr(
      variable: 'group',
      values: [
        LinearGradient(
          begin: Alignment(0, 0),
          end: Alignment(0, 1),
          colors: [Color.fromARGB(255, 128, 255, 165), Color.fromARGB(255, 1, 191, 236)],
        ),
        LinearGradient(
          begin: Alignment(0, 0),
          end: Alignment(0, 1),
          colors: [Color.fromARGB(255, 0, 221, 255), Color.fromARGB(255, 77, 119, 255)],
        ),
        LinearGradient(
          begin: Alignment(0, 0),
          end: Alignment(0, 1),
          colors: [Color.fromARGB(255, 55, 162, 255), Color.fromARGB(255, 116, 21, 219)],
        ),
        LinearGradient(
          begin: Alignment(0, 0),
          end: Alignment(0, 1),
          colors: [Color.fromARGB(255, 255, 0, 135), Color.fromARGB(255, 135, 0, 157)],
        ),
        LinearGradient(
          begin: Alignment(0, 0),
          end: Alignment(0, 1),
          colors: [Color.fromARGB(255, 255, 191, 0), Color.fromARGB(255, 224, 62, 76)],
        ),
      ],
      onSelection: {
        's': {false: (init) => LinearGradient(
          begin: Alignment(0, 0),
          end: Alignment(0, 1),
          colors: init.colors.map((c) => c.withAlpha(40)).toList(),
        )},
      },
    ),
    modifier: StackModifier(),
  )],
  selections: {'s': PointSelection(
    variables: ['group'],
    nearest: true,
  )},
);
