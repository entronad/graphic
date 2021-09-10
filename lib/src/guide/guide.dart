import 'package:flutter/painting.dart';
import 'package:graphic/graphic.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/guide/interaction/crosshair.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/parse/spec.dart';

import 'axis/axis.dart';
import 'annotation/line.dart';
import 'annotation/region.dart';
import 'annotation/tag.dart';

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
        'position': axisSpec.position ?? 0,
        'flip': axisSpec.flip ?? false,
        'line': axisSpec.line,
        'ticks': ticks,
      }, axisScene));

      final gridScene = view.graffiti.add(GridScene());
      view.add(GridRenderOp({
        'gridZindex': axisSpec.gridZIndex ?? 0,
        'coord': scope.coord,
        'dim': dim,
        'ticks': ticks,
      }, gridScene));
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
          'zIndex': annotSpec.zIndex,
          'scales': scope.scales,
          'coord': scope.coord,
        }, annotScene));
      } else if (annotSpec is LineAnnotation) {
        final dim = annotSpec.dim ?? 1;
        final variable = annotSpec.variable ?? scope.forms.first.first[dim - 1];
        final annotScene = view.graffiti.add(LineAnnotScene());
        view.add(LineAnnotRenderOp({
          'dim': dim,
          'variable': variable,
          'value': annotSpec.value,
          'style': annotSpec.style,
          'zIndex': annotSpec.zIndex,
          'scales': scope.scales,
          'coord': scope.coord,
        }, annotScene));
      } else if (annotSpec is TagAnnotation) {
        final variables = annotSpec.variables ?? [
          scope.forms.first.first[0],
          scope.forms.first.first[1],
        ];
        final annotScene = view.graffiti.add(LineAnnotScene());
        view.add(LineAnnotRenderOp({
          'variables': variables,
          'values': annotSpec.values,
          'label': annotSpec.label,
          'zIndex': annotSpec.zIndex,
          'scales': scope.scales,
          'coord': scope.coord,
        }, annotScene));
      } else {
        throw UnimplementedError('No such annotation type $annotSpec.');
      }
    }
  }

  if (spec.crosshair != null) {
    final crosshairSpec = spec.crosshair!;
    final elementIndex = crosshairSpec.element ?? 0;

    List<StrokeStyle> styles;
    if (crosshairSpec.styles == null) {
      styles = [StrokeStyle(), StrokeStyle()];
    } else if (crosshairSpec.styles!.length < 2) {
      styles = [
        crosshairSpec.styles!.first,
        crosshairSpec.styles!.first,
      ];
    } else {
      styles = crosshairSpec.styles!;
    }
    
    List<bool> followPointer;
    if (crosshairSpec.followPointer == null) {
      followPointer = [false, false];
    } else if (crosshairSpec.followPointer!.length < 2) {
      followPointer = [
        crosshairSpec.followPointer!.first,
        crosshairSpec.followPointer!.first,
      ];
    } else {
      followPointer = crosshairSpec.followPointer!;
    }

    final crosshairScene = view.graffiti.add(CrosshairScene());
    view.add(CrosshairRenderOp({
      'selectorName': crosshairSpec.select ?? spec.selects!.keys.first,
      'selector': scope.selector,
      'selects': scope.selectsList[elementIndex],
      'zIndex': crosshairSpec.zIndex,
      'coord': scope.coord,
      'groups': scope.updateList[elementIndex],
      'styles': styles,
      'followPointer': followPointer,
    }, crosshairScene));
  }

  if (spec.tooltip != null) {
    final tooltipSpec = spec.tooltip!;
    final elementIndex = tooltipSpec.element ?? 0;
    
    List<bool> followPointer;
    if (tooltipSpec.followPointer == null) {
      followPointer = [false, false];
    } else if (tooltipSpec.followPointer!.length < 2) {
      followPointer = [
        tooltipSpec.followPointer!.first,
        tooltipSpec.followPointer!.first,
      ];
    } else {
      followPointer = tooltipSpec.followPointer!;
    }

    final tooltipScene = view.graffiti.add(CrosshairScene());
    view.add(CrosshairRenderOp({
      'selectorName': tooltipSpec.select ?? spec.selects!.keys.first,
      'selector': scope.selector,
      'selects': scope.selectsList[elementIndex],
      'zIndex': tooltipSpec.zIndex,
      'coord': scope.coord,
      'groups': scope.updateList[elementIndex],
      'originals': scope.originals,
      'align': tooltipSpec.align ?? Alignment.center,
      'offset': tooltipSpec.offset,
      'padding': tooltipSpec.padding ?? EdgeInsets.all(5),
      'backgroudColor': tooltipSpec.backgroundColor ?? Color(0xff010101),  // TODO: defalut
      'radius': tooltipSpec.radius,
      'elevation': tooltipSpec.elevation ?? 1,  // TODO: defalut
      'textStyle': tooltipSpec.textStyle ?? TextStyle(),  // TODO: defalut
      'followPointer': followPointer,
      'variables': tooltipSpec.variables,
      'scales': scope.scales,
    }, tooltipScene));
  }
}
