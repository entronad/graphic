import 'package:flutter/painting.dart';
import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/guide/annotation/custom.dart';
import 'package:graphic/src/interaction/selection/point.dart';
import 'package:graphic/src/parse/parse.dart';

import 'axis/axis.dart';
import 'annotation/line.dart';
import 'annotation/region.dart';
import 'annotation/figure.dart';
import 'annotation/mark.dart';
import 'annotation/tag.dart';
import 'interaction/crosshair.dart';
import 'interaction/tooltip.dart';

/// Parses the guide related specifications.
void parseGuide(
  Chart spec,
  View view,
  Scope scope,
) {
  if (spec.axes != null) {
    for (var i = 0; i < spec.axes!.length; i++) {
      final axisSpec = spec.axes![i];
      final dim = axisSpec.dim ?? i + 1;
      final variable = axisSpec.variable ?? scope.forms.first.first[dim - 1];

      final ticks = view.add(TickInfoOp({
        'variable': variable,
        'scales': scope.scales,
        'tickLine': axisSpec.tickLine,
        'tickLineMapper': axisSpec.tickLineMapper,
        'label': axisSpec.label,
        'labelMapper': axisSpec.labelMapper,
        'grid': axisSpec.grid,
        'gridMapper': axisSpec.gridMapper,
      }));

      final axisScene = view.graffiti.add(AxisScene(axisSpec.zIndex ?? 0));
      view.add(AxisRenderOp({
        'coord': scope.coord,
        'dim': dim,
        'position': axisSpec.position ?? 0.0,
        'flip': axisSpec.flip ?? false,
        'line': axisSpec.line,
        'ticks': ticks,
      }, axisScene, view));

      final gridScene = view.graffiti.add(GridScene(axisSpec.gridZIndex ?? 0));
      view.add(GridRenderOp({
        'coord': scope.coord,
        'dim': dim,
        'ticks': ticks,
      }, gridScene, view));
    }
  }

  if (spec.annotations != null) {
    for (var annotSpec in spec.annotations!) {
      if (annotSpec is RegionAnnotation) {
        final dim = annotSpec.dim ?? 1;
        final variable = annotSpec.variable ?? scope.forms.first.first[dim - 1];
        final annotScene =
            view.graffiti.add(RegionAnnotScene(annotSpec.zIndex ?? 0));
        view.add(RegionAnnotRenderOp({
          'dim': dim,
          'variable': variable,
          'values': annotSpec.values,
          'color': annotSpec.color,
          'scales': scope.scales,
          'coord': scope.coord,
        }, annotScene, view));
      } else if (annotSpec is LineAnnotation) {
        final dim = annotSpec.dim ?? 1;
        final variable = annotSpec.variable ?? scope.forms.first.first[dim - 1];
        final annotScene =
            view.graffiti.add(LineAnnotScene(annotSpec.zIndex ?? 0));
        view.add(LineAnnotRenderOp({
          'dim': dim,
          'variable': variable,
          'value': annotSpec.value,
          'style': annotSpec.style,
          'scales': scope.scales,
          'coord': scope.coord,
        }, annotScene, view));
      } else if (annotSpec is FigureAnnotation) {
        var anchor;
        if (annotSpec.anchor != null) {
          anchor = view.add(FigureAnnotSetAnchorOp({
            'anchor': annotSpec.anchor,
            'size': scope.size,
          }));
        } else {
          anchor = view.add(FigureAnnotCalcAnchorOp({
            'variables': annotSpec.variables ??
                [
                  scope.forms.first.first[0],
                  scope.forms.first.first[1],
                ],
            'values': annotSpec.values,
            'scales': scope.scales,
            'coord': scope.coord,
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
          annot = view.add(TagAnnotOp({
            'anchor': anchor,
            'render': annotSpec.render,
          }));
        }

        final annotScene =
            view.graffiti.add(FigureAnnotScene(annotSpec.zIndex ?? 0));
        view.add(FigureAnnotRenderOp({
          'figures': annot,
          'inRegion': annotSpec.anchor == null,
          'coord': scope.coord,
        }, annotScene, view));
      } else {
        throw UnimplementedError('No such annotation type $annotSpec.');
      }
    }
  }

  if (spec.crosshair != null) {
    final crosshairSpec = spec.crosshair!;
    final elementIndex = crosshairSpec.element ?? 0;

    final crosshairScene =
        view.graffiti.add(CrosshairScene(crosshairSpec.zIndex ?? 0));
    view.add(CrosshairRenderOp({
      'selectorName': crosshairSpec.selection ?? spec.selections!.keys.first,
      'selector': scope.selector,
      'selects': scope.selectsList[elementIndex],
      'coord': scope.coord,
      'groups': scope.groupsList[elementIndex],
      'styles': crosshairSpec.styles ??
          [
            StrokeStyle(color: Color(0xffbfbfbf)),
            StrokeStyle(color: Color(0xffbfbfbf)),
          ],
      'followPointer': crosshairSpec.followPointer ?? [false, false],
    }, crosshairScene, view));
  }

  if (spec.tooltip != null) {
    final tooltipSpec = spec.tooltip!;
    final elementIndex = tooltipSpec.element ?? 0;

    final tooltipScene =
        view.graffiti.add(TooltipScene(tooltipSpec.zIndex ?? 0));
    final selectorName = tooltipSpec.selection ?? spec.selections!.keys.first;
    final multiTuples = tooltipSpec.multiTuples ??
        ((spec.selections![selectorName] is PointSelection) ? false : true);
    view.add(TooltipRenderOp({
      'selectorName': selectorName,
      'selector': scope.selector,
      'selects': scope.selectsList[elementIndex],
      'coord': scope.coord,
      'groups': scope.groupsList[elementIndex],
      'tuples': scope.tuples,
      'align': tooltipSpec.align ?? Alignment.center,
      'offset': tooltipSpec.offset,
      'padding': tooltipSpec.padding ?? EdgeInsets.all(5),
      'backgroundColor': tooltipSpec.backgroundColor ?? Color(0xf0ffffff),
      'radius': tooltipSpec.radius ?? Radius.circular(3),
      'elevation': tooltipSpec.elevation ?? 3.0,
      'textStyle': tooltipSpec.textStyle ??
          TextStyle(
            color: Color(0xff595959),
            fontSize: 12,
          ),
      'multiTuples': multiTuples,
      'render': tooltipSpec.render,
      'followPointer': tooltipSpec.followPointer ?? [false, false],
      'anchor': tooltipSpec.anchor,
      'size': scope.size,
      'variables': tooltipSpec.variables,
      'scales': scope.scales,
    }, tooltipScene, view));
  }
}