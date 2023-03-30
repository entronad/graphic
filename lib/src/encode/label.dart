import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/dataflow/tuple.dart';

import 'encode.dart';

/// The specification of a label encode.
///
/// How to get label contents from tuples must be indicated by [encoder].
class LabelEncode extends Encode<Label> {
  /// Creates a label encode.
  LabelEncode({
    required Label Function(Tuple) encoder,
    Map<String, Map<bool, SelectionUpdater<Label>>>? updaters,
  }) : super(
          encoder: encoder,
          updaters: updaters,
        );
}
