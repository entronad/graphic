import 'cfg.dart' show Cfg;
import 'attrs.dart' show Attrs;
import 'element.dart' show Element;
import 'shape.dart' show Shape, shapeCreators;
import 'group.dart' show Group;

Comparator<Element> getComparer(Comparator<Element> compare) =>
  (left, right) {
    final result = compare(left, right);
    return result == 0 ? left.index - right.index : result;
  };

abstract class Container extends Element {
  Container(Cfg cfg) : super(cfg);

  List<Element> get children => cfg.children;

  Shape addShape(Cfg cfg) {
    final type = cfg.type;
    final creator = shapeCreators[type];
    final shape = creator(cfg);
    add(shape);
    return shape;
  }

  Group addGroup(Cfg cfg) {
    cfg.renderer = this.cfg.renderer;
    cfg.parent = this;
    final group = Group(cfg);
    add(group);
    return group;
  }

  bool contain(Element element) =>
    children.contains(element);

  void sort() {
    for (var i = 0; i < children.length; i++) {
      children[i].index = i;
    }

    children.sort(getComparer(
      (obj1, obj2) => obj1.cfg.zIndex - obj2.cfg.zIndex
    ));
  }

  void clear() {
    while (children.length != 0) {
      children[children.length - 1].remove(true);
    }
  }

  void add(Element element) {
    final parent = element.cfg.parent;
    if (parent != null) {
      final descendants = parent.cfg.children;
      descendants?.remove(element);
    }
    _setEvn(element);
    children.add(element);
  }

  void _setEvn(Element element) {
    element.cfg.parent = this;
    element.cfg.renderer = cfg.renderer;
    final clip = element.attrs.clip;
    if (clip != null) {
      clip.cfg.parent = this;
    }
    if (element.cfg.isGroup) {
      final children = element.cfg.children;
      for (var child in children) {
        (element as Group)._setEvn(child);
      }
    }
  }
}
