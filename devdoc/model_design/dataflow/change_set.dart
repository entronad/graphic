/// 在构造图表的时候会创建多个 ChangeSet，每次都会add，创建完了会调用 pulse，但是clock都是1
/// 当发生 hover 时，会调用 encode ，这时 mod 中携带的 tuple 是mark的信息
class ChangeSet {
  /// vega 中称为 insert， 这里改名为与 add 集合一致
  /// 传入参数为 List 一般都是一下全都传入
  Changeset add(List<Tuple> tuples) {}

  /// 外部节点和内部节点数据源不一致时（比如 signal），不能直接连接，
  /// 而是将外部节点连接到内部节点最近的 Collector，在这条连接上传递的 ChangeSet 标记为 reflow
  /// 当 Collector 接收到 reflow ChangeSet 时，会向前传递 tuples，并将它们标记为 modified
  Changeset reflow() {}
}