import 'cfg.dart' show Cfg;
import 'element.dart' show Element;

abstract class Container extends Element {
  Container(Cfg cfg) : super(cfg);

  void sort();
  List<Element> get children => null;
}
