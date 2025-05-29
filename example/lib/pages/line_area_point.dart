import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';

import '../data.dart';

final _monthDayFormat = DateFormat('MM-dd');

class LineAreaPointPage extends StatefulWidget {
  const LineAreaPointPage({Key? key}) : super(key: key);

  @override
  State<LineAreaPointPage> createState() => _LineAreaPointPageState();
}

class _LineAreaPointPageState extends State<LineAreaPointPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var _smooth = false;
  var _stepped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Line and Area Mark'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Options',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              CheckboxListTile(
                value: _smooth,
                onChanged: (value) {
                  setState(() {
                    _smooth = value ?? false;
                  });
                },
                title: const Text('Smooth'),
              ),
              CheckboxListTile(
                value: _stepped,
                onChanged: (value) {
                  setState(() {
                    _stepped = value ?? false;
                  });
                },
                title: const Text('Stepped'),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Time series line chart',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Pre-select a point.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Dash line.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- With time scale in domain dimension.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Input data type is a custom class.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- With coordinate region background color.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: timeSeriesSales,
                  variables: {
                    'time': Variable(
                      accessor: (TimeSeriesSales datum) => datum.time,
                      scale: TimeScale(
                        formatter: (time) => _monthDayFormat.format(time),
                      ),
                    ),
                    'sales': Variable(
                      accessor: (TimeSeriesSales datum) => datum.sales,
                    ),
                  },
                  marks: [
                    LineMark(
                      shape: ShapeEncode(value: BasicLineShape(smooth: _smooth, stepped: _stepped, dash: [5, 2])),
                      selected: {
                        'touchMove': {1}
                      },
                    )
                  ],
                  coord: RectCoord(color: const Color(0xffdddddd)),
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {
                    'touchMove': PointSelection(
                      on: {
                        GestureType.scaleUpdate,
                        GestureType.tapDown,
                        GestureType.longPressMoveUpdate
                      },
                      dim: Dim.x,
                    )
                  },
                  tooltip: TooltipGuide(
                    followPointer: [false, true],
                    align: Alignment.topLeft,
                    offset: const Offset(-20, -20),
                  ),
                  crosshair: CrosshairGuide(followPointer: [false, true]),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Area chart',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Line and area will break at NaN.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- A touch moving triggerd selection.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: invalidData,
                  variables: {
                    'Date': Variable(
                      accessor: (Map map) => map['Date'] as String,
                      scale: OrdinalScale(tickCount: 5),
                    ),
                    'Close': Variable(
                      accessor: (Map map) =>
                          (map['Close'] ?? double.nan) as num,
                    ),
                  },
                  marks: [
                    AreaMark(
                      shape: ShapeEncode(value: BasicAreaShape(smooth: _smooth, stepped: _stepped)),
                      color: ColorEncode(
                          value: Defaults.colors10.first.withAlpha(80)),
                    ),
                    LineMark(
                      shape: ShapeEncode(value: BasicLineShape(smooth: _smooth, stepped: _stepped)),
                      size: SizeEncode(value: 0.5),
                    ),
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {
                    'touchMove': PointSelection(
                      on: {
                        GestureType.scaleUpdate,
                        GestureType.tapDown,
                        GestureType.longPressMoveUpdate
                      },
                      dim: Dim.x,
                    )
                  },
                  tooltip: TooltipGuide(
                    followPointer: [false, true],
                    align: Alignment.topLeft,
                    offset: const Offset(-20, -20),
                  ),
                  crosshair: CrosshairGuide(followPointer: [false, true]),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Group interactions',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Select and change color of a whole group',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- The group and tooltip selections are different but triggerd by same gesture.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Different interactions for different devices',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: complexGroupData,
                  variables: {
                    'date': Variable(
                      accessor: (Map map) => map['date'] as String,
                      scale: OrdinalScale(tickCount: 5, inflate: true),
                    ),
                    'points': Variable(
                      accessor: (Map map) => map['points'] as num,
                    ),
                    'name': Variable(
                      accessor: (Map map) => map['name'] as String,
                    ),
                  },
                  coord: RectCoord(horizontalRange: [0.01, 0.99]),
                  marks: [
                    LineMark(
                      position:
                          Varset('date') * Varset('points') / Varset('name'),
                      shape: ShapeEncode(value: BasicLineShape(smooth: _smooth, stepped: _stepped)),
                      size: SizeEncode(value: 0.5),
                      color: ColorEncode(
                        variable: 'name',
                        values: Defaults.colors10,
                        updaters: {
                          'groupMouse': {
                            false: (color) => color.withAlpha(100)
                          },
                          'groupTouch': {
                            false: (color) => color.withAlpha(100)
                          },
                        },
                      ),
                    ),
                    PointMark(
                      color: ColorEncode(
                        variable: 'name',
                        values: Defaults.colors10,
                        updaters: {
                          'groupMouse': {
                            false: (color) => color.withAlpha(100)
                          },
                          'groupTouch': {
                            false: (color) => color.withAlpha(100)
                          },
                        },
                      ),
                    ),
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {
                    'tooltipMouse': PointSelection(on: {
                      GestureType.hover,
                    }, devices: {
                      PointerDeviceKind.mouse
                    }),
                    'groupMouse': PointSelection(
                        on: {
                          GestureType.hover,
                        },
                        variable: 'name',
                        devices: {PointerDeviceKind.mouse}),
                    'tooltipTouch': PointSelection(on: {
                      GestureType.scaleUpdate,
                      GestureType.tapDown,
                      GestureType.longPressMoveUpdate
                    }, devices: {
                      PointerDeviceKind.touch
                    }),
                    'groupTouch': PointSelection(
                        on: {
                          GestureType.scaleUpdate,
                          GestureType.tapDown,
                          GestureType.longPressMoveUpdate
                        },
                        variable: 'name',
                        devices: {PointerDeviceKind.touch}),
                  },
                  tooltip: TooltipGuide(
                    selections: {'tooltipTouch', 'tooltipMouse'},
                    followPointer: [true, true],
                    align: Alignment.topLeft,
                    mark: 0,
                    variables: [
                      'date',
                      'name',
                      'points',
                    ],
                  ),
                  crosshair: CrosshairGuide(
                    selections: {'tooltipTouch', 'tooltipMouse'},
                    styles: [
                      PaintStyle(strokeColor: const Color(0xffbfbfbf)),
                      PaintStyle(strokeColor: const Color(0x00bfbfbf)),
                    ],
                    followPointer: [true, false],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'River chart',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: riverData,
                  variables: {
                    'date': Variable(
                      accessor: (List list) => list[0] as String,
                      scale: OrdinalScale(tickCount: 5),
                    ),
                    'value': Variable(
                      accessor: (List list) => list[1] as num,
                      scale: LinearScale(min: -120, max: 120),
                    ),
                    'type': Variable(
                      accessor: (List list) => list[2] as String,
                    ),
                  },
                  marks: [
                    AreaMark(
                      position:
                          Varset('date') * Varset('value') / Varset('type'),
                      shape: ShapeEncode(value: BasicAreaShape(smooth: true)),
                      color: ColorEncode(
                        variable: 'type',
                        values: Defaults.colors10,
                      ),
                      modifiers: [StackModifier(), SymmetricModifier()],
                    ),
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {
                    'touchMove': PointSelection(
                      on: {
                        GestureType.scaleUpdate,
                        GestureType.tapDown,
                        GestureType.longPressMoveUpdate
                      },
                      dim: Dim.x,
                      variable: 'date',
                    )
                  },
                  tooltip: TooltipGuide(
                    followPointer: [false, true],
                    align: Alignment.topLeft,
                    offset: const Offset(-20, -20),
                    multiTuples: true,
                    variables: ['type', 'value'],
                  ),
                  crosshair: CrosshairGuide(followPointer: [false, true]),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Spider Net Chart',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- A loop connects the first and last point.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: adjustData,
                  variables: {
                    'index': Variable(
                      accessor: (Map map) => map['index'].toString(),
                    ),
                    'type': Variable(
                      accessor: (Map map) => map['type'] as String,
                    ),
                    'value': Variable(
                      accessor: (Map map) => map['value'] as num,
                    ),
                  },
                  marks: [
                    LineMark(
                      position:
                          Varset('index') * Varset('value') / Varset('type'),
                      shape: ShapeEncode(value: BasicLineShape(loop: true)),
                      color: ColorEncode(
                          variable: 'type', values: Defaults.colors10),
                    )
                  ],
                  coord: PolarCoord(),
                  axes: [
                    Defaults.circularAxis,
                    Defaults.radialAxis,
                  ],
                  selections: {
                    'touchMove': PointSelection(
                      on: {
                        GestureType.scaleUpdate,
                        GestureType.tapDown,
                        GestureType.longPressMoveUpdate
                      },
                      dim: Dim.x,
                      variable: 'index',
                    )
                  },
                  tooltip: TooltipGuide(
                    anchor: (_) => Offset.zero,
                    align: Alignment.bottomRight,
                    multiTuples: true,
                    variables: ['type', 'value'],
                  ),
                  crosshair: CrosshairGuide(followPointer: [false, true]),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Interactive Scatter Chart',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Tuples in various shapes for different types.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Tap to toggle a multiple selecton.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Scalable coordinate ranges.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: scatterData,
                  variables: {
                    '0': Variable(
                      accessor: (List datum) => datum[0] as num,
                    ),
                    '1': Variable(
                      accessor: (List datum) => datum[1] as num,
                    ),
                    '2': Variable(
                      accessor: (List datum) => datum[2] as num,
                    ),
                    '4': Variable(
                      accessor: (List datum) => datum[4].toString(),
                    ),
                  },
                  marks: [
                    PointMark(
                      size: SizeEncode(variable: '2', values: [5, 20]),
                      color: ColorEncode(
                        variable: '4',
                        values: Defaults.colors10,
                        updaters: {
                          'choose': {true: (_) => Colors.red}
                        },
                      ),
                      shape: ShapeEncode(variable: '4', values: [
                        CircleShape(hollow: true),
                        SquareShape(hollow: true),
                      ]),
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  coord: RectCoord(
                    horizontalRange: [0.05, 0.95],
                    verticalRange: [0.05, 0.95],
                    horizontalRangeUpdater: Defaults.horizontalRangeEvent,
                    verticalRangeUpdater: Defaults.verticalRangeEvent,
                  ),
                  selections: {'choose': PointSelection(toggle: true)},
                  tooltip: TooltipGuide(
                    anchor: (_) => Offset.zero,
                    align: Alignment.bottomRight,
                    multiTuples: true,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Interval selection',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Pan to trigger an interval selection.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Note to pan horizontally first to avoid conflict with the scroll view.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Axis lines set to middle of the coordinate region.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: scatterData,
                  variables: {
                    '0': Variable(
                      accessor: (List datum) => datum[0] as num,
                    ),
                    '1': Variable(
                      accessor: (List datum) => datum[1] as num,
                    ),
                    '2': Variable(
                      accessor: (List datum) => datum[2] as num,
                    ),
                    '4': Variable(
                      accessor: (List datum) => datum[4].toString(),
                    ),
                  },
                  marks: [
                    PointMark(
                      size: SizeEncode(variable: '2', values: [5, 20]),
                      color: ColorEncode(
                        variable: '4',
                        values: Defaults.colors10,
                        updaters: {
                          'choose': {true: (_) => Colors.red}
                        },
                      ),
                      shape: ShapeEncode(variable: '4', values: [
                        CircleShape(hollow: true),
                        SquareShape(hollow: true),
                      ]),
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis
                      ..position = 0.5
                      ..grid = null
                      ..line = Defaults.strokeStyle,
                    Defaults.verticalAxis
                      ..position = 0.5
                      ..grid = null
                      ..line = Defaults.strokeStyle,
                  ],
                  coord: RectCoord(
                    horizontalRange: [0.05, 0.95],
                    verticalRange: [0.05, 0.95],
                  ),
                  selections: {'choose': IntervalSelection()},
                  tooltip: TooltipGuide(
                    anchor: (_) => Offset.zero,
                    align: Alignment.bottomRight,
                    multiTuples: true,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Polar Scatter Chart',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- A red danger tag marks a position.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: scatterData,
                  variables: {
                    '0': Variable(
                      accessor: (List datum) => datum[0] as num,
                      scale: LinearScale(min: 0, max: 80000, tickCount: 8),
                    ),
                    '1': Variable(
                      accessor: (List datum) => datum[1] as num,
                    ),
                    '2': Variable(
                      accessor: (List datum) => datum[2] as num,
                    ),
                    '4': Variable(
                      accessor: (List datum) => datum[4].toString(),
                    ),
                  },
                  marks: [
                    PointMark(
                      size: SizeEncode(variable: '2', values: [5, 20]),
                      color: ColorEncode(
                        variable: '4',
                        values: Defaults.colors10,
                        updaters: {
                          'choose': {true: (_) => Colors.red}
                        },
                      ),
                      shape: ShapeEncode(variable: '4', values: [
                        CircleShape(hollow: true),
                        SquareShape(hollow: true),
                      ]),
                    )
                  ],
                  axes: [
                    Defaults.circularAxis
                      ..labelMapper = (_, index, total) {
                        if (index == total - 1) {
                          return null;
                        }
                        return LabelStyle(textStyle: Defaults.textStyle);
                      }
                      ..label = null,
                    Defaults.radialAxis
                      ..labelMapper = (_, index, total) {
                        if (index == total - 1) {
                          return null;
                        }
                        return LabelStyle(textStyle: Defaults.textStyle);
                      }
                      ..label = null,
                  ],
                  coord: PolarCoord(),
                  selections: {'choose': PointSelection(toggle: true)},
                  tooltip: TooltipGuide(
                    anchor: (_) => Offset.zero,
                    align: Alignment.bottomRight,
                    multiTuples: true,
                  ),
                  annotations: [
                    TagAnnotation(
                      label: Label(
                          'DANGER',
                          LabelStyle(
                              textStyle: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ))),
                      values: [45000, 65],
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  '1D Scatter Chart',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: const [65, 43, 22, 11],
                  variables: {
                    'value': Variable(
                      accessor: (num value) => value,
                      scale: LinearScale(min: 0),
                    ),
                  },
                  marks: [
                    PointMark(
                      position: Varset('value'),
                    )
                  ],
                  axes: [
                    Defaults.verticalAxis,
                  ],
                  coord: RectCoord(dimCount: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
