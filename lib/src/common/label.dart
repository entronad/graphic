import 'package:graphic/src/encode/label.dart';
import 'package:graphic/src/graffiti/element/label.dart';
import 'package:graphic/src/guide/annotation/tag.dart';

import 'defaults.dart';

/// Specification of a label.
///
/// A label is a span of text with styles. In is used for [LabelEncode], [TagAnnotation],
/// etc in the chart.
///
/// If the [text] is null or empty, the label will render nothing.
class Label {
  /// Creates a label.
  Label(
    this.text, [
    LabelStyle? style,
  ]) : style = style ?? LabelStyle(textStyle: Defaults.textStyle);

  /// The label text.
  String? text;

  /// The label style.
  LabelStyle style;

  @override
  bool operator ==(Object other) =>
      other is Label && text == other.text && style == other.style;

  /// Whether the [text] is not null or empty;
  bool get haveText => text != null && text!.isNotEmpty;
}
