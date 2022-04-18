import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../data.dart';

class TriangleShape extends IntervalShape {
  @override
  List<Figure> renderGroup(
    List<Aes> group,
    CoordConv coord,
    Offset origin,
  ) {
    assert(coord is RectCoordConv);
    assert(coord.transposed == false);

    final rst = <Figure>[];

    for (var item in group) {
      rst.addAll(renderItem(item, coord, origin));
    }

    return rst;
  }

  @override
  List<Figure> renderItem(
    Aes item,
    CoordConv coord,
    Offset origin,
  ) {
    for (var point in item.position) {
      if (!point.dy.isFinite) {
        return [];
      }
    }

    final start = coord.convert(item.position[0]);
    final end = coord.convert(item.position[1]);
    final size = item.size ?? defaultSize;
    final startLeft = Offset(start.dx - size / 2, start.dy);
    final startRight = Offset(start.dx + size / 2, start.dy);
    final path = Path()..addPolygon([end, startLeft, startRight], true);

    return renderBasicItem(path, item, false, 0);
  }

  @override
  bool equalTo(Object other) => other is TriangleShape;
}

List<Figure> simpleTooltip(
  Offset anchor,
  Map<int, Tuple> selectedTuples,
) {
  List<Figure> figures;

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

  final widowPath = Path()
    ..addRRect(
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

List<Figure> centralPieLabel(
  Offset anchor,
  Map<int, Tuple> selectedTuples,
) {
  final tuple = selectedTuples.values.last;

  final titleSpan = TextSpan(
    text: tuple['genre'].toString() + '\n',
    style: const TextStyle(
      fontSize: 14,
      color: Colors.black87,
    ),
  );

  final valueSpan = TextSpan(
    text: tuple['sold'].toString(),
    style: const TextStyle(
      fontSize: 28,
      color: Colors.black87,
    ),
  );

  final painter = TextPainter(
    text: TextSpan(children: [titleSpan, valueSpan]),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );
  painter.layout();

  final paintPoint = getPaintPoint(
    const Offset(175, 150),
    painter.width,
    painter.height,
    Alignment.center,
  );

  return [TextFigure(painter, paintPoint)];
}

class PolygonCustomPage extends StatelessWidget {
  PolygonCustomPage({Key? key}) : super(key: key);

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
                child: const Text(
                  'Heatmap',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
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
                  elements: [
                    PolygonElement(
                      color: ColorAttr(
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
                child: const Text(
                  'Heatmap fade',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- Tap to select one, and others will fade.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- With corner radius.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
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
                  elements: [
                    PolygonElement(
                      shape: ShapeAttr(
                          value: HeatmapShape(
                              borderRadius: BorderRadius.circular(4))),
                      color: ColorAttr(
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
                child: const Text(
                  'Polar Heatmap of Polygon',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- Tap to select one for tooltip, and others will fade.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
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
                  elements: [
                    PolygonElement(
                      color: ColorAttr(
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
                child: const Text(
                  'Polar Heatmap of Sector',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- Tap to select one for tooltip, and others will fade.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
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
                  elements: [
                    PolygonElement(
                      shape: ShapeAttr(value: HeatmapShape(sector: true)),
                      color: ColorAttr(
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
                child: const Text(
                  'Custom Shape and Tooltip',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- A custom shape attribution should corresponds to the geometry elemnet type.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
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
                  elements: [
                    IntervalElement(
                      shape: ShapeAttr(value: TriangleShape()),
                      label: LabelAttr(
                          encoder: (tuple) => Label(tuple['sold'].toString())),
                      elevation: ElevationAttr(value: 0, updaters: {
                        'tap': {true: (_) => 5}
                      }),
                      color: ColorAttr(value: Defaults.primaryColor, updaters: {
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
                child: const Text(
                  'Central Pie Label by Custom Tooltip',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
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
                  elements: [
                    IntervalElement(
                      position: Varset('percent') / Varset('genre'),
                      color: ColorAttr(
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
                child: const Text(
                  'Custom Legend',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- Custom legend by mark and tag annotations.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- With dodge modifier.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
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
                  elements: [
                    IntervalElement(
                      position:
                          Varset('index') * Varset('value') / Varset('type'),
                      color: ColorAttr(
                          variable: 'type', values: Defaults.colors10),
                      size: SizeAttr(value: 2),
                      modifiers: [DodgeModifier(ratio: 0.1)],
                    )
                  ],
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
                    MarkAnnotation(
                      relativePath: Path()
                        ..addRect(Rect.fromCircle(
                            center: const Offset(0, 0), radius: 5)),
                      style: Paint()..color = Defaults.colors10[0],
                      anchor: (size) => const Offset(25, 290),
                    ),
                    TagAnnotation(
                      label: Label(
                        'Email',
                        LabelStyle(
                            style: Defaults.textStyle,
                            align: Alignment.centerRight),
                      ),
                      anchor: (size) => const Offset(34, 290),
                    ),
                    MarkAnnotation(
                      relativePath: Path()
                        ..addRect(Rect.fromCircle(
                            center: const Offset(0, 0), radius: 5)),
                      style: Paint()..color = Defaults.colors10[1],
                      anchor: (size) => Offset(25 + size.width / 5, 290),
                    ),
                    TagAnnotation(
                      label: Label(
                        'Affiliate',
                        LabelStyle(
                            style: Defaults.textStyle,
                            align: Alignment.centerRight),
                      ),
                      anchor: (size) => Offset(34 + size.width / 5, 290),
                    ),
                    MarkAnnotation(
                      relativePath: Path()
                        ..addRect(Rect.fromCircle(
                            center: const Offset(0, 0), radius: 5)),
                      style: Paint()..color = Defaults.colors10[2],
                      anchor: (size) => Offset(25 + size.width / 5 * 2, 290),
                    ),
                    TagAnnotation(
                      label: Label(
                        'Video',
                        LabelStyle(
                            style: Defaults.textStyle,
                            align: Alignment.centerRight),
                      ),
                      anchor: (size) => Offset(34 + size.width / 5 * 2, 290),
                    ),
                    MarkAnnotation(
                      relativePath: Path()
                        ..addRect(Rect.fromCircle(
                            center: const Offset(0, 0), radius: 5)),
                      style: Paint()..color = Defaults.colors10[3],
                      anchor: (size) => Offset(25 + size.width / 5 * 3, 290),
                    ),
                    TagAnnotation(
                      label: Label(
                        'Direct',
                        LabelStyle(
                            style: Defaults.textStyle,
                            align: Alignment.centerRight),
                      ),
                      anchor: (size) => Offset(34 + size.width / 5 * 3, 290),
                    ),
                    MarkAnnotation(
                      relativePath: Path()
                        ..addRect(Rect.fromCircle(
                            center: const Offset(0, 0), radius: 5)),
                      style: Paint()..color = Defaults.colors10[4],
                      anchor: (size) => Offset(25 + size.width / 5 * 4, 290),
                    ),
                    TagAnnotation(
                      label: Label(
                        'Search',
                        LabelStyle(
                            style: Defaults.textStyle,
                            align: Alignment.centerRight),
                      ),
                      anchor: (size) => Offset(34 + size.width / 5 * 4, 290),
                    ),
                  ],
                ),
              ),
              Container(
                child: const Text(
                  'Custom Modifier',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- With dodge and size modifier that scales the interval element width to fit within its band',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
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
                  elements: [
                    IntervalElement(
                      position:
                          Varset('index') * Varset('value') / Varset('type'),
                      color: ColorAttr(
                          variable: 'type', values: Defaults.colors10),
                      size: SizeAttr(value: 2),
                      modifiers: [DodgeSizeModifier()],
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis..tickLine = TickLine(),
                    Defaults.verticalAxis,
                  ],
                ),
              ),
              Container(
                child: const Text(
                  'Candlestick Chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- A candlestick custom shape is provided.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- Shape must be designated explicitly for a custom element.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- Make sure to specify a same scale for all variables in a same dimension.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  'We insist that the price of a subject matter of investment is determined by its intrinsic value. Too much attention to the short-term fluctuations in prices is harmful. Thus a candlestick chart may misslead your investment decision.',
                  style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                alignment: Alignment.centerLeft,
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
                  elements: [
                    CustomElement(
                      shape: ShapeAttr(value: CandlestickShape()),
                      position: Varset('time') *
                          (Varset('start') +
                              Varset('max') +
                              Varset('min') +
                              Varset('end')),
                      color: ColorAttr(
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
                      horizontalRangeUpdater: Defaults.horizontalRangeSignal),
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

/// Changes the position of elements while also updating their width to match
/// the number of elements in a single band. Useful for bar charts when the
/// width of the bars can be dynamic.
@immutable
class DodgeSizeModifier extends Modifier {
  @override
  void modify(AesGroups groups, Map<String, ScaleConv<dynamic, num>> scales,
      AlgForm form, CoordConv coord, Offset origin) {
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
    final maxWidthPerAes = maxWidthInBand / numGroups;
    final barHorizontalPadding = groupHorizontalPadding / 2;
    final size = max(maxWidthPerAes - barHorizontalPadding, _kMinBarSize);

    final bias = ratio * effectiveBand;

    // Negatively shift half of the total bias.
    var accumulated = -bias * (numGroups + 1) / 2;

    for (final group in groups) {
      for (final aes in group) {
        final oldPosition = aes.position;
        aes.position = oldPosition
            .map(
              (point) => Offset(point.dx + accumulated + bias, point.dy),
            )
            .toList();

        aes.size = size;
      }
      accumulated += bias;
    }
  }

  @override
  bool equalTo(Object other) {
    return super == other;
  }
}
