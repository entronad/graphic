import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:quiver/iterables.dart';

import '../echarts_data.dart';

class EchartsPage extends StatelessWidget {
  EchartsPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Echarts Examples'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              // https://echarts.apache.org/examples/zh/editor.html?c=area-stack-gradient
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: areaStackGradientData,
                  variables: {
                    'day': Variable(
                      accessor: (Map datum) => datum['day'] as String,
                      scale: OrdinalScale(inflate: true),
                    ),
                    'value': Variable(
                      accessor: (Map datum) => datum['value'] as num,
                      scale: LinearScale(min: 0, max: 1500),
                    ),
                    'group': Variable(
                      accessor: (Map datum) => datum['group'].toString(),
                    ),
                  },
                  elements: [
                    AreaElement(
                      position:
                          Varset('day') * Varset('value') / Varset('group'),
                      shape: ShapeAttr(value: BasicAreaShape(smooth: true)),
                      gradient: GradientAttr(
                        variable: 'group',
                        values: [
                          const LinearGradient(
                            begin: Alignment(0, 0),
                            end: Alignment(0, 1),
                            colors: [
                              Color.fromARGB(204, 128, 255, 165),
                              Color.fromARGB(204, 1, 191, 236),
                            ],
                          ),
                          const LinearGradient(
                            begin: Alignment(0, 0),
                            end: Alignment(0, 1),
                            colors: [
                              Color.fromARGB(204, 0, 221, 255),
                              Color.fromARGB(204, 77, 119, 255),
                            ],
                          ),
                          const LinearGradient(
                            begin: Alignment(0, 0),
                            end: Alignment(0, 1),
                            colors: [
                              Color.fromARGB(204, 55, 162, 255),
                              Color.fromARGB(204, 116, 21, 219),
                            ],
                          ),
                          const LinearGradient(
                            begin: Alignment(0, 0),
                            end: Alignment(0, 1),
                            colors: [
                              Color.fromARGB(204, 255, 0, 135),
                              Color.fromARGB(204, 135, 0, 157),
                            ],
                          ),
                          const LinearGradient(
                            begin: Alignment(0, 0),
                            end: Alignment(0, 1),
                            colors: [
                              Color.fromARGB(204, 255, 191, 0),
                              Color.fromARGB(204, 224, 62, 76),
                            ],
                          ),
                        ],
                        updaters: {
                          'groupMouse': {
                            false: (gradient) => LinearGradient(
                                  begin: const Alignment(0, 0),
                                  end: const Alignment(0, 1),
                                  colors: [
                                    gradient.colors.first.withAlpha(25),
                                    gradient.colors.last.withAlpha(25),
                                  ],
                                ),
                          },
                          'groupTouch': {
                            false: (gradient) => LinearGradient(
                                  begin: const Alignment(0, 0),
                                  end: const Alignment(0, 1),
                                  colors: [
                                    gradient.colors.first.withAlpha(25),
                                    gradient.colors.last.withAlpha(25),
                                  ],
                                ),
                          },
                        },
                      ),
                      modifiers: [StackModifier()],
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
                    }, variable: 'day'),
                    'groupMouse': PointSelection(
                        on: {
                          GestureType.hover,
                        },
                        variable: 'group',
                        devices: {PointerDeviceKind.mouse}),
                    'tooltipTouch': PointSelection(on: {
                      GestureType.scaleUpdate,
                      GestureType.tapDown,
                      GestureType.longPressMoveUpdate
                    }, devices: {
                      PointerDeviceKind.touch
                    }, variable: 'day'),
                    'groupTouch': PointSelection(
                        on: {
                          GestureType.scaleUpdate,
                          GestureType.tapDown,
                          GestureType.longPressMoveUpdate
                        },
                        variable: 'group',
                        devices: {PointerDeviceKind.touch}),
                  },
                  tooltip: TooltipGuide(
                    selections: {'tooltipTouch', 'tooltipMouse'},
                    followPointer: [true, true],
                    align: Alignment.topLeft,
                  ),
                  crosshair: CrosshairGuide(
                    selections: {'tooltipTouch', 'tooltipMouse'},
                    followPointer: [false, true],
                  ),
                ),
              ),
              // https://echarts.apache.org/examples/zh/editor.html?c=line-marker
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: lineMarkerData,
                  variables: {
                    'day': Variable(
                      accessor: (Map datum) => datum['day'] as String,
                      scale: OrdinalScale(inflate: true),
                    ),
                    'value': Variable(
                      accessor: (Map datum) => datum['value'] as num,
                      scale: LinearScale(
                        max: 15,
                        min: -3,
                        tickCount: 7,
                        formatter: (v) => '${v.toInt()} ℃',
                      ),
                    ),
                    'group': Variable(
                      accessor: (Map datum) => datum['group'] as String,
                    ),
                  },
                  elements: [
                    LineElement(
                      position:
                          Varset('day') * Varset('value') / Varset('group'),
                      color: ColorAttr(
                        variable: 'group',
                        values: [
                          const Color(0xff5470c6),
                          const Color(0xff91cc75),
                        ],
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
                    }, variable: 'day', dim: Dim.x),
                    'tooltipTouch': PointSelection(on: {
                      GestureType.scaleUpdate,
                      GestureType.tapDown,
                      GestureType.longPressMoveUpdate
                    }, devices: {
                      PointerDeviceKind.touch
                    }, variable: 'day', dim: Dim.x),
                  },
                  tooltip: TooltipGuide(
                    followPointer: [true, true],
                    align: Alignment.topLeft,
                    variables: ['group', 'value'],
                  ),
                  crosshair: CrosshairGuide(
                    followPointer: [false, true],
                  ),
                  annotations: [
                    LineAnnotation(
                      dim: Dim.y,
                      value: 11.14,
                      style: StrokeStyle(
                        color: const Color(0xff5470c6).withAlpha(100),
                        dash: [2],
                      ),
                    ),
                    LineAnnotation(
                      dim: Dim.y,
                      value: 1.57,
                      style: StrokeStyle(
                        color: const Color(0xff91cc75).withAlpha(100),
                        dash: [2],
                      ),
                    ),
                    MarkAnnotation(
                      relativePath:
                          Paths.circle(center: Offset.zero, radius: 5),
                      style: Paint()..color = const Color(0xff5470c6),
                      values: ['Wed', 13],
                    ),
                    MarkAnnotation(
                      relativePath:
                          Paths.circle(center: Offset.zero, radius: 5),
                      style: Paint()..color = const Color(0xff5470c6),
                      values: ['Sun', 9],
                    ),
                    MarkAnnotation(
                      relativePath:
                          Paths.circle(center: Offset.zero, radius: 5),
                      style: Paint()..color = const Color(0xff91cc75),
                      values: ['Tue', -2],
                    ),
                    MarkAnnotation(
                      relativePath:
                          Paths.circle(center: Offset.zero, radius: 5),
                      style: Paint()..color = const Color(0xff91cc75),
                      values: ['Thu', 5],
                    ),
                    TagAnnotation(
                      label: Label(
                          '13',
                          LabelStyle(
                            style: Defaults.textStyle,
                            offset: const Offset(0, -10),
                          )),
                      values: ['Wed', 13],
                    ),
                    TagAnnotation(
                      label: Label(
                          '9',
                          LabelStyle(
                            style: Defaults.textStyle,
                            offset: const Offset(0, -10),
                          )),
                      values: ['Sun', 9],
                    ),
                    TagAnnotation(
                      label: Label(
                          '-2',
                          LabelStyle(
                            style: Defaults.textStyle,
                            offset: const Offset(0, -10),
                          )),
                      values: ['Tue', -2],
                    ),
                    TagAnnotation(
                      label: Label(
                          '5',
                          LabelStyle(
                            style: Defaults.textStyle,
                            offset: const Offset(0, -10),
                          )),
                      values: ['Thu', 5],
                    ),
                  ],
                ),
              ),
              // https://echarts.apache.org/examples/zh/editor.html?c=line-sections
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: zip(lineSectionsData).toList(),
                  variables: {
                    'time': Variable(
                      accessor: (List datum) => datum[0] as String,
                      scale: OrdinalScale(inflate: true, tickCount: 6),
                    ),
                    'value': Variable(
                      accessor: (List datum) => datum[1] as num,
                      scale: LinearScale(
                        max: 800,
                        min: 0,
                        formatter: (v) => '${v.toInt()} W',
                      ),
                    ),
                  },
                  elements: [
                    LineElement(
                      shape: ShapeAttr(value: BasicLineShape(smooth: true)),
                    )
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
                    }, dim: Dim.x),
                    'tooltipTouch': PointSelection(on: {
                      GestureType.scaleUpdate,
                      GestureType.tapDown,
                      GestureType.longPressMoveUpdate
                    }, devices: {
                      PointerDeviceKind.touch
                    }, dim: Dim.x),
                  },
                  tooltip: TooltipGuide(
                    followPointer: [true, true],
                    align: Alignment.topLeft,
                  ),
                  crosshair: CrosshairGuide(
                    followPointer: [false, true],
                  ),
                  annotations: [
                    RegionAnnotation(
                      values: ['07:30', '10:00'],
                      color: const Color.fromARGB(120, 255, 173, 177),
                    ),
                    RegionAnnotation(
                      values: ['17:30', '21:15'],
                      color: const Color.fromARGB(120, 255, 173, 177),
                    ),
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
