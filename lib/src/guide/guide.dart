import 'package:flutter/painting.dart';
import 'package:graphic/graphic.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/parse/spec.dart';

import 'axis/axis.dart';
import 'annotation/line.dart';
import 'annotation/region.dart';
import 'annotation/figure.dart';
import 'annotation/mark.dart';
import 'annotation/tag.dart';
import 'interaction/crosshair.dart';
import 'interaction/tooltip.dart';

void parseGuide(
  Spec spec,
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

      final axisScene = view.graffiti.add(AxisScene());
      view.add(AxisRenderOp({
        'zIndex': axisSpec.zIndex ?? 0,
        'coord': scope.coord,
        'dim': dim,
        'position': axisSpec.position ?? 0.0,
        'flip': axisSpec.flip ?? false,
        'line': axisSpec.line,
        'ticks': ticks,
      }, axisScene, view));

      final gridScene = view.graffiti.add(GridScene());
      view.add(GridRenderOp({
        'gridZIndex': axisSpec.gridZIndex ?? 0,
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
        final annotScene = view.graffiti.add(RegionAnnotScene());
        view.add(RegionAnnotRenderOp({
          'dim': dim,
          'variable': variable,
          'values': annotSpec.values,
          'color': annotSpec.color,
          'zIndex': annotSpec.zIndex ?? 0,
          'scales': scope.scales,
          'coord': scope.coord,
        }, annotScene, view));
      } else if (annotSpec is LineAnnotation) {
        final dim = annotSpec.dim ?? 1;
        final variable = annotSpec.variable ?? scope.forms.first.first[dim - 1];
        final annotScene = view.graffiti.add(LineAnnotScene());
        view.add(LineAnnotRenderOp({
          'dim': dim,
          'variable': variable,
          'value': annotSpec.value,
          'style': annotSpec.style,
          'zIndex': annotSpec.zIndex ?? 0,
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
            'variables': annotSpec.variables ?? [
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
        } else {
          annotSpec as TagAnnotation;
          annot = view.add(TagAnnotOp({
            'anchor': anchor,
            'label': annotSpec.label,
            'align': annotSpec.align ?? Alignment.center,
          }));
        }

        final annotScene = view.graffiti.add(FigureAnnotScene());
        view.add(FigureAnnotRenderOp({
          'figures': annot,
          'inRegion': annotSpec.anchor == null,
          'zIndex': annotSpec.zIndex ?? 0,
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

    final crosshairScene = view.graffiti.add(CrosshairScene());
    view.add(CrosshairRenderOp({
      'selectorName': crosshairSpec.select ?? spec.selects!.keys.first,
      'selector': scope.selector,
      'selects': scope.selectsList[elementIndex],
      'zIndex': crosshairSpec.zIndex ?? 0,
      'coord': scope.coord,
      'groups': scope.groupsList[elementIndex],
      'styles': crosshairSpec.styles ?? [
        StrokeStyle(color: Color(0xffbfbfbf)),
        StrokeStyle(color: Color(0xffbfbfbf)),
      ],
      'followPointer': crosshairSpec.followPointer ?? [false, false],
    }, crosshairScene, view));
  }

  if (spec.tooltip != null) {
    final tooltipSpec = spec.tooltip!;
    final elementIndex = tooltipSpec.element ?? 0;

    final tooltipScene = view.graffiti.add(TooltipScene());
    view.add(TooltipRenderOp({
      'selectorName': tooltipSpec.select ?? spec.selects!.keys.first,
      'selector': scope.selector,
      'selects': scope.selectsList[elementIndex],
      'zIndex': tooltipSpec.zIndex ?? 0,
      'coord': scope.coord,
      'groups': scope.groupsList[elementIndex],
      'originals': scope.originals,
      'align': tooltipSpec.align ?? Alignment.center,
      'offset': tooltipSpec.offset,
      'padding': tooltipSpec.padding ?? EdgeInsets.all(5),
      'backgroundColor': tooltipSpec.backgroundColor ?? Color(0xf0ffffff),  // TODO: defalut
      'radius': tooltipSpec.radius ?? Radius.circular(3),
      'elevation': tooltipSpec.elevation ?? 3.0,  // TODO: defalut
      'textStyle': tooltipSpec.textStyle ?? TextStyle(
        color: Color(0xff595959),
        fontSize: 12,
      ),  // TODO: defalut
      'render': tooltipSpec.render,
      'followPointer': tooltipSpec.followPointer ?? [false, false],
      'variables': tooltipSpec.variables,
      'scales': scope.scales,
    }, tooltipScene, view));
  }
}
