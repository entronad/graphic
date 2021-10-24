import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import 'data.dart';

class DebugPage extends StatelessWidget {
  DebugPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Debug Charts'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                width: 350,
                height: 350,
                child: Chart(
                  data: basicData,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                      scale: LinearScale(min: 0),
                    ),
                  },
                  elements: [IntervalElement(
                    position: Varset('genre') * Varset('sold'),
                    label: LabelAttr(encode: (tuple) => Label(tuple['sold'].toString())),
                    color: ColorAttr(
                      variable: 'genre',
                      values: Defaults.colors10,
                    ),
                  )],
                  coord: PolarCoord(transposed: true),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
                width: 350,
                height: 350,
                child: Chart(
                  data: basicData,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                      scale: LinearScale(max: 1200),
                    ),
                  },
                  elements: [IntervalElement(
                    position: Varset('sold'),
                    color: ColorAttr(
                      variable: 'genre',
                      values: Defaults.colors10,
                    ),
                    groupBy: 'genre',
                    modifiers: [StackModifier()],
                  )],
                  coord: PolarCoord(dimCount: 1),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: stockData.reversed.toList(),
                  variables: {
                    'time': Variable(
                      accessor: (Map datumn) => datumn['time'].toString(),
                      scale: OrdinalScale(tickCount: 4),
                    ),
                    'start': Variable(
                      accessor: (Map datumn) => datumn['start'] as num,
                      scale: LinearScale(min: 6, max: 9),
                    ),
                    'max': Variable(
                      accessor: (Map datumn) => datumn['max'] as num,
                      scale: LinearScale(min: 6, max: 9),
                    ),
                    'min': Variable(
                      accessor: (Map datumn) => datumn['min'] as num,
                      scale: LinearScale(min: 6, max: 9),
                    ),
                    'end': Variable(
                      accessor: (Map datumn) => datumn['end'] as num,
                      scale: LinearScale(min: 6, max: 9),
                    ),
                  },
                  elements: [CustomElement(
                    shape: ShapeAttr(value: CandlestickShape()),
                    position: Varset('time') * (Varset('start') + Varset('max') + Varset('min') + Varset('end')),
                    color: ColorAttr(encode: (tuple) => tuple['end'] >= tuple['start'] ? Colors.red : Colors.green),
                  )],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  coord: RectCoord(onHorizontalRangeSignal: Defaults.horizontalRangeSignal),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: heatmapData,
                  variables: {
                    'name': Variable(accessor: (List datum) => datum[0].toString()),
                    'day': Variable(accessor: (List datum) => datum[1].toString()),
                    'sales': Variable(accessor: (List datum) => datum[2] as num),
                  },
                  elements: [PolygonElement(
                    color: ColorAttr(
                      variable: 'sales',
                      values: [const Color(0xffbae7ff), const Color(0xff1890ff), const Color(0xff0050b3)]),
                      shape: ShapeAttr(value: HeatmapShape(sector: true)),
                  )],
                  axes: [
                    Defaults.circularAxis,
                    Defaults.radialAxis,
                  ],
                  coord: PolarCoord(),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: heatmapData,
                  variables: {
                    'name': Variable(accessor: (List datum) => datum[0].toString()),
                    'day': Variable(accessor: (List datum) => datum[1].toString()),
                    'sales': Variable(accessor: (List datum) => datum[2] as num),
                  },
                  elements: [PolygonElement(
                    color: ColorAttr(
                      variable: 'sales',
                      values: [const Color(0xffbae7ff), const Color(0xff1890ff), const Color(0xff0050b3)]),
                      shape: ShapeAttr(value: HeatmapShape(
                        sector: true,
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      )),
                  )],
                  axes: [
                    Defaults.circularAxis,
                    Defaults.radialAxis,
                  ],
                  coord: PolarCoord(),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: heatmapData,
                  variables: {
                    'name': Variable(accessor: (List datum) => datum[0].toString()),
                    'day': Variable(accessor: (List datum) => datum[1].toString()),
                    'sales': Variable(accessor: (List datum) => datum[2] as num),
                  },
                  elements: [PolygonElement(
                    color: ColorAttr(
                      variable: 'sales',
                      values: [const Color(0xffbae7ff), const Color(0xff1890ff), const Color(0xff0050b3)]),
                  )],
                  axes: [
                    Defaults.circularAxis,
                    Defaults.radialAxis,
                  ],
                  coord: PolarCoord(),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: heatmapData,
                  variables: {
                    'name': Variable(accessor: (List datum) => datum[0].toString()),
                    'day': Variable(accessor: (List datum) => datum[1].toString()),
                    'sales': Variable(accessor: (List datum) => datum[2] as num),
                  },
                  elements: [PolygonElement(
                    color: ColorAttr(
                      variable: 'sales',
                      values: [const Color(0xffbae7ff), const Color(0xff1890ff), const Color(0xff0050b3)]),
                      shape: ShapeAttr(value: HeatmapShape(borderRadius: const BorderRadius.all(Radius.circular(10)))),
                  )],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: heatmapData,
                  variables: {
                    'name': Variable(accessor: (List datum) => datum[0].toString()),
                    'day': Variable(accessor: (List datum) => datum[1].toString()),
                    'sales': Variable(accessor: (List datum) => datum[2] as num),
                  },
                  elements: [PolygonElement(
                    color: ColorAttr(
                      variable: 'sales',
                      values: [const Color(0xffbae7ff), const Color(0xff1890ff), const Color(0xff0050b3)]),
                  )],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {'tap': PointSelection()},
                  tooltip: TooltipGuide(),
                ),
              ),
              
              Container(
                margin: const EdgeInsets.only(top: 100),
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
                  elements: [PointElement(
                    size: SizeAttr(variable: '2', values: [5, 20]),
                    // color: ColorAttr(variable: '4', values: Defaults.colors10, onSelection: {'choose': {true: (_) => Colors.red}}),
                    shape: ShapeAttr(variable: '4', values: [
                      CircleShape(hollow: true),
                      SquareShape(hollow: true),
                    ]),
                  )],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  coord: RectCoord(
                    horizontalRange: [0.05, 0.95],
                    verticalRange: [0.05, 0.95],
                    onHorizontalRangeSignal: Defaults.horizontalRangeSignal,
                    onVerticalRangeSignal: Defaults.verticalRangeSignal,
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 40),
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
                  elements: [PointElement(
                    size: SizeAttr(variable: '2', values: [5, 20]),
                    color: ColorAttr(variable: '4', values: Defaults.colors10, onSelection: {'choose': {true: (_) => Colors.red}}),
                    shape: ShapeAttr(variable: '4', values: [
                      CircleShape(hollow: true),
                      SquareShape(hollow: true),
                    ]),
                  )],
                  axes: [
                    Defaults.circularAxis
                      ..position = 1
                      ..grid = null
                      ..flip = true,
                    Defaults.radialAxis
                      ..position = 0.2
                      ..grid = null
                      ..flip = true,
                  ],
                  coord: PolarCoord(),
                  selections: {'choose': PointSelection()},
                  tooltip: TooltipGuide(
                    anchor: (_) => Offset.zero,
                    align: Alignment.bottomRight,
                    multiTuples: true,
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 40),
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
                  elements: [PointElement(
                    size: SizeAttr(variable: '2', values: [5, 20]),
                    color: ColorAttr(variable: '4', values: Defaults.colors10, onSelection: {'choose': {true: (_) => Colors.red}}),
                    shape: ShapeAttr(variable: '4', values: [
                      CircleShape(hollow: true),
                      SquareShape(hollow: true),
                    ]),
                  )],
                  axes: [
                    Defaults.horizontalAxis
                      ..flip = true
                      ..label!.offset = Offset(0, -7.5)
                      ..position = 1
                      ..tickLine = TickLine(),
                    Defaults.verticalAxis
                      ..flip = true
                      ..label!.offset = Offset(7.5, 0)
                      ..position = 1
                      ..tickLine = TickLine(),
                  ],
                  coord: RectCoord(
                    horizontalRange: [0.05, 0.95],
                    verticalRange: [0.05, 0.95],
                    // transposed: true,
                  ),
                  selections: {'choose': PointSelection(toggle: true)},
                  tooltip: TooltipGuide(
                    anchor: (_) => Offset.zero,
                    align: Alignment.bottomRight,
                    multiTuples: true,
                  ),
                  padding: EdgeInsets.all(40),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 40),
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
                      accessor: (Map map) => (map['Close'] ?? double.nan) as num,
                      scale: LinearScale(nice: true, min: 100),
                    ),
                  },
                  elements: [
                    AreaElement(
                      shape: ShapeAttr(value: BasicAreaShape(smooth: true)),
                      color: ColorAttr(value: Defaults.colors10.first.withAlpha(80)),
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
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
                width: 350,
                height: 350,
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
                      scale: LinearScale(nice: true),
                    ),
                  },
                  elements: [LineElement(
                    position: Varset('index') * Varset('value'),
                    groupBy: 'type',
                    shape: ShapeAttr(value: BasicLineShape(loop: true)),
                    color: ColorAttr(variable: 'type', values: Defaults.colors10),
                  )],
                  axes: [
                    Defaults.circularAxis,
                    Defaults.radialAxis,
                  ],
                  coord: PolarCoord(),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: adjustData,
                  variables: {
                    'index': Variable(
                      accessor: (Map map) => map['index'] as num,
                      scale: LinearScale(marginMin: 0, marginMax: 0),
                    ),
                    'type': Variable(
                      accessor: (Map map) => map['type'] as String,
                    ),
                    'value': Variable(
                      accessor: (Map map) => map['value'] as num,
                      scale: LinearScale(max: 2000),
                    ),
                  },
                  elements: [AreaElement(
                    position: Varset('index') * Varset('value'),
                    groupBy: 'type',
                    shape: ShapeAttr(value: BasicAreaShape(smooth: true)),
                    color: ColorAttr(variable: 'type', values: Defaults.colors10),
                    modifiers: [StackModifier()],
                  )],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: lineData,
                  variables: {
                    'Date': Variable(
                      accessor: (Map map) => map['Date'] as String,
                      scale: OrdinalScale(tickCount: 5),
                    ),
                    'Close': Variable(
                      accessor: (Map map) => map['Close'] as num,
                      scale: LinearScale(nice: true, min: 100),
                    ),
                  },
                  elements: [
                    AreaElement(
                      shape: ShapeAttr(value: BasicAreaShape(smooth: true)),
                      color: ColorAttr(value: Defaults.colors10.first.withAlpha(80)),
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
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 40),
                width: 350,
                height: 350,
                child: Chart(
                  data: List<Map>.from(basicData)
                    ..sort((a, b) => ((b['sold'] as num) - (a['sold'] as num)).toInt()),
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                      scale: LinearScale(min: -200, max: 200),
                    ),
                  },
                  elements: [IntervalElement(
                    label: LabelAttr(encode: (tuple) => Label(tuple['sold'].toString())),
                    shape: ShapeAttr(value: FunnelShape(pyramid: true)),
                    color: ColorAttr(variable: 'genre', values: Defaults.colors10),
                    modifiers: [SymmetricModifier()],
                  )],
                  coord: RectCoord(transposed: true, verticalRange: [1, 0]),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 40),
                width: 350,
                height: 350,
                child: Chart(
                  data: List<Map>.from(basicData)
                    ..sort((a, b) => ((b['sold'] as num) - (a['sold'] as num)).toInt()),
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                      scale: LinearScale(min: -200, max: 200),
                    ),
                  },
                  elements: [IntervalElement(
                    label: LabelAttr(encode: (tuple) => Label(tuple['sold'].toString())),
                    shape: ShapeAttr(value: FunnelShape()),
                    color: ColorAttr(variable: 'genre', values: Defaults.colors10),
                    modifiers: [SymmetricModifier()],
                  )],
                  coord: RectCoord(transposed: true, verticalRange: [1, 0]),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: intervalData,
                  variables: {
                    'id': Variable(
                      accessor: (Map map) => map['id'] as String,
                    ),
                    'min': Variable(
                      accessor: (Map map) => map['min'] as num,
                      scale: LinearScale(min: 0, max: 160),
                    ),
                    'max': Variable(
                      accessor: (Map map) => map['max'] as num,
                      scale: LinearScale(min: 0, max: 160),
                    ),
                  },
                  elements: [IntervalElement(
                    position: Varset('id') * (Varset('min') + Varset('max')),
                    elevation: ElevationAttr(value: 2),
                  )],
                  axes: [
                    Defaults.horizontalAxis
                      ..tickLine = TickLine(style: Defaults.strokeStyle, length: 5),
                    Defaults.verticalAxis,
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 40),
                width: 350,
                height: 350,
                child: Chart(
                  padding: EdgeInsets.zero,
                  data: roseData,
                  variables: {
                    'name': Variable(
                      accessor: (Map map) => map['name'] as String,
                    ),
                    'value': Variable(
                      accessor: (Map map) => map['value'] as num,
                      scale: LinearScale(min: 0, marginMax: 0.1),
                    ),
                  },
                  elements: [IntervalElement(
                    label: LabelAttr(encode: (tuple) => Label(tuple['name'].toString())),
                    shape: ShapeAttr(value: RectShape(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    )),
                    color: ColorAttr(variable: 'name', values: Defaults.colors10),
                    elevation: ElevationAttr(value: 5),
                  )],
                  coord: PolarCoord(startRadius: 0.15),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: basicData,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                    ),
                  },
                  transforms: [Proportion(
                    variable: 'sold',
                    as: 'percent',
                  )],
                  elements: [IntervalElement(
                    position: Varset('percent'),
                    label: LabelAttr(encode: (tuple) => Label(tuple['sold'].toString())),
                    // shape: ShapeAttr(value: RectShape(labelPosition: 0.5)),
                    color: ColorAttr(variable: 'genre', values: Defaults.colors10),
                    groupBy: 'genre',
                    modifiers: [StackModifier()],
                  )],
                  coord: PolarCoord(transposed: true, dimCount: 1),
                  selections: {'tap': PointSelection(

                  )},
                  tooltip: TooltipGuide(),
                  crosshair: CrosshairGuide(),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
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
                  elements: [PointElement(
                    position: Varset('value'),
                  )],
                  axes: [
                    Defaults.horizontalAxis
                      ..line = null
                      ..grid = Defaults.strokeStyle,
                  ],
                  coord: RectCoord(dimCount: 1, transposed: true),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
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
                  elements: [PointElement(
                    position: Varset('value'),
                  )],
                  axes: [
                    Defaults.verticalAxis,
                  ],
                  coord: RectCoord(dimCount: 1),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: basicData,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                      scale: LinearScale(min: 0),
                    ),
                  },
                  elements: [IntervalElement(
                    position: Varset('genre') * Varset('sold'),
                    label: LabelAttr(encode: (tuple) => Label(tuple['sold'].toString())),
                    shape: ShapeAttr(value: RectShape(labelPosition: 0.5)),
                    color: ColorAttr(variable: 'genre', values: Defaults.colors10),
                  )],
                  coord: PolarCoord(),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: basicData,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                      scale: LinearScale(min: 0),
                    ),
                  },
                  elements: [IntervalElement(
                    position: Varset('genre') * Varset('sold'),
                    label: LabelAttr(encode: (tuple) => Label(tuple['sold'].toString())),
                    shape: ShapeAttr(value: RectShape(histogram: true)),
                    color: ColorAttr(variable: 'genre', values: Defaults.colors10),
                  )],
                  axes: [
                    Defaults.circularAxis,
                    Defaults.radialAxis,
                  ],
                  coord: PolarCoord(),
                  selections: {'tap': PointSelection(
                    on: {GestureType.scaleUpdate, GestureType.tapDown, GestureType.longPressMoveUpdate},
                    dim: 1,
                  )},
                  tooltip: TooltipGuide(followPointer: [false, true]),
                  crosshair: CrosshairGuide(followPointer: [false, true]),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
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
                      scale: LinearScale(max: 2000),
                    ),
                  },
                  elements: [IntervalElement(
                    position: Varset('index') * Varset('value'),
                    groupBy: 'type',
                    label: LabelAttr(encode: (tuple) => Label(tuple['value'].toString())),
                    color: ColorAttr(variable: 'type', values: Defaults.colors10),
                    modifiers: [StackModifier()],
                  )],
                  axes: [
                    Defaults.verticalAxis
                      ..line = Defaults.strokeStyle
                      ..grid = null,
                    Defaults.horizontalAxis
                      ..line = null
                      ..grid = Defaults.strokeStyle,
                  ],
                  coord: RectCoord(transposed: true),
                  selections: {'tap': PointSelection(
                    variable: 'index',
                  )},
                  tooltip: TooltipGuide(),
                  crosshair: CrosshairGuide(),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
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
                  elements: [IntervalElement(
                    position: Varset('index') * Varset('value'),
                    groupBy: 'type',
                    label: LabelAttr(encode: (tuple) => Label(tuple['value'].toString())),
                    color: ColorAttr(variable: 'type', values: Defaults.colors10),
                    modifiers: [DodgeModifier()],
                    size: SizeAttr(value: 4),
                  )],
                  axes: [
                    Defaults.verticalAxis
                      ..line = Defaults.strokeStyle
                      ..grid = null,
                    Defaults.horizontalAxis
                      ..line = null
                      ..grid = Defaults.strokeStyle,
                  ],
                  coord: RectCoord(transposed: true),
                  selections: {'tap': PointSelection(
                    variable: 'index',
                    dim: 1,
                  )},
                  tooltip: TooltipGuide(),
                  crosshair: CrosshairGuide(),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
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
                      scale: LinearScale(max: 1000, min: -1000),
                    ),
                  },
                  elements: [IntervalElement(
                    position: Varset('index') * Varset('value'),
                    groupBy: 'type',
                    label: LabelAttr(encode: (tuple) => Label(tuple['value'].toString())),
                    color: ColorAttr(variable: 'type', values: Defaults.colors10),
                    modifiers: [StackModifier(), SymmetricModifier()],
                  )],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {'tap': PointSelection(
                    variable: 'index',
                  )},
                  tooltip: TooltipGuide(),
                  crosshair: CrosshairGuide(),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
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
                      scale: LinearScale(max: 2000),
                    ),
                  },
                  elements: [IntervalElement(
                    position: Varset('index') * Varset('value'),
                    groupBy: 'type',
                    label: LabelAttr(encode: (tuple) => Label(tuple['value'].toString())),
                    color: ColorAttr(variable: 'type', values: Defaults.colors10),
                    modifiers: [StackModifier()],
                  )],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {'tap': PointSelection(
                    variable: 'index',
                  )},
                  tooltip: TooltipGuide(),
                  crosshair: CrosshairGuide(),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
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
                  elements: [IntervalElement(
                    position: Varset('index') * Varset('value'),
                    groupBy: 'type',
                    color: ColorAttr(variable: 'type', values: Defaults.colors10),
                    modifiers: [DodgeModifier(ratio: 0.12)],
                    size: SizeAttr(value: 4),
                  )],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {'tap': PointSelection(
                    variable: 'index',
                    dim: 1,
                  )},
                  tooltip: TooltipGuide(),
                  crosshair: CrosshairGuide(),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: basicData,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                    ),
                  },
                  elements: [IntervalElement(
                    position: Varset('genre') * Varset('sold'),
                    label: LabelAttr(encode: (tuple) => Label(tuple['sold'].toString())),
                    shape: ShapeAttr(value: RectShape(histogram: true)),
                    color: ColorAttr(variable: 'genre', values: Defaults.colors10),
                  )],
                  axes: [
                    Defaults.verticalAxis
                      ..line = Defaults.strokeStyle
                      ..grid = null,
                    Defaults.horizontalAxis
                      ..line = null
                      ..grid = Defaults.strokeStyle,
                  ],
                  coord: RectCoord(transposed: true),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: basicData,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                    ),
                  },
                  elements: [IntervalElement(
                    position: Varset('genre') * Varset('sold'),
                    label: LabelAttr(encode: (tuple) => Label(tuple['sold'].toString())),
                    shape: ShapeAttr(value: RectShape(histogram: true)),
                    color: ColorAttr(variable: 'genre', values: Defaults.colors10),
                  )],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: basicData,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                    ),
                  },
                  elements: [IntervalElement(
                    position: Varset('genre') * Varset('sold'),
                    label: LabelAttr(encode: (tuple) => Label(tuple['sold'].toString())),
                  )],
                  axes: [
                    Defaults.verticalAxis
                      ..line = Defaults.strokeStyle
                      ..grid = null,
                    Defaults.horizontalAxis
                      ..line = null
                      ..grid = Defaults.strokeStyle,
                  ],
                  selections: {'tap': PointSelection(

                  )},
                  coord: RectCoord(transposed: true),
                  tooltip: TooltipGuide(),
                  crosshair: CrosshairGuide(),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: basicData,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                    ),
                  },
                  elements: [IntervalElement(
                    position: Varset('genre') * Varset('sold'),
                    label: LabelAttr(encode: (tuple) => Label(tuple['sold'].toString())),
                    elevation: ElevationAttr(
                      value: 0,
                      onSelection: {'tap': {true: (_) => 5,}}
                    ),
                    color: ColorAttr(
                      value: Defaults.primaryColor,
                      onSelection: {'tap': {false: (color) => color.withAlpha(100),}}
                    ),
                  )],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {'tap': PointSelection(

                  )},
                  tooltip: TooltipGuide(render: simpleTooltip),
                  crosshair: CrosshairGuide(),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40),
                width: 350,
                height: 300,
                child: Chart(
                  data: basicData,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                    ),
                  },
                  elements: [IntervalElement(
                    position: Varset('genre') * Varset('sold'),
                    label: LabelAttr(encode: (tuple) => Label(tuple['sold'].toString())),
                    elevation: ElevationAttr(
                      value: 0,
                      onSelection: {'tap': {true: (_) => 5,}}
                    ),
                    color: ColorAttr(
                      value: Defaults.primaryColor,
                      onSelection: {'tap': {false: (color) => color.withAlpha(100),}}
                    ),
                  )],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {'tap': PointSelection(
                    on: {GestureType.scaleUpdate, GestureType.tapDown, GestureType.longPressMoveUpdate},
                    dim: 1,
                  )},
                  tooltip: TooltipGuide(
                    render: simpleTooltip,
                    followPointer: [false, true]
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

List<Figure> simpleTooltip(
  Offset anchor,
  List<Tuple> selectedTuples,
) {
  List<Figure> figures;

  String textContent = '';
  final fields = selectedTuples.first.keys.toList();
  if (selectedTuples.length == 1) {
    final original = selectedTuples.single;
    var field = fields.first;
    textContent += '$field: ${original[field]}';
    for (var i = 1; i < fields.length; i++) {
      field = fields[i];
      textContent += '\n$field: ${original[field]}';
    }
  } else {
    for (var original in selectedTuples) {
      final domainField = fields.first;
      final measureField = fields.last;
      textContent += '\n${original[domainField]}: ${original[measureField]}';
    }
  }

  const textStyle = TextStyle(fontSize: 12);
  const padding = EdgeInsets.all(5);
  const align = Alignment.topRight;
  const offset = Offset(5, -5);
  const radius = Radius.zero;
  const elevation = 1.0;
  const backgroundColor = Colors.black;

  final painter = TextPainter(
    text: TextSpan(text: textContent, style: textStyle),
    textDirection: TextDirection.ltr,
  );
  painter.layout();

  final width = padding.left + painter.width + padding.right;
  final height = padding.top + painter.height + padding.bottom;

  final paintPoint = getPaintPoint(
    anchor + offset,
    width,
    height,
    align,
  );

  final widow = Rect.fromLTWH(
    paintPoint.dx,
    paintPoint.dy,
    width,
    height,
  );

  final widowPath = Path()..addRRect(
    RRect.fromRectAndRadius(widow, radius),
  );
  
  figures = <Figure>[];

  figures.add(ShadowFigure(
    widowPath,
    backgroundColor,
    elevation,
  ));
  figures.add(PathFigure(
    widowPath,
    Paint()..color = backgroundColor,
  ));
  figures.add(TextFigure(
    painter,
    paintPoint + padding.topLeft,
  ));

  return figures;
}
