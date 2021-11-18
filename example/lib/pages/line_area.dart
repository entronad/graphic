import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';

import '../data.dart';

final _monthDayFormat = DateFormat('MM-dd');

class LineAreaPage extends StatelessWidget {
  LineAreaPage({Key? key}) : super(key: key);

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
                  elements: [LineElement()],
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
                      dim: 1,
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
                      dim: 1,
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
                      position: Varset('date') * Varset('value') / Varset('type'),
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
                      dim: 1,
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
                      position: Varset('index') * Varset('value') / Varset('type'),
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
                      dim: 1,
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
            ],
          ),
        ),
      ),
    );
  }
}
