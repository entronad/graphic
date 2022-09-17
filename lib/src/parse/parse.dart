import 'dart:async';
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:graphic/src/aes/aes.dart';
import 'package:graphic/src/aes/channel.dart';
import 'package:graphic/src/aes/color.dart';
import 'package:graphic/src/aes/gradient.dart';
import 'package:graphic/src/aes/position.dart';
import 'package:graphic/src/aes/shape.dart';
import 'package:graphic/src/aes/elevation.dart';
import 'package:graphic/src/aes/size.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/chart/size.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/defaults.dart';
import 'package:graphic/src/common/dim.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/common/reserveds.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/geom/element.dart';
import 'package:graphic/src/geom/modifier/modifier.dart';
import 'package:graphic/src/guide/annotation/custom.dart';
import 'package:graphic/src/guide/annotation/figure.dart';
import 'package:graphic/src/guide/annotation/line.dart';
import 'package:graphic/src/guide/annotation/mark.dart';
import 'package:graphic/src/guide/annotation/region.dart';
import 'package:graphic/src/guide/annotation/tag.dart';
import 'package:graphic/src/guide/axis/axis.dart';
import 'package:graphic/src/guide/interaction/crosshair.dart';
import 'package:graphic/src/guide/interaction/tooltip.dart';
import 'package:graphic/src/interaction/gesture.dart';
import 'package:graphic/src/interaction/selection/interval.dart';
import 'package:graphic/src/interaction/selection/point.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/interaction/signal.dart';
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
EdgeInsets _defaultRectPadding(Size _) => const EdgeInsets.fromLTRB(40, 5, 10, 20);

/// The default padding function for polar coordinate.
EdgeInsets _defaultPolarPadding(Size _) => const EdgeInsets.all(10);

/// Parses the specification for a view.
void parse<D>(
  Chart<D> spec,
  View<D> view,
  Size chartSize,
) {
  // Signal

  final gestureSignal = view.add(SignalOp<GestureSignal>());

  final gestureChannel =
      spec.gestureChannel ?? StreamController<GestureSignal>();
  view.bindChannel(gestureChannel, gestureSignal);
  view.gestureChannel = gestureChannel;

  final resizeSignal = view.add(SignalOp<ResizeSignal>());

  final resizeChannel = spec.resizeChannel ?? StreamController<ResizeSignal>();
  view.bindChannel(resizeChannel, resizeSignal);
  view.resizeChannel = resizeChannel;

  final changeDataSignal = view.add(SignalOp<ChangeDataSignal<D>>());

  final changeDataChannel =
      spec.changeDataChannel ?? StreamController<ChangeDataSignal<D>>();
  view.bindChannel(changeDataChannel, changeDataSignal);
  view.changeDataChannel = changeDataChannel;

  final signal = view.add(SignalReducerOp<D>({
    'gesture': gestureSignal,
    'resize': resizeSignal,
    'changeData': changeDataSignal,
  }));

  // Coord.

  final size = view.add(SizeOp({
    'signal': resizeSignal,
  }, chartSize));

  final coordSpec = spec.coord ?? RectCoord();

  final region = view.add(RegionOp({
    'size': size,
    'padding': spec.padding ??
        (coordSpec is RectCoord ? _defaultRectPadding : _defaultPolarPadding),
  }));

  if (coordSpec.color != null) {
    final regionBackgroundScene =
        view.graffiti.add(RegionBackgroundScene(coordSpec.layer ?? 0));
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
    final regionBackgroundScene =
        view.graffiti.add(RegionBackgroundScene(coordSpec.layer ?? 0));
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
      horizontalRange = view.add(SignalUpdateOp({
        'update': coordSpec.horizontalRangeUpdater,
        'initialValue': horizontalRange,
        'signal': signal,
      }));
    }
    Operator<List<double>> verticalRange = view.add(Value<List<double>>(
      coordSpec.verticalRange ?? [0, 1],
    ));
    if (coordSpec.verticalRangeUpdater != null) {
      verticalRange = view.add(SignalUpdateOp({
        'update': coordSpec.verticalRangeUpdater,
        'initialValue': verticalRange,
        'signal': signal,
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
      angleRange = view.add(SignalUpdateOp({
        'update': coordSpec.angleRangeUpdater,
        'initialValue': angleRange,
        'signal': signal,
      }));
    }
    Operator<List<double>> radiusRange = view.add(Value<List<double>>(
      coordSpec.radiusRange ?? [0, 1],
    ));
    if (coordSpec.radiusRangeUpdater != null) {
      radiusRange = view.add(SignalUpdateOp({
        'update': coordSpec.radiusRangeUpdater,
        'initialValue': radiusRange,
        'signal': signal,
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

  final data = view.add(DataOp<D>({'signal': changeDataSignal}, spec.data));

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
    'signal': gestureSignal,
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
      final selectorScene =
          view.graffiti.add(SelectorScene(selectSpecs[name]!.layer ?? 0));
      view.add(SelectorRenderOp({
        'selectors': selectors,
        'name': name,
      }, selectorScene, view));
    }
  }

  // Element.

  // For all elements, they either all have or all have not select operator.
  final selectOpList = <SelectOp>[];
  final groupsList = <Operator<AesGroups>>[];
  // First term of the form of the first element, in order to get first variable
  // of each dimension.
  AlgTerm? firstVariables;

  for (var elementSpec in spec.elements) {
    var form = elementSpec.position?.form;
    // Default algebracal form.
    if (form == null) {
      final variables = scaleSpecs.keys.toList();
      form = (Varset(variables[0]) * Varset(variables[1])).form;
    }

    final nesters = elementSpec.position?.nesters ?? <AlgForm>[];

    firstVariables ??= form.first;

    final origin = view.add(OriginOp({
      'form': form,
      'scales': scales,
      'coord': coord,
    }));

    final positionEncoder = view.add(PositionEncoderOp({
      'form': form,
      'scales': scales,
      'completer': getPositionCompleter(elementSpec),
      'origin': origin,
    }));

    final aeses = view.add(AesOp({
      'scaleds': scaleds,
      'tuples': tuples,
      'positionEncoder': positionEncoder,
      'shapeEncoder': getChannelEncoder<Shape>(
        elementSpec.shape ?? ShapeAttr(value: getDefaultShape(elementSpec)),
        scaleSpecs,
        null,
      ),
      // Uses a default color when both color and gradient attributes are null.
      'colorEncoder': elementSpec.gradient == null
          ? getChannelEncoder<Color>(
              elementSpec.color ?? ColorAttr(value: Defaults.primaryColor),
              scaleSpecs,
              (List<Color> values, List<double> stops) =>
                  ContinuousColorConv(values, stops),
            )
          : null,
      'gradientEncoder': elementSpec.gradient == null
          ? null
          : getChannelEncoder<Gradient>(
              elementSpec.gradient!,
              scaleSpecs,
              (List<Gradient> values, List<double> stops) =>
                  ContinuousGradientConv(values, stops),
            ),
      'elevationEncoder': elementSpec.elevation == null
          ? null
          : getChannelEncoder<double>(
              elementSpec.elevation!,
              scaleSpecs,
              (List<double> values, List<double> stops) =>
                  ContinuousElevationConv(values, stops),
            ),
      'labelEncoder': elementSpec.label == null
          ? null
          : CustomEncoder<Label>(elementSpec.label!.encoder!),
      'sizeEncoder': elementSpec.size == null
          ? null
          : getChannelEncoder<double>(
              elementSpec.size!,
              scaleSpecs,
              (List<double> values, List<double> stops) =>
                  ContinuousSizeConv(values, stops),
            ),
    }));

    Operator<AesGroups> groups = view.add(GroupOp({
      'aeses': aeses,
      'tuples': tuples,
      'nesters': nesters,
      'scales': scales,
    }));

    if (elementSpec.modifiers != null) {
      for (var modifier in elementSpec.modifiers!) {
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
      }, elementSpec.selected));
      if (elementSpec.selectionChannel != null) {
        view.bindChannel(elementSpec.selectionChannel!, selected);
      }
      selectOpList.add(selected);

      final shapeUpdaters = elementSpec.shape?.updaters;
      final colorUpdaters = elementSpec.color?.updaters;
      final gradientUpdaters = elementSpec.gradient?.updaters;
      final elevationUpdaters = elementSpec.elevation?.updaters;
      final labelUpdaters = elementSpec.label?.updaters;
      final sizeUpdaters = elementSpec.size?.updaters;

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

    final elementScene =
        view.graffiti.add(ElementScene(elementSpec.layer ?? 0));
    view.add(ElementRenderOp({
      'groups': groups,
      'coord': coord,
      'origin': origin,
    }, elementScene, view));
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
      }));

      final axisScene = view.graffiti.add(AxisScene(axisSpec.layer ?? 0));
      view.add(AxisRenderOp({
        'coord': coord,
        'dim': dim,
        'position': axisSpec.position ?? 0.0,
        'flip': axisSpec.flip ?? false,
        'line': axisSpec.line,
        'ticks': ticks,
      }, axisScene, view));

      final gridScene = view.graffiti.add(GridScene(axisSpec.gridZIndex ?? 0));
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
        final annotScene =
            view.graffiti.add(RegionAnnotScene(annotSpec.layer ?? 0));
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
        final annotScene =
            view.graffiti.add(LineAnnotScene(annotSpec.layer ?? 0));
        view.add(LineAnnotRenderOp({
          'dim': dim,
          'variable': variable,
          'value': annotSpec.value,
          'style': annotSpec.style,
          'scales': scales,
          'coord': coord,
        }, annotScene, view));
      } else if (annotSpec is FigureAnnotation) {
        Operator<Offset> anchor;
        if (annotSpec.anchor != null) {
          anchor = view.add(FigureAnnotSetAnchorOp({
            'anchor': annotSpec.anchor,
            'size': size,
          }));
        } else {
          anchor = view.add(FigureAnnotCalcAnchorOp({
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

        FigureAnnotOp annot;
        if (annotSpec is MarkAnnotation) {
          annot = view.add(MarkAnnotOp({
            'anchor': anchor,
            'relativePath': annotSpec.relativePath,
            'style': annotSpec.style,
            'elevation': annotSpec.elevation,
          }));
        } else if (annotSpec is TagAnnotation) {
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

        final annotScene =
            view.graffiti.add(FigureAnnotScene(annotSpec.layer ?? 0));
        view.add(FigureAnnotRenderOp({
          'figures': annot,
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
    final elementIndex = crosshairSpec.element ?? 0;

    final crosshairScene =
        view.graffiti.add(CrosshairScene(crosshairSpec.layer ?? 0));
    view.add(CrosshairRenderOp({
      'selections': crosshairSpec.selections ?? spec.selections!.keys.toSet(),
      'selectors': selectors!,
      'selected': selectOpList[elementIndex],
      'coord': coord,
      'groups': groupsList[elementIndex],
      'styles': crosshairSpec.styles ??
          [
            StrokeStyle(color: const Color(0xffbfbfbf)),
            StrokeStyle(color: const Color(0xffbfbfbf)),
          ],
      'followPointer': crosshairSpec.followPointer ?? [false, false],
    }, crosshairScene, view));
  }

  if (spec.tooltip != null) {
    assert(selectors != null);

    final tooltipSpec = spec.tooltip!;
    final elementIndex = tooltipSpec.element ?? 0;

    final tooltipScene =
        view.graffiti.add(TooltipScene(tooltipSpec.layer ?? 0));
    view.add(TooltipRenderOp({
      'selections': tooltipSpec.selections ?? spec.selections!.keys.toSet(),
      'selectors': selectors!,
      'selected': selectOpList[elementIndex],
      'selectionSpecs': spec.selections!,
      'coord': coord,
      'groups': groupsList[elementIndex],
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
