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
                    size: SizeAttr(value: 15),
                    elevation: ElevationAttr(variable: '2', values: [0, 8]),
                    color: ColorAttr(variable: '4', values: Defaults.colors10),
                    shape: ShapeAttr(variable: '4', values: [
                      CircleShape(),
                      SquareShape(),
                    ]),
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
                    size: SizeAttr(value: 15),
                    elevation: ElevationAttr(variable: '2', values: [0, 8]),
                    color: ColorAttr(variable: '4', values: Defaults.colors10),
                    shape: ShapeAttr(variable: '4', values: [
                      CircleShape(),
                      SquareShape(),
                    ]),
                  )],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  coord: RectCoord(
                    horizontalRange: [0.05, 0.95],
                    verticalRange: [0.05, 0.95]
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
                    color: ColorAttr(variable: '4', values: Defaults.colors10),
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
                    verticalRange: [0.05, 0.95]
                  ),
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
                  coord: PolarCoord(innerRadius: 0.15),
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
                  coord: PolarCoord(transposed: true, dim: 1),
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
                  coord: RectCoord(dim: 1, transposed: true),
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
                  coord: RectCoord(dim: 1),
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
                  )],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
