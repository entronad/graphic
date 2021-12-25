import 'dart:ui';

import 'package:graphic/src/util/collection.dart';
import 'package:graphic/src/util/path.dart';

/// The style of a stroke.
class StrokeStyle {
  /// Creates a stroke style
  StrokeStyle({
    this.color = const Color(0xff000000),
    this.width = 1,
    this.dash,
  });

  /// The stroke color.
  Color color;

  /// The stroke width.
  double width;

  /// The circular array of dash offsets and lengths.
  ///
  /// For example, the array `[5, 10]` would result in dashes 5 pixels long
  /// followed by blank spaces 10 pixels long.  The array `[5, 10, 5]` would
  /// result in a 5 pixel dash, a 10 pixel gap, a 5 pixel dash, a 5 pixel gap,
  /// a 10 pixel dash, etc.
  List<double>? dash;

  bool operator ==(Object other) =>
      other is StrokeStyle && color == other.color && width == other.width && deepCollectionEquals(dash, other.dash);

  /// Gets [Paint] object from this stroke style.
  ///
  /// If [paint] set, the result will be applied to it.
  Paint toPaint([Paint? paint]) => (paint ?? Paint())
    // This setting is a must, or the Canvas.drawPath will not render the stoke.
    ..style = PaintingStyle.stroke
    ..color = color
    ..strokeWidth = width;
  
  /// Gets the dash line from a source path.
  Path dashPath(Path path) => dash == null
    ? path
    : Paths.dashLine(source: path, dashArray: dash!);
}
