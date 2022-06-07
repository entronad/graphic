import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';

import '../data.dart';

final _monthDayFormat = DateFormat('MM-dd');

class LineAreaPointPage extends StatelessWidget {
  LineAreaPointPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Line and Area Element'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                child: const Text(
                  'Time series line chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- Pre-select a point.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- Dash line.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- With time scale in domain dimension.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- Input data type is a custom class.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- With coordinate region background color.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
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
                  elements: [
                    LineElement(
                      shape: ShapeAttr(value: BasicLineShape(dash: [5, 2])),
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
                child: const Text(
                  'Smooth Line and Area chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- Line and area will break at NaN.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- A touch moving triggerd selection.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
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
                  elements: [
                    AreaElement(
                      shape: ShapeAttr(value: BasicAreaShape(smooth: true)),
                      color: ColorAttr(
                          value: Defaults.colors10.first.withAlpha(80)),
                    ),
                    LineElement(
                      shape: ShapeAttr(value: BasicLineShape(smooth: true)),
                      size: SizeAttr(value: 0.5),
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
                child: const Text(
                  'Group interactions',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- Select and change color of a whole group',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- The group and tooltip selections are different but triggerd by same gesture.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- Different interactions for different devices',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
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
                      scale: OrdinalScale(tickCount: 5),
                    ),
                    'points': Variable(
                      accessor: (Map map) => map['points'] as num,
                    ),
                    'name': Variable(
                      accessor: (Map map) => map['name'] as String,
                    ),
                  },
                  elements: [
                    LineElement(
                      position:
                          Varset('date') * Varset('points') / Varset('name'),
                      shape: ShapeAttr(value: BasicLineShape(smooth: true)),
                      size: SizeAttr(value: 0.5),
                      color: ColorAttr(
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
                    PointElement(
                      color: ColorAttr(
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
                    element: 0,
                    variables: [
                      'date',
                      'name',
                      'points',
                    ],
                  ),
                  crosshair: CrosshairGuide(
                    selections: {'tooltipTouch', 'tooltipMouse'},
                    styles: [
                      StrokeStyle(color: const Color(0xffbfbfbf)),
                      StrokeStyle(color: const Color(0x00bfbfbf)),
                    ],
                    followPointer: [true, false],
                  ),
                ),
              ),
              Container(
                child: const Text(
                  'River chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
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
                  elements: [
                    AreaElement(
                      position:
                          Varset('date') * Varset('value') / Varset('type'),
                      shape: ShapeAttr(value: BasicAreaShape(smooth: true)),
                      color: ColorAttr(
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
                child: const Text(
                  'Spider Net Chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- A loop connects the first and last point.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
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
                  elements: [
                    LineElement(
                      position:
                          Varset('index') * Varset('value') / Varset('type'),
                      shape: ShapeAttr(value: BasicLineShape(loop: true)),
                      color: ColorAttr(
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
                child: const Text(
                  'Interactive Scatter Chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- Tuples in various shapes for different types.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- Tap to toggle a multiple selecton.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- Scalable coordinate ranges.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
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
                  elements: [
                    PointElement(
                      size: SizeAttr(variable: '2', values: [5, 20]),
                      color: ColorAttr(
                        variable: '4',
                        values: Defaults.colors10,
                        updaters: {
                          'choose': {true: (_) => Colors.red}
                        },
                      ),
                      shape: ShapeAttr(variable: '4', values: [
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
                    horizontalRangeUpdater: Defaults.horizontalRangeSignal,
                    verticalRangeUpdater: Defaults.verticalRangeSignal,
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
                child: const Text(
                  'Interval selection',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- Pan to trigger an interval selection.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- Note to pan horizontally first to avoid conflict with the scroll view.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- Axis lines set to middle of the coordinate region.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
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
                  elements: [
                    PointElement(
                      size: SizeAttr(variable: '2', values: [5, 20]),
                      color: ColorAttr(
                        variable: '4',
                        values: Defaults.colors10,
                        updaters: {
                          'choose': {true: (_) => Colors.red}
                        },
                      ),
                      shape: ShapeAttr(variable: '4', values: [
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
                child: const Text(
                  'Polar Scatter Chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- A red danger tag marks a position.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
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
                  elements: [
                    PointElement(
                      size: SizeAttr(variable: '2', values: [5, 20]),
                      color: ColorAttr(
                        variable: '4',
                        values: Defaults.colors10,
                        updaters: {
                          'choose': {true: (_) => Colors.red}
                        },
                      ),
                      shape: ShapeAttr(variable: '4', values: [
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
                        return LabelStyle(style: Defaults.textStyle);
                      }
                      ..label = null,
                    Defaults.radialAxis
                      ..labelMapper = (_, index, total) {
                        if (index == total - 1) {
                          return null;
                        }
                        return LabelStyle(style: Defaults.textStyle);
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
                              style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ))),
                      values: [45000, 65],
                    )
                  ],
                ),
              ),
              Container(
                child: const Text(
                  '1D Scatter Chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
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
                  elements: [
                    PointElement(
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
