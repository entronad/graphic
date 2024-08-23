import 'dart:async';
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/builtin_layers.dart';
import 'package:graphic/src/encode/encode.dart';
import 'package:graphic/src/encode/channel.dart';
import 'package:graphic/src/encode/color.dart';
import 'package:graphic/src/encode/gradient.dart';
import 'package:graphic/src/encode/position.dart';
import 'package:graphic/src/encode/shape.dart';
import 'package:graphic/src/encode/elevation.dart';
import 'package:graphic/src/encode/size.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/chart/size.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/defaults.dart';
import 'package:graphic/src/common/dim.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/common/reserveds.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/graffiti/element/element.dart';
import 'package:graphic/src/graffiti/element/label.dart';
import 'package:graphic/src/mark/mark.dart';
import 'package:graphic/src/mark/modifier/modifier.dart';
import 'package:graphic/src/guide/annotation/custom.dart';
import 'package:graphic/src/guide/annotation/element.dart';
import 'package:graphic/src/guide/annotation/line.dart';
import 'package:graphic/src/guide/annotation/region.dart';
import 'package:graphic/src/guide/annotation/tag.dart';
import 'package:graphic/src/guide/axis/axis.dart';
import 'package:graphic/src/guide/interaction/crosshair.dart';
import 'package:graphic/src/guide/interaction/tooltip.dart';
import 'package:graphic/src/interaction/gesture.dart';
import 'package:graphic/src/interaction/selection/interval.dart';
import 'package:graphic/src/interaction/selection/point.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/interaction/event.dart';
import 'package:graphic/src/scale/linear.dart';
import 'package:graphic/src/scale/ordinal.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/time.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/variable/transform/filter.dart';
import 'package:graphic/src/variable/transform/map.dart';
import 'package:graphic/src/variable/transform/proportion.dart';
import 'package:graphic/src/variable/transform/sort.dart';
import 'package:graphic/src/variable/variable.dart';

/// The default padding function for rectangle coordinate.
EdgeInsets _defaultRectPadding(Size _) =>
    const EdgeInsets.fromLTRB(40, 5, 10, 20);

/// The default padding function for polar coordinate.
EdgeInsets _defaultPolarPadding(Size _) => const EdgeInsets.all(10);

/// Parses the specification for a view.
void parse<D>(
  Chart<D> spec,
  ChartView<D> view,
  Size chartSize,
) {
  // Event

  final gestureEvent = view.add(EventOp<GestureEvent>());

  final gestureStream = spec.gestureStream ?? StreamController<GestureEvent>();
  view.bindStream(gestureStream, gestureEvent);
  view.gestureStream = gestureStream;

  final resizeEvent = view.add(EventOp<ResizeEvent>());

  final resizeStream = spec.resizeStream ?? StreamController<ResizeEvent>();
  view.bindStream(resizeStream, resizeEvent);
  view.resizeStream = resizeStream;

  final changeDataEvent = view.add(EventOp<ChangeDataEvent<D>>());

  final changeDataStream =
      spec.changeDataStream ?? StreamController<ChangeDataEvent<D>>();
  view.bindStream(changeDataStream, changeDataEvent);
  view.changeDataStream = changeDataStream;

  final event = view.add(EventReducerOp<D>({
    'gesture': gestureEvent,
    'resize': resizeEvent,
    'changeData': changeDataEvent,
  }));

  // Coord.

  final size = view.add(SizeOp({
    'event': resizeEvent,
  }, chartSize));

  final coordSpec = spec.coord ?? RectCoord();

  final regionPadding = spec.padding ??
      (coordSpec is RectCoord ? _defaultRectPadding : _defaultPolarPadding);

  final region = view.add(RegionOp({
    'size': size,
    'padding': regionPadding,
  }));

  if (coordSpec.color != null) {
    final regionBackgroundScene = view.graffiti.createScene(
        layer: coordSpec.layer ?? 0,
        builtinLayer: BuiltinLayers.regionBackground);
    if (coordSpec is RectCoord) {
      view.add(RectRegionColorRenderOp({
        'region': region,
        'color': coordSpec.color,
      }, regionBackgroundScene, view));
    } else {
      view.add(PolarRegionColorRenderOp({
        'region': region,
        'color': coordSpec.color,
      }, regionBackgroundScene, view));
    }
  } else if (coordSpec.gradient != null) {
    final regionBackgroundScene = view.graffiti.createScene(
        layer: coordSpec.layer ?? 0,
        builtinLayer: BuiltinLayers.regionBackground);
    if (coordSpec is RectCoord) {
      view.add(RectRegionGradientRenderOp({
        'region': region,
        'gradient': coordSpec.gradient,
      }, regionBackgroundScene, view));
    } else {
      view.add(PolarRegionGradientRenderOp({
        'region': region,
        'gradient': coordSpec.gradient,
      }, regionBackgroundScene, view));
    }
  }

  late CoordConvOp coord;
  if (coordSpec is RectCoord) {
    Operator<List<double>> horizontalRange = view.add(Value<List<double>>(
      coordSpec.horizontalRange ?? [0, 1],
    ));
    if (coordSpec.horizontalRangeUpdater != null) {
      horizontalRange = view.add(EventUpdateOp({
        'update': coordSpec.horizontalRangeUpdater,
        'initialValue': horizontalRange,
        'event': event,
      }));
    }
    Operator<List<double>> verticalRange = view.add(Value<List<double>>(
      coordSpec.verticalRange ?? [0, 1],
    ));
    if (coordSpec.verticalRangeUpdater != null) {
      verticalRange = view.add(EventUpdateOp({
        'update': coordSpec.verticalRangeUpdater,
        'initialValue': verticalRange,
        'event': event,
      }));
    }

    coord = view.add(RectCoordConvOp({
      'region': region,
      'dimCount': coordSpec.dimCount ?? 2,
      'dimFill': coordSpec.dimFill ?? 0.5,
      'transposed': coordSpec.transposed ?? false,
      'renderRangeX': horizontalRange,
      'renderRangeY': verticalRange,
    }));
  } else {
    coordSpec as PolarCoord;
    Operator<List<double>> angleRange = view.add(Value<List<double>>(
      coordSpec.angleRange ?? [0, 1],
    ));
    if (coordSpec.angleRangeUpdater != null) {
      angleRange = view.add(EventUpdateOp({
        'update': coordSpec.angleRangeUpdater,
        'initialValue': angleRange,
        'event': event,
      }));
    }
    Operator<List<double>> radiusRange = view.add(Value<List<double>>(
      coordSpec.radiusRange ?? [0, 1],
    ));
    if (coordSpec.radiusRangeUpdater != null) {
      radiusRange = view.add(EventUpdateOp({
        'update': coordSpec.radiusRangeUpdater,
        'initialValue': radiusRange,
        'event': event,
      }));
    }

    coord = view.add(PolarCoordConvOp({
      'region': region,
      'dimCount': coordSpec.dimCount ?? 2,
      'dimFill': coordSpec.dimFill ?? 0.5,
      'transposed': coordSpec.transposed ?? false,
      'renderRangeX': angleRange,
      'renderRangeY': radiusRange,
      'startAngle': coordSpec.startAngle ?? (-pi / 2),
      'endAngle': coordSpec.endAngle ?? (3 * pi / 2),
      'startRadius': coordSpec.startRadius ?? 0.0,
      'endRadius': coordSpec.endRadius ?? 1.0,
    }));
  }

  // Variable

  final data = view.add(DataOp<D>({'event': changeDataEvent}, spec.data));

  final accessors = <String, Accessor<D, dynamic>>{};
  final variableSpecs = spec.variables;
  final scaleSpecs = <String, Scale>{};
  for (var field in variableSpecs.keys) {
    final accessor = variableSpecs[field]!.accessor;
    final scaleSpec = variableSpecs[field]!.scale;
    accessors[field] = accessor;
    if (accessor is Accessor<D, String>) {
      scaleSpecs[field] = scaleSpec ?? OrdinalScale();
    } else if (accessor is Accessor<D, num>) {
      scaleSpecs[field] = scaleSpec ?? LinearScale();
    } else if (accessor is Accessor<D, DateTime>) {
      scaleSpecs[field] = scaleSpec ?? TimeScale();
    } else {
      throw ArgumentError('Variable value must be String, num, or DataTime');
    }
  }

  Operator<List<Tuple>> tuples = view.add(VariableOp<D>({
    'accessors': accessors,
    'data': data,
  }));

  final transformSpecs = spec.transforms;
  if (transformSpecs != null) {
    for (var transformSpec in transformSpecs) {
      if (transformSpec is Filter) {
        tuples = view.add(FilterOp({
          'tuples': tuples,
          'predicate': transformSpec.predicate,
        }));
      } else if (transformSpec is MapTrans) {
        tuples = view.add(MapOp({
          'tuples': tuples,
          'mapper': transformSpec.mapper,
        }));
      } else if (transformSpec is Proportion) {
        final as = transformSpec.as;
        assert(scaleSpecs[as] == null);
        scaleSpecs[as] = transformSpec.scale ?? LinearScale(min: 0, max: 1);

        var nesters = <AlgForm>[];
        if (transformSpec.nest != null) {
          final exp = Varset(as) / transformSpec.nest!;
          nesters = exp.nesters;
        }

        tuples = view.add(ProportionOp({
          'tuples': tuples,
          'variable': transformSpec.variable,
          'nesters': nesters,
          'as': as,
        }));
      } else if (transformSpec is Sort) {
        tuples = view.add(SortOp({
          'tuples': tuples,
          'compare': transformSpec.compare,
        }));
      } else {
        throw UnimplementedError('No such transform $transformSpec.');
      }
    }
  }

  assert(Reserveds.legalIdentifiers(scaleSpecs.keys));

  // Scale.

  final scales = view.add(ScaleConvOp({
    'tuples': tuples,
    'specs': scaleSpecs,
  }));

  final scaleds = view.add(ScaleOp({
    'tuples': tuples,
    'convs': scales,
  }));

  // Selection.

  final gesture = view.add(GestureOp({
    'event': gestureEvent,
  }));

  SelectorOp? selectors;
  if (spec.selections != null) {
    final selectSpecs = spec.selections!;
    final onTypes = <GestureType, List<String>>{};
    final clearTypes = <GestureType>{};
    for (var name in selectSpecs.keys) {
      final selectSpec = selectSpecs[name]!;

      assert(!(selectSpec is IntervalSelection && spec.coord is PolarCoord));

      final on = selectSpec.on ??
          (selectSpec is PointSelection
              ? {GestureType.tap}
              : {GestureType.scaleUpdate, GestureType.scroll});
      final clear = selectSpec.clear ?? {GestureType.doubleTap};
      for (var type in on) {
        if (onTypes[type] == null) {
          onTypes[type] = [name];
        } else {
          onTypes[type]!.add(name);
        }
      }
      clearTypes.addAll(clear);
    }

    selectors = view.add(SelectorOp({
      'specs': selectSpecs,
      'onTypes': onTypes,
      'clearTypes': clearTypes,
      'gesture': gesture,
    }));

    for (var name in selectSpecs.keys) {
      final selectorScene = view.graffiti.createScene(
          layer: selectSpecs[name]!.layer ?? 0,
          builtinLayer: BuiltinLayers.selector);
      view.add(SelectorRenderOp({
        'selectors': selectors,
        'name': name,
      }, selectorScene, view));
    }
  }

  // Mark.

  // For all marks, they either all have or all have not select operator.
  final selectOpList = <SelectOp>[];
  final groupsList = <Operator<AttributesGroups>>[];
  // First term of the form of the first mark, in order to get first variable
  // of each dimension.
  AlgTerm? firstVariables;

  for (var markSpec in spec.marks) {
    var form = markSpec.position?.form;
    // Default algebracal form.
    if (form == null) {
      final variables = scaleSpecs.keys.toList();
      form = (Varset(variables[0]) * Varset(variables[1])).form;
    }

    final nesters = markSpec.position?.nesters ?? <AlgForm>[];

    firstVariables ??= form.first;

    final origin = view.add(OriginOp({
      'form': form,
      'scales': scales,
      'coord': coord,
    }));

    final positionEncoder = view.add(PositionEncoderOp({
      'form': form,
      'scales': scales,
      'completer': getPositionCompleter(markSpec),
      'origin': origin,
    }));

    final attributes = view.add(EncodeOp({
      'scaleds': scaleds,
      'tuples': tuples,
      'positionEncoder': positionEncoder,
      'shapeEncoder': getChannelEncoder<Shape>(
        markSpec.shape ?? ShapeEncode(value: getDefaultShape(markSpec)),
        scaleSpecs,
        null,
      ),
      // Uses a default color when both color and gradient encodes are null.
      'colorEncoder': markSpec.gradient == null
          ? getChannelEncoder<Color>(
              markSpec.color ?? ColorEncode(value: Defaults.primaryColor),
              scaleSpecs,
              (List<Color> values, List<double> stops) =>
                  ContinuousColorConv(values, stops),
            )
          : null,
      'gradientEncoder': markSpec.gradient == null
          ? null
          : getChannelEncoder<Gradient>(
              markSpec.gradient!,
              scaleSpecs,
              (List<Gradient> values, List<double> stops) =>
                  ContinuousGradientConv(values, stops),
            ),
      'elevationEncoder': markSpec.elevation == null
          ? null
          : getChannelEncoder<double>(
              markSpec.elevation!,
              scaleSpecs,
              (List<double> values, List<double> stops) =>
                  ContinuousElevationConv(values, stops),
            ),
      'labelEncoder': markSpec.label == null
          ? null
          : CustomEncoder<Label>(markSpec.label!.encoder!),
      'sizeEncoder': markSpec.size == null
          ? null
          : getChannelEncoder<double>(
              markSpec.size!,
              scaleSpecs,
              (List<double> values, List<double> stops) =>
                  ContinuousSizeConv(values, stops),
            ),
      'tagEncoder': markSpec.tag,
    }));

    Operator<AttributesGroups> groups = view.add(GroupOp({
      'attributes': attributes,
      'tuples': tuples,
      'nesters': nesters,
      'scales': scales,
    }));

    if (markSpec.modifiers != null) {
      for (var modifier in markSpec.modifiers!) {
        groups = view.add(ModifyOp({
          'modifier': modifier,
          'groups': groups,
          'scales': scales,
          'form': form,
          'coord': coord,
          'origin': origin,
        }));
      }
    }

    if (selectors != null) {
      final selected = view.add(SelectOp({
        'selectors': selectors,
        'groups': groups,
        'tuples': tuples,
        'coord': coord,
      }, markSpec.selected));
      if (markSpec.selectionStream != null) {
        view.bindStream(markSpec.selectionStream!, selected);
      }
      selectOpList.add(selected);

      final shapeUpdaters = markSpec.shape?.updaters;
      final colorUpdaters = markSpec.color?.updaters;
      final gradientUpdaters = markSpec.gradient?.updaters;
      final elevationUpdaters = markSpec.elevation?.updaters;
      final labelUpdaters = markSpec.label?.updaters;
      final sizeUpdaters = markSpec.size?.updaters;

      final updaterNames = <String>{};
      if (shapeUpdaters != null) {
        updaterNames.addAll(shapeUpdaters.keys);
      }
      if (colorUpdaters != null) {
        updaterNames.addAll(colorUpdaters.keys);
      }
      if (gradientUpdaters != null) {
        updaterNames.addAll(gradientUpdaters.keys);
      }
      if (elevationUpdaters != null) {
        updaterNames.addAll(elevationUpdaters.keys);
      }
      if (labelUpdaters != null) {
        updaterNames.addAll(labelUpdaters.keys);
      }
      if (sizeUpdaters != null) {
        updaterNames.addAll(sizeUpdaters.keys);
      }

      final update = view.add(SelectionUpdateOp({
        'groups': groups,
        'selected': selected,
        'shapeUpdaters': shapeUpdaters,
        'colorUpdaters': colorUpdaters,
        'gradientUpdaters': gradientUpdaters,
        'elevationUpdaters': elevationUpdaters,
        'labelUpdaters': labelUpdaters,
        'sizeUpdaters': sizeUpdaters,
        'updaterNames': updaterNames,
      }));
      groups = update;
    }

    groupsList.add(groups);

    final markPrimitiveScene = view.graffiti.createScene(
        layer: markSpec.layer ?? 0,
        builtinLayer: BuiltinLayers.mark,
        transition: markSpec.transition);
    view.add(MarkPrimitiveRenderOp({
      'groups': groups,
      'coord': coord,
      'origin': origin,
      'transition': markSpec.transition,
      'entrance': markSpec.entrance ?? {MarkEntrance.opacity},
    }, markPrimitiveScene, view));

    final markLabelScene = view.graffiti.createScene(
        layer: markSpec.layer ?? 0,
        builtinLayer: BuiltinLayers.mark,
        transition: markSpec.transition);
    view.add(MarkLabelRenderOp({
      'groups': groups,
      'coord': coord,
      'origin': origin,
      'transition': markSpec.transition,
      'entrance': markSpec.entrance ?? {MarkEntrance.opacity},
    }, markLabelScene, view));
  }

  // Guide.

  if (spec.axes != null) {
    for (var i = 0; i < spec.axes!.length; i++) {
      final axisSpec = spec.axes![i];
      final dim = axisSpec.dim ?? (i == 0 ? Dim.x : Dim.y);
      final variable =
          axisSpec.variable ?? firstVariables![dim == Dim.x ? 0 : 1];

      final ticks = view.add(TickInfoOp({
        'variable': variable,
        'scales': scales,
        'tickLine': axisSpec.tickLine,
        'tickLineMapper': axisSpec.tickLineMapper,
        'label': axisSpec.label,
        'labelMapper': axisSpec.labelMapper,
        'grid': axisSpec.grid,
        'gridMapper': axisSpec.gridMapper,
        'labelBackground': axisSpec.labelBackground,
        'labelBackgroundMapper': axisSpec.labelBackgroundMapper,
      }));

      final axisScene = view.graffiti.createScene(
          layer: axisSpec.layer ?? 0, builtinLayer: BuiltinLayers.axis);
      view.add(AxisRenderOp({
        'coord': coord,
        'dim': dim,
        'position': axisSpec.position ?? 0.0,
        'flip': axisSpec.flip ?? false,
        'line': axisSpec.line,
        'ticks': ticks,
      }, axisScene, view));

      final gridScene = view.graffiti.createScene(
          layer: axisSpec.gridZIndex ?? 0, builtinLayer: BuiltinLayers.grid);
      view.add(GridRenderOp({
        'coord': coord,
        'dim': dim,
        'ticks': ticks,
      }, gridScene, view));
    }
  }

  if (spec.annotations != null) {
    for (var annotSpec in spec.annotations!) {
      if (annotSpec is RegionAnnotation) {
        final dim = annotSpec.dim ?? Dim.x;
        final variable =
            annotSpec.variable ?? firstVariables![dim == Dim.x ? 0 : 1];
        final annotScene = view.graffiti.createScene(
            layer: annotSpec.layer ?? 0,
            builtinLayer: BuiltinLayers.regionAnnot);
        view.add(RegionAnnotRenderOp({
          'dim': dim,
          'variable': variable,
          'values': annotSpec.values,
          'color': annotSpec.color,
          'gradient': annotSpec.gradient,
          'scales': scales,
          'coord': coord,
        }, annotScene, view));
      } else if (annotSpec is LineAnnotation) {
        final dim = annotSpec.dim ?? Dim.x;
        final variable =
            annotSpec.variable ?? firstVariables![dim == Dim.x ? 0 : 1];
        final annotScene = view.graffiti.createScene(
            layer: annotSpec.layer ?? 0, builtinLayer: BuiltinLayers.lineAnnot);
        view.add(LineAnnotRenderOp({
          'dim': dim,
          'variable': variable,
          'value': annotSpec.value,
          'style': annotSpec.style,
          'scales': scales,
          'coord': coord,
        }, annotScene, view));
      } else if (annotSpec is ElementAnnotation) {
        Operator<Offset> anchor;
        if (annotSpec.anchor != null) {
          anchor = view.add(ElementAnnotSetAnchorOp({
            'anchor': annotSpec.anchor,
            'size': size,
          }));
        } else {
          anchor = view.add(ElementAnnotCalcAnchorOp({
            'variables': annotSpec.variables ??
                [
                  firstVariables![0],
                  firstVariables[1],
                ],
            'values': annotSpec.values,
            'scales': scales,
            'coord': coord,
          }));
        }

        ElementAnnotOp annot;
        if (annotSpec is TagAnnotation) {
          annot = view.add(TagAnnotOp({
            'anchor': anchor,
            'label': annotSpec.label,
          }));
        } else {
          annotSpec as CustomAnnotation;
          annot = view.add(CustomAnnotOp({
            'anchor': anchor,
            'size': size,
            'renderer': annotSpec.renderer,
          }));
        }

        final annotScene = view.graffiti.createScene(
            layer: annotSpec.layer ?? 0,
            builtinLayer: BuiltinLayers.elementAnnot);
        view.add(ElementAnnotRenderOp({
          'elements': annot,
          'clip': annotSpec.clip ?? false,
          'coord': coord,
        }, annotScene, view));
      } else {
        throw UnimplementedError('No such annotation type $annotSpec.');
      }
    }
  }

  if (spec.crosshair != null) {
    assert(selectors != null);

    final crosshairSpec = spec.crosshair!;
    final markIndex = crosshairSpec.mark ?? 0;

    final crosshairScene = view.graffiti.createScene(
        layer: crosshairSpec.layer ?? 0, builtinLayer: BuiltinLayers.crosshair);
    final showLabel = crosshairSpec.showLabel ?? [false, false];
    view.add(CrosshairRenderOp({
      'selections': crosshairSpec.selections ?? spec.selections!.keys.toSet(),
      'selectors': selectors!,
      'selected': selectOpList[markIndex],
      'coord': coord,
      'groups': groupsList[markIndex],
      'tuples': tuples,
      'styles': crosshairSpec.styles ??
          [
            PaintStyle(
                strokeColor: showLabel[0]
                    ? const Color(0xff000000)
                    : const Color(0xffbfbfbf)),
            PaintStyle(
                strokeColor: showLabel[1]
                    ? const Color(0xff000000)
                    : const Color(0xffbfbfbf)),
          ],
      'labelStyles': crosshairSpec.labelStyles ??
          [
            LabelStyle(textStyle: const TextStyle(color: Color(0xffffffff))),
            LabelStyle(textStyle: const TextStyle(color: Color(0xffffffff))),
          ],
      'labelBackgroundStyles': crosshairSpec.labelBackgroundStyles ??
          [
            PaintStyle(fillColor: const Color(0xff000000)),
            PaintStyle(fillColor: const Color(0xff000000)),
          ],
      'labelPaddings': crosshairSpec.labelPaddings ?? [0.0, 0.0],
      'showLabel': showLabel,
      'formatter': crosshairSpec.formatter ?? [null, null],
      'followPointer': crosshairSpec.followPointer ?? [false, false],
      'scales': scales,
      'size': size,
      'padding': regionPadding,
      'expandEdges': crosshairSpec.expandEdges ?? [false, false, false, false],
    }, crosshairScene, view));
  }

  if (spec.tooltip != null) {
    assert(selectors != null);

    final tooltipSpec = spec.tooltip!;
    final markIndex = tooltipSpec.mark ?? 0;

    final tooltipScene = view.graffiti.createScene(
        layer: tooltipSpec.layer ?? 0, builtinLayer: BuiltinLayers.tooltip);
    view.add(TooltipRenderOp({
      'selections': tooltipSpec.selections ?? spec.selections!.keys.toSet(),
      'selectors': selectors!,
      'selected': selectOpList[markIndex],
      'selectionSpecs': spec.selections!,
      'coord': coord,
      'groups': groupsList[markIndex],
      'tuples': tuples,
      'align': tooltipSpec.align ?? Alignment.center,
      'offset': tooltipSpec.offset,
      'padding': tooltipSpec.padding ?? const EdgeInsets.all(5),
      'backgroundColor': tooltipSpec.backgroundColor ?? const Color(0xf0ffffff),
      'radius': tooltipSpec.radius ?? const Radius.circular(3),
      'elevation': tooltipSpec.elevation ?? 3.0,
      'textStyle': tooltipSpec.textStyle ??
          const TextStyle(
            color: Color(0xff595959),
            fontSize: 12,
          ),
      'multiTuples': tooltipSpec.multiTuples,
      'renderer': tooltipSpec.renderer,
      'followPointer': tooltipSpec.followPointer ?? [false, false],
      'anchor': tooltipSpec.anchor,
      'size': size,
      'variables': tooltipSpec.variables,
      'constrained': tooltipSpec.constrained ?? true,
      'scales': scales,
    }, tooltipScene, view));
  }
}
