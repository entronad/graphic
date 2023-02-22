import 'package:flutter/widgets.dart';
import 'package:graffiti_dev/graffiti/graffiti.dart';

class ShapePage extends StatefulWidget {
  const ShapePage();

  @override
  State<ShapePage> createState() => _ShapePageState();
}

class _ShapePageState extends State<ShapePage> with SingleTickerProviderStateMixin {
  late final Graffiti graffiti;

  void repaint() {
    setState(() {});
  }

  @override
  void initState() {
    graffiti = Graffiti(tickerProvider: this, repaint: repaint);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
