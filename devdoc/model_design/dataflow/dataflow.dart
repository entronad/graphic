class Dataflow {
  /// 初始时是0, 第一次是 run 是 1
  int clock;

  /// 添加一个 Operator
  /// 没有 params 的会直接放在 touch 里，绝大部分时候是不要 connect 的
  Operator add() {}

  /// sources 是这个 target 要挂载的上游列表
  void connect(Operator target, List<Operator> sources) {}

  /// op 的 rank 设为 当前 dataflow 自增 1
  void rank(Operator op) {}

  /// 重排 op 和下游的所有 op
  /// 当op是插在中间时需要
  void rerank(Operator op) {}

  /// 用 changeset 去 pulse 一个 op
  /// 注意 pulse 不代表 run
  Dataflow pulse(Operator op, ChangeSet changeSet) {}

  /// 如果在 propagation 中就 enqueue，否则就放到 touched 中
  Dataflow touch(Operator op) {}

  /// 更新 op 的 value，并 touch 它
  /// 注意它不是一个核心过程，仅在onStream时使用到
  Dataflow update(Operator op, value) {}

  /// 输入数据
  /// 实现是对 target 发起一个 pulse，用 data 创建 ChangeSet
  Dataflow ingest(Operator target, List<Tuple> data) {}

  /// 从事件源 source 创建 EventStream
  EventStream events(source, type, filter, apply) {}

  /// 对发生的事件更新 operators
  /// 似乎应该存在以下派生关系
  /// Operator -> EventStream
  /// Pulse -> Event
  /// Pulse -> ChangeSet
  Dataflow on() {}

  /// 处理所有 updated, pulsed, touched operators, 增加 clock
  /// 第一次调用时所有 operators 都会处理
  /// 是异步函数
  /// 只在 run 和 runAsync 中被调用
  Future<Dataflow> evaluate() {
    /// _pulse 必须是空的
    /// 如果有 _pending ，等 _pending 执行完
    /// 执行 prerun
    /// 没有 _touched 直接返回
    /// clock 加 1
    /// _pulse 里放一个新 Pulse
    /// _touched 里的 op 全部 enqueue
    /// 重置 _touched
    /// 从 _heap 中一个一个 pop 出 op
    /// （如果 rank 和 qRank 不等，重新 enqueue 这个 op，并进入下一个 op）
    /// 执行 op.run，获取 next，其中的 pulse 通过 getPulse 方法获取
    /// 处理 next 中的 then 和 async
    /// 如果 next 不是 stop 且 op 有 targets，则 enqueue 所有 targets
    /// 清空 _input 和 _pulse
    /// 执行 postrun 和 async
  }

  /// 异步执行 evaluate，并将状态包装为 _running 进行标识和控制
  Future<Dataflow> runAsync() {}

  /// 同步执行 evaluate
  Dataflow run() {}

  /// 在当前 pulse 执行之后执行，如果当前不在pulse中则立即执行。
  /// 这是内部使用的，外部通过 postrun 参数使用
  void runAfter() {}

  /// op 的 qRank 设为等于 rank，插入 _heap 中
  /// _heap 是根据 op 的 qRank 排序的
  void enqueue(op) {}

  /// 获取计算 op 的正确的 pulse
  Pulse getPulse(op) {}
}