import 'dart:ui';

import 'segment.dart';
import 'cubic.dart';

/// A close segment like [Path.close].
class CloseSegment extends Segment {
  /// Creates a close segment.
  CloseSegment({
    String? tag,
  }) : super(
          tag: tag,
        );

  @override
  void drawPath(Path path) => path.close();

  @override
  CloseSegment lerpFrom(covariant CloseSegment from, double t) => this;

  @override
  CubicSegment toCubic(Offset start) {
    throw UnsupportedError('Close segment should not call this method.');
  }

  @override
  CloseSegment sow(Offset position) => this;

  @override
  Offset getEnd() {
    throw UnsupportedError('Close segment should not call this method.');
  }

  @override
  bool operator ==(Object other) => other is CloseSegment && super == other;
}
