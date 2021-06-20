
typedef SelectUpdate<V> = V Function(V initialValue, V preValue);

class Select {
  Select(this.tag)
    : reversed = false;

  /// Meaning the selection is triggerd but this tuple is not select.
  Select.not(this.tag)
    : reversed = true;

  final String tag;

  final bool reversed;

  @override
  bool operator ==(Object other) =>
    other is Select &&
    tag == other.tag &&
    reversed == other.reversed;
}
