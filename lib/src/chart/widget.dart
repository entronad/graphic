import 'package:flutter/widgets.dart';

import 'package:graphic/src/parse/spec.dart';

import 'controller.dart';

/// [D]: Type of source data items.
class Chart<D> extends StatefulWidget implements Spec {
  @override
  _ChartState<D> createState() => _ChartState<D>();
}

class _ChartState<D> extends State<Chart<D>> {
  ChartController? controller;

  @override
  void initState() {
    super.initState();

    controller = ChartController(widget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}
