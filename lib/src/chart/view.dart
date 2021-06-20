import 'package:graphic/src/dataflow/dataflow.dart';
import 'package:graphic/src/parse/scope.dart';
import 'package:graphic/src/parse/parse.dart';

import 'chart.dart';
import 'context.dart';

class View extends Dataflow {
  View(Chart chart) {
    final scope = Scope();
    parse(chart, scope);

    _context = Context(this);
    _context!.mount(scope);
  }

  Context? _context;
}
