import 'dart:ui';

import 'package:graphic/src/geom/base.dart';

import 'base.dart';

class SymmetricAdjust extends Adjust {
  @override
  AdjustType get type => AdjustType.symmetric;
}

class SymmetricAdjustState extends AdjustState {}

class SymmetricAdjustComponent extends AdjustComponent<SymmetricAdjustState> {
  SymmetricAdjustComponent([SymmetricAdjust props]) : super(props);

  @override
  SymmetricAdjustState get originalState => SymmetricAdjustState();

  @override
  void adjust(List<List<AttrValueRecord>> recordsGroup, Offset origin) {
    final originY = origin.dy;
    
    final symmetricRecordsGroup = <List<AttrValueRecord>>[];
    for (var records in recordsGroup) {
      final symmetricRecords = <AttrValueRecord>[];
      for (var record in records) {
        record.position = record.position.map(
          (point) => Offset(point.dx, point.dy - (point.dy - originY) / 2),
        ).toList();
        final symmetricRecord = AttrValueRecord(
          color: record.color,
          size: record.size,
          shape: record.shape,
          position: record.position.map(
            (point) => Offset(point.dx, originY - (point.dy - originY)),
          ).toList(),
        );
        symmetricRecords.add(symmetricRecord);
      }
      symmetricRecordsGroup.add(symmetricRecords);
    }
    recordsGroup.addAll(symmetricRecordsGroup);
  }
}
