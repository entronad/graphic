import 'package:graphic/src/dataflow/dataflow.dart';
import 'package:graphic/src/parse/scope.dart';
import 'package:graphic/src/parse/parse.dart';

import 'widget.dart';
import 'context.dart';

class ChartController extends Dataflow {
  ChartController(Chart chart) {
    final scope = Scope();
    parse(chart, scope);

    _context = Context(this);
    _context!.mount(scope);
  }

  Context? _context;
}
