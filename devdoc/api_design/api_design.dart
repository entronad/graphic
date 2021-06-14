import 'package:flutter/material.dart';

// https://g2.antv.vision/zh/examples/case/column#column2

class AgeDist {
  AgeDist(this.type, this.value);
  String type;
  int value;
}

Chart(
  data: [
    AgeDist('未知', 654),
    AgeDist('17岁以下', 654),
    AgeDist('18-24岁', 4400),
    AgeDist('25-29岁', 5300),
    AgeDist('30-39岁', 6200),
    AgeDist('40-49岁', 3300),
    AgeDist('50岁以上', 1500),
  ],
  variables: {
    'type': Variable<String>(
      acceccor: (datum) => datum.type,
      scale: OrdinalScale(),
    ),
    'value': Variable<num>(
      accessor: (datum) => datum.value,
      scale: LinearScale(),
    ),
  },
  axes: [
    Axis(
      dim: 1,
    ),
  ],
  selections: {
    's': Selection(
      type: SelectionType.point,
      project: ['type'],
      nearest: true,
    ),
  },
  coord: RectCoord(
    horizontalRangeSignal: Signal<List<double>>(
      value: [0,1],
      onEvent: {EventType.scale, Default.horizontalZoom}
    ),
  ),
  elements: [Interval(
    position: PositionAttr(
      algebra: Varset('type') * Varset('value'),
    ),
    label: LabelAttr(
      algebra: Varset('value'),
    ),
    elevation: ElevationAttr(
      selections: {
        Selected('s'): (_) => 5,
      }
    ),
  )],
  tooltip: Tooltip(
    showMarks: false,
  ),
)

// https://echarts.apache.org/examples/zh/editor.html?c=area-stack-gradient

Chart(
  data: [
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
  ],
  variables: {
    'day': Variable<String>(
      accessor: (datum) => (datum['day'] as String),
      scale: OrdinalScale(),
    ),
    'value': Variable<num>(
      accessor: (datum) => (datum['value'] as num),
      scale: LinearScale(),
    ),
    'group': Variable<String>(
      accessor: (datum) => (datum['group'].toString()),
      scale: OrdinalScale(),
    ),
  },
  selections: {
    's': Selection(
      type: SelectionType.point,
      project: ['group'],
      nearest: true,
    ),
  },
  elements: [Area(
    position: PositionAttr(
      algebra: Varset('day') * Varset('value'),
    ),
    gradient: GradientAttr(
      algebra: Varset('group'),
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
      selections: {
        Selected('s'): (g) => g,
        !Selected('s'): (g) => LinearGradient(
          begin: Alignment(0, 0),
          end: Alignment(0, 1),
          colors: g.colors.map((c) => c.withAlpha(0.2)),
        ),
      }
    ),
    modifier: Stack(),
  )]
)

// https://echarts.apache.org/examples/zh/editor.html?c=pie-simple

// transform
Chart(
  data: [
    {'value': 1048, 'name': '搜索引擎'},
    {'value': 735, 'name': '直接访问'},
    {'value': 580, 'name': '邮件营销'},
    {'value': 484, 'name': '联盟广告'},
    {'value': 300, 'name': '视频广告'}
  ],
  variables: {
    'name': Variable<String>(
      accessor: (datum) => (datum['name'] as String),
      scale: OrdinalScale(),
    ),
    'value': Variable<num>(
      accessor: (datum) => (datum['value'] as num),
      scale: LinearScale(),
    ),
    'percent': PercentTrans(
      param: 'value',
      scale: LinearScale(),
    ),
  },
  coord: ThetaCoord(),
  elements: [Interval(
    position: PositionAttr(
      algebra: Varset('percent'),
    ),
    color: ColorAttr(
      algebra: Varset('name'),
    ),
    label: LabelAttr(
      algebra: Varset('value'),
    ),
    modifier: Stack(),
  )],
)

// stat
Chart(
  data: [
    {'value': 1048, 'name': '搜索引擎'},
    {'value': 735, 'name': '直接访问'},
    {'value': 580, 'name': '邮件营销'},
    {'value': 484, 'name': '联盟广告'},
    {'value': 300, 'name': '视频广告'}
  ],
  variables: {
    'name': Variable<String>(
      accessor: (datum) => (datum['name'] as String),
      scale: OrdinalScale(),
    ),
    'value': Variable<num>(
      accessor: (datum) => (datum['value'] as num),
      scale: LinearScale(),
    ),
  },
  coord: ThetaCoord(),
  elements: [Interval(
    position: PositionAttr(
      algebra: Varset('value'),
      stat: ProptionStat(),
    ),
    color: ColorAttr(
      algebra: Varset('name'),
    ),
    label: LabelAttr(
      algebra: Varset('value'),
    ),
    modifier: Stack(),
  )],
)
