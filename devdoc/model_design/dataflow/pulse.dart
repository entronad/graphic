/// 在 dataflow run 时提供 Operator 之间的通信
/// 可携带当前 clock，change set，指向背景数据源的指针
class Pulse {
  /// 新的 Pulse 复制 dataflow, clock, field，创建新的空 add, rem, mod
  Pulse fork(flags) {}

  /// add, rem, mod 也再拷贝一份
  Pulse clone() {}

  /// 类似 fork，add 中放上 source 中的所有 tuple
  /// 用于已经 process 之后再添加 operator，这个 operator 能观察到 source 中的所有 tuple
  Pulse addAll() {}

  /// 将 source 中的所有 tuple 加到 mod 中（或新建一个）
  Pulse reflow(bool fork) {}

  /// 记录被改变的变量名，以便 transform operators 追踪依赖和增量处理
  Pulse modify(List<String> variables) {}

  /// 检查某些变量是否在本周期内修改过
  bool modified(List<String> variables) {}

  /// 将 filter 以 and 方式添加到对应的 addF, remF, modF 中
  /// 作用是从 source 中取时避免不必要的拷贝
  /// 通过返回非 null tuple ，不通过返回 null，因此还能起到 transformer 的作用
  Pulse(int flags, filter) {}

  /// 过滤一遍对应的 add, rem, mod, source，并将过滤过的 filter 清空
  Pulse materialize(int flags) {}

  /// 遍历对应的，执行 visitor 操作
  Pulse visit(int flags, visitor) {}
}