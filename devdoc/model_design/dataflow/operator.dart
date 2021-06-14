/// Operator 最重要的是 value 和 update（可选）
/// 传入的 Parameters 值可包含直接值或其他 Operator，如果是Operator，值从其中动态拉取
/// 
/// Parameters 类很少在外面创建，基本上都是外面传入 Object 给 Operators.parameters 方法然后新建出来的，在 _argval 变量中
class Operator {
  /// 下游 Operators
  /// operator 通过 targets 指向链接起来，根在 dataflow._runtime.root
  Set<Operator> targets;

  /// 下一个 pulse 跳过 evaluate
  /// pulse 仍然会向前传递，但不会调用 update 方法
  /// 每个 pulse 完了都会重置 skip，只会作用一次
  bool skip;

  /// 表明 value 在最近的 pulse 中变化了
  /// 一般变化是根据相等判断的，这个主要用于 value 的引用没有变内部变了
  /// 除非 unset 否则一直会保持，与最后一个 clock 一起可以判断变化是不是最新的
  bool modified;

  /// 为 Operator 设置 Parameters
  /// 要是发现其中有 Operator（也包括在数组中的），将会添加为上游，并 marshall
  /// 对名称为 "pulse" 的值也会特殊处理
  /// 
  /// 参数传入就用 Map<String, Object>, Parameters 作为内部类提供功能
  List<Operator> parameters(Map<String, Object> params) {}

  /// 遍历所有上游 operators 拉取最新 value
  /// 返回 Parameters 给 update 函数
  Parameters marshall([int? clock]) {}

  /// 移除此 Operator，通知上游移除它
  void detach() {}

  /// 执行处理，子类主要重写它
  /// 默认情况下会 marchall，然后调用 update。
  /// 如果 update 没有改变 value，返回 stop
  /// 如果没有定义 update，什么事也不做
  /// 返回值正常是输出的pulse，如果 stop 则通知停止传递，如果null则pulse会穿过
  evaluate(Pulse pulse) {}

  /// 执行，其中会调用 evaluate
  /// 如果在 pulse 中的 clock 时（和之后）已经 run 过了，则返回 stop
  /// 如果 evaluate 返回的是 null，则直接返回 pulse
  /// 子类不要重写 run，重写 evaluate
  Pulse run(Pulse pulse) {}
}
