/// 传入 Chart Spec 获取解析好的 Desc 以构造 Controller
/// 每种 Spec 的 parse 作为方法定义在 Spec 内，方便子类重写，从 Chart Spec 开始递归调用
Desc parse(Chart spec) {
  return spec.parse(Scope()).toDesc();
}