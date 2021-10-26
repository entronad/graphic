import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/layers.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/graffiti/scene.dart';
import 'package:graphic/src/guide/axis/circular.dart';
import 'package:graphic/src/guide/axis/horizontal.dart';
import 'package:graphic/src/guide/axis/radial.dart';
import 'package:graphic/src/guide/axis/vertical.dart';
import 'package:graphic/src/parse/spec.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/util/assert.dart';

/// The specification of a single axis tick line.
class TickLine {
  /// Creates a tick line.
  TickLine({
    StrokeStyle? style,
    this.length = 2,
  }) : style = style ?? StrokeStyle();

  /// The stroke style of this tick line.
  StrokeStyle style;

  /// The length of this tick line.
  double length;

  @override
  bool operator ==(Object other) =>
    other is TickLine &&
    style == other.style &&
    length == other.length;
}

/// Gets an axis tick line form an axis value text.
/// 
/// [index] and [total] is current and total count of all ticks respectively.
typedef TickLineMapper = TickLine? Function(String text, int index, int total);

/// Gets an axis label form an axis value text.
/// 
/// [index] and [total] is current and total count of all ticks respectively.
typedef LabelMapper = LabelStyle? Function(String text, int index, int total);

/// Gets an axis grid stroke style form an axis value text.
/// 
/// [index] and [total] is current and total count of all ticks respectively.
typedef GridMapper = StrokeStyle? Function(String text, int index, int total);

/// The specification of an axis.
/// 
/// There can be mutiple axes in one dimension.
class AxisGuide<V> {
  /// Creates an axis.
  AxisGuide({
    this.dim,
    this.variable,
    this.position,
    this.flip,
    this.line,
    this.tickLine,
    this.tickLineMapper,
    this.label,
    this.labelMapper,
    this.grid,
    this.gridMapper,
    this.zIndex,
    this.gridZIndex,
  })
    : assert(isSingle([tickLine, tickLineMapper], allowNone: true)),
      assert(isSingle([label, labelMapper], allowNone: true)),
      assert(isSingle([grid, gridMapper], allowNone: true));

  /// The dimension where this axis lies.
  /// 
  /// If null, the index of this axis in the [Spec.axes] list plus 1 is set by
  /// default.
  int? dim;

  /// The variable this axis is binded to.
  /// 
  /// If null, the first variable assigned to [dim] is set by default.
  String? variable;

  /// The position ratio in the crossing dimension where this axis line stands.
  /// 
  /// This ratio is to region boundaries for [RectCoord] and to angle or radius
  /// boundaries for [PolarCoord].
  /// 
  /// If null, a default 0 is set.
  double? position;

  /// Whether to flip tick lines and labels to the other side of the axis line.
  /// 
  /// The default side is left for vertical axes, bottom for horizontal axes, outer
  /// for circular axes, and behind the anticlockwise for radial axes.
  bool? flip;

  /// The stroke style for the axis line.
  /// 
  /// If null, there will be no axis line.
  StrokeStyle? line;

  /// The tick line settings for all ticks.
  /// 
  /// Only one in [tickLine] and [tickLineMapper] can be set.
  /// 
  /// If null and [tickLineMapper] is also null, there will be no tick lines.
  TickLine? tickLine;

  /// Indicates how to get the tick line setting for each tick.
  /// 
  /// Only one in [tickLine] and [tickLineMapper] can be set.
  TickLineMapper? tickLineMapper;

  /// The label style for all ticks.
  /// 
  /// Only one in [label] and [labelMapper] can be set.
  /// 
  /// If null and [labelMapper] is also null, there will be no labels.
  LabelStyle? label;

  /// Indicates how to get the label style for each tick.
  /// 
  /// Only one in [label] and [labelMapper] can be set.
  LabelMapper? labelMapper;

  /// The grid stroke style for all ticks.
  /// 
  /// Only one in [grid] and [gridMapper] can be set.
  /// 
  /// If null and [gridMapper] is also null, there will be no grids.
  StrokeStyle? grid;

  /// Indicates how to get the grid stroke style for each tick.
  /// 
  /// Only one in [grid] and [gridMapper] can be set.
  GridMapper? gridMapper;

  /// The z index of this axis.
  /// 
  /// If null, a default 0 is set.
  int? zIndex;

  /// The z index of the grids.
  /// 
  /// If null, a default 0 is set.
  int? gridZIndex;

  @override
  bool operator ==(Object other) =>
    other is AxisGuide &&
    dim == other.dim &&
    variable == other.variable &&
    position == other.position &&
    flip == other.flip &&
    line == other.line &&
    tickLine == other.tickLine &&
    // tickLineMapper: Function
    label == other.label &&
    // labelMapper: Function
    grid == other.grid &&
    // gridMapper: Function
    zIndex == other.zIndex &&
    gridZIndex == other.gridZIndex;
}

// tickInfo

class TickInfo {
  TickInfo(
    this.position,
    this.text,
  );

  final double position;

  final String text;

  TickLine? tickLine;

  LabelStyle? label;

  StrokeStyle? grid;
}

/// -         / AxisRenderOp
/// TickInfoOp
/// -         \ GridRenderOp
class TickInfoOp extends Operator<List<TickInfo>> {
  TickInfoOp(Map<String, dynamic> params) : super(params);

  @override
  List<TickInfo> evaluate() {
    final variable = params['variable'] as String;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final tickLine = params['tickLine'] as TickLine?;
    final tickLineMapper = params['tickLineMapper'] as TickLineMapper?;
    final label = params['label'] as LabelStyle?;
    final labelMapper = params['labelMapper'] as LabelMapper?;
    final grid = params['grid'] as StrokeStyle?;
    final gridMapper = params['gridMapper'] as GridMapper?;

    final scale = scales[variable]!;

    final ticks = scale.ticks.map((value) => TickInfo(
      scale.normalize(scale.convert(value)),
      scale.formatter(value),
    )).toList();

    final total = ticks.length;
    for (var i = 0; i < total; i++) {
      final tick = ticks[i];
      if (tickLine != null) {
        tick.tickLine = tickLine;
      } else if (tickLineMapper != null) {
        tick.tickLine = tickLineMapper(tick.text, i, total);
      }
      if (label != null) {
        tick.label = label;
      } else if (labelMapper != null) {
        tick.label = labelMapper(tick.text, i, total);
      }
      if (grid != null) {
        tick.grid = grid;
      } else if (gridMapper != null) {
        tick.grid = gridMapper(tick.text, i, total);
      }
    }

    return ticks;
  }
}

// axis

class AxisScene extends Scene {
  @override
  int get layer => Layers.axis;
}

class AxisRenderOp extends Render<AxisScene> {
  AxisRenderOp(
    Map<String, dynamic> params,
    AxisScene scene,
    View view,
  ) : super(params, scene, view);

  @override
  void render() {
    final zIndex = params['zIndex'] as int;
    final coord = params['coord'] as CoordConv;
    final dim = params['dim'] as int;
    final position = params['position'] as double;
    final flip = params['flip'] as bool;
    final line = params['line'] as StrokeStyle?;
    final ticks = params['ticks'] as List<TickInfo>;
    
    scene.zIndex = zIndex;

    final canvasDim = coord.getCanvasDim(dim);
    if (coord is RectCoordConv) {
      if (canvasDim == 1) {
        scene.figures = renderHorizontalAxis(
          ticks,
          position,
          flip,
          line,
          coord,
        );
      } else {
        scene.figures = renderVerticalAxis(
          ticks,
          position,
          flip,
          line,
          coord,
        );
      }
    } else {
      coord as PolarCoordConv;
      if (canvasDim == 1) {
        scene.figures = renderCircularAxis(
          ticks,
          position,
          flip,
          line,
          coord,
        );
      } else {
        scene.figures = renderRadialAxis(
          ticks,
          position,
          flip,
          line,
          coord,
        );
      }
    }
  }
}

// grid

class GridScene extends Scene {
  @override
  int get layer => Layers.grid;
}

class GridRenderOp extends Render<GridScene> {
  GridRenderOp(
    Map<String, dynamic> params,
    GridScene scene,
    View view
  ) : super(params, scene, view);

  @override
  void render() {
    final gridZIndex = params['gridZIndex'] as int;
    final coord = params['coord'] as CoordConv;
    final dim = params['dim'] as int;
    final ticks = params['ticks'] as List<TickInfo>;
    
    scene.zIndex = gridZIndex;

    final canvasDim = coord.getCanvasDim(dim);
    if (coord is RectCoordConv) {
      if (canvasDim == 1) {
        scene.figures = renderHorizontalGrid(
          ticks,
          coord,
        );
      } else {
        scene.figures = renderVerticalGrid(
          ticks,
          coord,
        );
      }
    } else {
      coord as PolarCoordConv;
      if (canvasDim == 1) {
        scene.figures = renderCircularGrid(
          ticks,
          coord,
        );
      } else {
        scene.figures = renderRadialGrid(
          ticks,
          coord,
        );
      }
    }
  }
}
