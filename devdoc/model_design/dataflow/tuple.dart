/// tuple 还是采用包装法吧，因为有可能是外部传入的对象定义不受控
class Tuple<D> {
  Tuple(D datum) {}

  int get id {}
  D datum;
}