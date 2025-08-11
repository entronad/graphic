import 'dart:math';

import 'package:flutter/material.dart' ;
import 'package:graphic/graphic.dart';
//name conflit TextDirection with material.dart
import 'package:intl/intl.dart' as p_intl;

import '../data.dart';

class TriangleShape extends IntervalShape {
  @override
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) {
    assert(coord is RectCoordConv);
    assert(coord.transposed == false);

    final rst = <MarkElement>[];

    for (var item in group) {
      for (var point in item.position) {
        if (!point.dy.isFinite) {
          return [];
        }
      }

      final style = getPaintStyle(item, false, 0, null, null);

      final start = coord.convert(item.position[0]);
      final end = coord.convert(item.position[1]);
      final size = item.size ?? defaultSize;
      final startLeft = Offset(start.dx - size / 2, start.dy);
      final startRight = Offset(start.dx + size / 2, start.dy);

      rst.add(
          PolygonElement(points: [end, startLeft, startRight], style: style));
    }

    return rst;
  }

  @override
  List<MarkElement<ElementStyle>> drawGroupLabels(
      List<Attributes> group, CoordConv coord, Offset origin) {
    final rst = <MarkElement>[];

    for (var item in group) {
      bool nan = false;
      for (var point in item.position) {
        if (!point.dy.isFinite) {
          nan = true;
          break;
        }
      }
      if (!nan && item.label != null) {
        final end = coord.convert(item.position[1]);
        rst.add(LabelElement(
            text: item.label!.text!,
            anchor: end,
            defaultAlign: Alignment.topCenter,
            style: item.label!.style));
      }
    }

    return rst;
  }

  @override
  bool equalTo(Object other) => other is TriangleShape;
}

List<MarkElement> simpleTooltip(
  Size size,
  Offset anchor,
  Map<int, Tuple> selectedTuples,
) {
  List<MarkElement> elements;

  String textContent = '';
  final selectedTupleList = selectedTuples.values;
  final fields = selectedTupleList.first.keys.toList();
  if (selectedTuples.length == 1) {
    final original = selectedTupleList.single;
    var field = fields.first;
    textContent += '$field: ${original[field]}';
    for (var i = 1; i < fields.length; i++) {
      field = fields[i];
      textContent += '\n$field: ${original[field]}';
    }
  } else {
    for (var original in selectedTupleList) {
      final domainField = fields.first;
      final measureField = fields.last;
      textContent += '\n${original[domainField]}: ${original[measureField]}';
    }
  }

  const textStyle = TextStyle(fontSize: 12, color: Colors.white);
  const padding = EdgeInsets.all(5);
  const align = Alignment.topRight;
  const offset = Offset(5, -5);
  const elevation = 1.0;
  const backgroundColor = Colors.black;

  final painter = TextPainter(
    text: TextSpan(text: textContent, style: textStyle),
    textDirection: TextDirection.ltr,
  );
  painter.layout();

  final width = padding.left + painter.width + padding.right;
  final height = padding.top + painter.height + padding.bottom;

  final paintPoint = getBlockPaintPoint(
    anchor + offset,
    width,
    height,
    align,
  );

  final window = Rect.fromLTWH(
    paintPoint.dx,
    paintPoint.dy,
    width,
    height,
  );

  var textPaintPoint = paintPoint + padding.topLeft;

  elements = <MarkElement>[
    RectElement(
        rect: window,
        style: PaintStyle(fillColor: backgroundColor, elevation: elevation)),
    LabelElement(
        text: textContent,
        anchor: textPaintPoint,
        style: LabelStyle(textStyle: textStyle, align: Alignment.bottomRight)),
  ];

  return elements;
}

List<MarkElement> centralPieLabel(
  Size size,
  Offset anchor,
  Map<int, Tuple> selectedTuples,
) {
  final tuple = selectedTuples.values.last;

  final titleElement = LabelElement(
      text: '${tuple['genre']}\n',
      anchor: const Offset(175, 150),
      style: LabelStyle(
          textStyle: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          align: Alignment.topCenter));

  final valueElement = LabelElement(
      text: tuple['sold'].toString(),
      anchor: const Offset(175, 150),
      style: LabelStyle(
          textStyle: const TextStyle(
            fontSize: 28,
            color: Colors.black87,
          ),
          align: Alignment.bottomCenter));

  return [titleElement, valueElement];
}

class CombinedPolygonCustomPage extends StatelessWidget {
  CombinedPolygonCustomPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Custom'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
            Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Combined Bar/Line Chart',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- With fixed scale so that bar and line use the same scale.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- With rotated and formatted labels.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
            data: combinedBarLineData,
            variables: {
              "date_information": Variable(
                accessor: (Map map) => map["dateInformation"] as String,
              ),
              "kCalIntake": Variable(
                accessor: (Map map) => map["kCalIntake"] as num,
                scale: LinearScale(
                  max: 3000,
                  min: 0,
                  //value is num/double, this removes the decimal separator on y axis label.
                  formatter: (value) => p_intl.NumberFormat(null, 'en',).format(value.toInt()),
                ),
              ),
              "kCalTarget": Variable(
                accessor: (Map map) => map["kCalTarget"] as num,
                scale: LinearScale(max: 3000, min: 0),
              ),
            },
            marks: [
              IntervalMark(
                size: SizeEncode(value: 5),
                label: LabelEncode(
                  encoder: (tuple) => Label(
                    p_intl.NumberFormat(null, 'en',).format(tuple["kCalIntake"]),
                    LabelStyle(
                      textStyle: const TextStyle(
                        fontSize: 10,
                        color: Color(0xff808080),
                      ),
                      offset: const Offset(6, -15),
                      rotation: 4.72,
                    ),
                  ),
                ),
                color: ColorEncode(
                  value: const Color(0xff1890ff),
                ),
              ),
              LineMark(
                position: Varset("date_information") * Varset("kCalTarget"),
                size: SizeEncode(value: 1.5),
                color: ColorEncode(
                  value: const Color(0xff0050b3),
                ),
              ),
            ],
            axes: [
              AxisGuide(
                dim: Dim.x,
                line: PaintStyle(
                  strokeColor: const Color(0xffe8e8e8),
                  strokeWidth: 1,
                ),
                label: LabelStyle(
                  textStyle: const TextStyle(
                    fontSize: 10,
                    color: Color(0xff808080),
                  ),
                  offset: const Offset(12, 15),
                  rotation: 1,
                ),
              ),
              AxisGuide(
                dim: Dim.y,
                label: LabelStyle(
                  textStyle: const TextStyle(
                    fontSize: 10,
                    color: Color(0xff808080),
                  ),
                  offset: const Offset(-7.5, 0),
                ),
                grid: PaintStyle(
                  strokeColor: const Color(0xffe8e8e8),
                  strokeWidth: 1,
                ),
              ),
            ],
          ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Heatmap',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: heatmapData,
                  variables: {
                    'name': Variable(
                      accessor: (List datum) => datum[0].toString(),
                    ),
                    'day': Variable(
                      accessor: (List datum) => datum[1].toString(),
                    ),
                    'sales': Variable(
                      accessor: (List datum) => datum[2] as num,
                    ),
                  },
                  marks: [
                    PolygonMark(
                      color: ColorEncode(
                        variable: 'sales',
                        values: [
                          const Color(0xffbae7ff),
                          const Color(0xff1890ff),
                          const Color(0xff0050b3)
                        ],
                      ),
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {'tap': PointSelection()},
                  tooltip: TooltipGuide(),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Heatmap fade',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Tap to select one, and others will fade.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- With corner radius.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: heatmapData,
                  variables: {
                    'name': Variable(
                      accessor: (List datum) => datum[0].toString(),
                    ),
                    'day': Variable(
                      accessor: (List datum) => datum[1].toString(),
                    ),
                    'sales': Variable(
                      accessor: (List datum) => datum[2] as num,
                    ),
                  },
                  marks: [
                    PolygonMark(
                      shape: ShapeEncode(
                          value: HeatmapShape(
                              borderRadius: BorderRadius.circular(4))),
                      color: ColorEncode(
                        variable: 'sales',
                        values: [
                          const Color(0xffbae7ff),
                          const Color(0xff1890ff),
                          const Color(0xff0050b3)
                        ],
                        updaters: {
                          'tap': {false: (color) => color.withAlpha(70)}
                        },
                      ),
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {'tap': PointSelection()},
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Polar Heatmap of Polygon',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Tap to select one for tooltip, and others will fade.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: heatmapData,
                  variables: {
                    'name': Variable(
                      accessor: (List datum) => datum[0].toString(),
                    ),
                    'day': Variable(
                      accessor: (List datum) => datum[1].toString(),
                    ),
                    'sales': Variable(
                      accessor: (List datum) => datum[2] as num,
                    ),
                  },
                  marks: [
                    PolygonMark(
                      color: ColorEncode(
                        variable: 'sales',
                        values: [
                          const Color(0xffbae7ff),
                          const Color(0xff1890ff),
                          const Color(0xff0050b3)
                        ],
                        updaters: {
                          'tap': {false: (color) => color.withAlpha(70)}
                        },
                      ),
                    )
                  ],
                  coord: PolarCoord(),
                  selections: {'tap': PointSelection()},
                  tooltip: TooltipGuide(
                    anchor: (_) => Offset.zero,
                    align: Alignment.bottomRight,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Polar Heatmap of Sector',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Tap to select one for tooltip, and others will fade.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: heatmapData,
                  variables: {
                    'name': Variable(
                      accessor: (List datum) => datum[0].toString(),
                    ),
                    'day': Variable(
                      accessor: (List datum) => datum[1].toString(),
                    ),
                    'sales': Variable(
                      accessor: (List datum) => datum[2] as num,
                    ),
                  },
                  marks: [
                    PolygonMark(
                      shape: ShapeEncode(value: HeatmapShape(sector: true)),
                      color: ColorEncode(
                        variable: 'sales',
                        values: [
                          const Color(0xffbae7ff),
                          const Color(0xff1890ff),
                          const Color(0xff0050b3)
                        ],
                        updaters: {
                          'tap': {false: (color) => color.withAlpha(70)}
                        },
                      ),
                    )
                  ],
                  coord: PolarCoord(),
                  selections: {'tap': PointSelection()},
                  tooltip: TooltipGuide(
                    anchor: (_) => Offset.zero,
                    align: Alignment.bottomRight,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Custom Shape and Tooltip',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- A custom shape attribution should corresponds to the geometry elemnet type.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
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
                        scale: LinearScale(min: 0)),
                  },
                  marks: [
                    IntervalMark(
                      shape: ShapeEncode(value: TriangleShape()),
                      label: LabelEncode(
                          encoder: (tuple) => Label(tuple['sold'].toString())),
                      elevation: ElevationEncode(value: 0, updaters: {
                        'tap': {true: (_) => 5}
                      }),
                      color:
                          ColorEncode(value: Defaults.primaryColor, updaters: {
                        'tap': {false: (color) => color.withAlpha(100)}
                      }),
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {'tap': PointSelection(dim: Dim.x)},
                  tooltip: TooltipGuide(renderer: simpleTooltip),
                  crosshair: CrosshairGuide(),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Central Pie Label by Custom Tooltip',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
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
                  transforms: [
                    Proportion(
                      variable: 'sold',
                      as: 'percent',
                    )
                  ],
                  marks: [
                    IntervalMark(
                      position: Varset('percent') / Varset('genre'),
                      color: ColorEncode(
                          variable: 'genre', values: Defaults.colors10),
                      modifiers: [StackModifier()],
                    )
                  ],
                  coord: PolarCoord(
                    transposed: true,
                    dimCount: 1,
                    startRadius: 0.4,
                  ),
                  selections: {'tap': PointSelection()},
                  tooltip: TooltipGuide(renderer: centralPieLabel),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Custom Legend',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Custom legend by mark and tag annotations.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- With dodge modifier.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  padding: (_) => const EdgeInsets.fromLTRB(40, 5, 10, 40),
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
                    IntervalMark(
                      position:
                          Varset('index') * Varset('value') / Varset('type'),
                      color: ColorEncode(
                          variable: 'type', values: Defaults.colors10),
                      size: SizeEncode(value: 2),
                      modifiers: [DodgeModifier(ratio: 0.1)],
                    )
                  ],
                  coord: RectCoord(
                    horizontalRangeUpdater: Defaults.horizontalRangeEvent,
                  ),
                  axes: [
                    Defaults.horizontalAxis..tickLine = TickLine(),
                    Defaults.verticalAxis,
                  ],
                  selections: {
                    'tap': PointSelection(
                      variable: 'index',
                    )
                  },
                  tooltip: TooltipGuide(multiTuples: true),
                  crosshair: CrosshairGuide(),
                  annotations: [
                    CustomAnnotation(
                        renderer: (_, size) => [
                              CircleElement(
                                  center: const Offset(25, 290),
                                  radius: 5,
                                  style: PaintStyle(
                                      fillColor: Defaults.colors10[0]))
                            ],
                        anchor: (p0) => const Offset(0, 0)),
                    TagAnnotation(
                      label: Label(
                        'Email',
                        LabelStyle(
                            textStyle: Defaults.textStyle,
                            align: Alignment.centerRight),
                      ),
                      anchor: (size) => const Offset(34, 290),
                    ),
                    CustomAnnotation(
                        renderer: (_, size) => [
                              CircleElement(
                                  center: Offset(25 + size.width / 5, 290),
                                  radius: 5,
                                  style: PaintStyle(
                                      fillColor: Defaults.colors10[1]))
                            ],
                        anchor: (p0) => const Offset(0, 0)),
                    TagAnnotation(
                      label: Label(
                        'Affiliate',
                        LabelStyle(
                            textStyle: Defaults.textStyle,
                            align: Alignment.centerRight),
                      ),
                      anchor: (size) => Offset(34 + size.width / 5, 290),
                    ),
                    CustomAnnotation(
                        renderer: (_, size) => [
                              CircleElement(
                                  center: Offset(25 + size.width / 5 * 2, 290),
                                  radius: 5,
                                  style: PaintStyle(
                                      fillColor: Defaults.colors10[2]))
                            ],
                        anchor: (p0) => const Offset(0, 0)),
                    TagAnnotation(
                      label: Label(
                        'Video',
                        LabelStyle(
                            textStyle: Defaults.textStyle,
                            align: Alignment.centerRight),
                      ),
                      anchor: (size) => Offset(34 + size.width / 5 * 2, 290),
                    ),
                    CustomAnnotation(
                        renderer: (_, size) => [
                              CircleElement(
                                  center: Offset(25 + size.width / 5 * 3, 290),
                                  radius: 5,
                                  style: PaintStyle(
                                      fillColor: Defaults.colors10[3]))
                            ],
                        anchor: (p0) => const Offset(0, 0)),
                    TagAnnotation(
                      label: Label(
                        'Direct',
                        LabelStyle(
                            textStyle: Defaults.textStyle,
                            align: Alignment.centerRight),
                      ),
                      anchor: (size) => Offset(34 + size.width / 5 * 3, 290),
                    ),
                    CustomAnnotation(
                        renderer: (_, size) => [
                              CircleElement(
                                  center: Offset(25 + size.width / 5 * 4, 290),
                                  radius: 5,
                                  style: PaintStyle(
                                      fillColor: Defaults.colors10[4]))
                            ],
                        anchor: (p0) => const Offset(0, 0)),
                    TagAnnotation(
                      label: Label(
                        'Search',
                        LabelStyle(
                            textStyle: Defaults.textStyle,
                            align: Alignment.centerRight),
                      ),
                      anchor: (size) => Offset(34 + size.width / 5 * 4, 290),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Custom Modifier',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- With dodge and size modifier that scales the interval mark width to fit within its band',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  padding: (_) => const EdgeInsets.fromLTRB(40, 5, 10, 40),
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
                    IntervalMark(
                      position:
                          Varset('index') * Varset('value') / Varset('type'),
                      color: ColorEncode(
                          variable: 'type', values: Defaults.colors10),
                      size: SizeEncode(value: 2),
                      modifiers: [DodgeSizeModifier()],
                    )
                  ],
                  coord: RectCoord(
                    horizontalRangeUpdater: Defaults.horizontalRangeEvent,
                  ),
                  axes: [
                    Defaults.horizontalAxis..tickLine = TickLine(),
                    Defaults.verticalAxis,
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Candlestick Chart',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- A candlestick custom shape is provided.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Shape must be designated explicitly for a custom mark.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Make sure to specify a same scale for all variables in a same dimension.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'We insist that the price of a subject matter of investment is determined by its intrinsic value. Too much attention to the short-term fluctuations in prices is harmful. Thus a candlestick chart may misslead your investment decision.',
                  style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
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
                  marks: [
                    CustomMark(
                      shape: ShapeEncode(value: CandlestickShape()),
                      position: Varset('time') *
                          (Varset('start') +
                              Varset('max') +
                              Varset('min') +
                              Varset('end')),
                      color: ColorEncode(
                          encoder: (tuple) => tuple['end'] >= tuple['start']
                              ? Colors.red
                              : Colors.green),
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  coord: RectCoord(
                      horizontalRangeUpdater: Defaults.horizontalRangeEvent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _kBaseGroupPaddingHorizontal = 32.0;
const _kMinBarSize = 4.0;

/// Changes the position of marks while also updating their width to match
/// the number of marks in a single band. Useful for bar charts when the
/// width of the bars can be dynamic.
@immutable
class DodgeSizeModifier extends Modifier {
  @override
  AttributesGroups modify(
      AttributesGroups groups,
      Map<String, ScaleConv<dynamic, num>> scales,
      AlgForm form,
      CoordConv coord,
      Offset origin) {
    final xField = form.first[0];
    final band = (scales[xField]! as DiscreteScaleConv).band;

    final ratio = 1 / groups.length;
    final numGroups = groups.length;
    final groupHorizontalPadding = _kBaseGroupPaddingHorizontal / numGroups;
    final invertedGroupPaddingHorizontal =
        coord.invertDistance(groupHorizontalPadding, Dim.x);

    final effectiveBand = band - 2 * invertedGroupPaddingHorizontal;

    final maxWidth = coord.convert(const Offset(1, 0)).dx;
    final maxWidthInBand = effectiveBand * maxWidth;
    final maxWidthPerAttributes = maxWidthInBand / numGroups;
    final barHorizontalPadding = groupHorizontalPadding / 2;
    final size =
        max(maxWidthPerAttributes - barHorizontalPadding, _kMinBarSize);

    final bias = ratio * effectiveBand;

    // Negatively shift half of the total bias.
    var accumulated = -bias * (numGroups + 1) / 2;

    final AttributesGroups rst = [];
    for (final group in groups) {
      final groupRst = <Attributes>[];
      for (final attributes in group) {
        final oldPosition = attributes.position;

        groupRst.add(Attributes(
          index: attributes.index,
          tag: attributes.tag,
          position: oldPosition
              .map(
                (point) => Offset(point.dx + accumulated + bias, point.dy),
              )
              .toList(),
          shape: attributes.shape,
          color: attributes.color,
          gradient: attributes.gradient,
          elevation: attributes.elevation,
          label: attributes.label,
          size: size,
        ));
      }
      rst.add(groupRst);
      accumulated += bias;
    }

    return rst;
  }

  @override
  bool equalTo(Object other) {
    return other is DodgeSizeModifier;
  }
}
