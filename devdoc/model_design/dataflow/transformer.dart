/// 处理 data tuples 的 Operator
/// 子类的处理逻辑写在 transform 方法中
class Transformer {
  /// evalute 完了之后还要执行 rv.then
  /// （原 Operator 中不涉及 rv.then）
  @override
  Pulse run(pulse) {}

  /// marchall 然后 transform
  /// （原 Operator 中主要执行 update）
  @override
  Pulse evaluate(pulse) {}

  /// 主要逻辑写的地方
  Pulse transform();
}