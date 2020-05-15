import 'dart:typed_data';
import 'dart:math' as math;

import 'package:vector_math/vector_math_64.dart' show Vector;
import 'package:vector_math/hash.dart' as quiver;

import 'vector2.dart' show Vector2;

enum TransActionType {
  translate,
  scale,
  rotate,
}

class TransAction {
  TransAction(this.type, this.payload);

  final TransActionType type;
  final List<double> payload;
}

/// A Vector of 6 elements handles linear transformation of Vector2.
/// Extends from vector_math.Vector.
class Matrix extends Vector {
  final Float64List _matstorage;

  /// The components of the vector.
  @override
  Float64List get storage => _matstorage;

  /// Construct a new vector with the specified values.
  factory Matrix(double m11, double m12, double m21, double m22, double dx, double dy) =>
      new Matrix.zero()..setValues(m11, m12, m21, m22, dx, dy);

  /// Initialized with values from [array] starting at [offset].
  factory Matrix.array(List<double> array, [int offset = 0]) =>
      new Matrix.zero()..copyFromArray(array, offset);

  /// Zero vector.
  Matrix.zero() : _matstorage = new Float64List(6);

  /// Constructs the identity vector.
  /// Set M to identity matrix, D to zero vector
  factory Matrix.identity() => new Matrix.zero()..setIdentity();

  /// Copy of [other].
  factory Matrix.copy(Matrix other) => new Matrix.zero()..setFrom(other);

  /// Constructs Matrix with given Float64List as [storage].
  Matrix.fromFloat64List(this._matstorage);

  /// Constructs Matrix with a [storage] that views given [buffer] starting at
  /// [offset]. [offset] has to be multiple of [Float64List.bytesPerElement].
  Matrix.fromBuffer(ByteBuffer buffer, int offset)
      : _matstorage = new Float64List.view(buffer, offset, 6);

  /// Set the values of the vector.
  /// 
  ///    m11  m21  dx
  ///    m12  m22  dy
  /// 
  void setValues(double m11_, double m12_, double m21_, double m22_, double dx_, double dy_) {
    _matstorage[0] = m11_;
    _matstorage[1] = m12_;
    _matstorage[2] = m21_;
    _matstorage[3] = m22_;
    _matstorage[4] = dx_;
    _matstorage[5] = dy_;
  }

  /// Zero the vector.
  void setZero() {
    _matstorage[0] = 0.0;
    _matstorage[1] = 0.0;
    _matstorage[2] = 0.0;
    _matstorage[3] = 0.0;
    _matstorage[4] = 0.0;
    _matstorage[5] = 0.0;
  }

  /// Set to the identity vector.
  void setIdentity() {
    _matstorage[0] = 1.0;
    _matstorage[1] = 0.0;
    _matstorage[2] = 0.0;
    _matstorage[3] = 1.0;
    _matstorage[4] = 0.0;
    _matstorage[5] = 0.0;
  }

  /// Set the values by copying them from [other].
  void setFrom(Matrix other) {
    final otherStorage = other._matstorage;
    _matstorage[0] = otherStorage[0];
    _matstorage[1] = otherStorage[1];
    _matstorage[2] = otherStorage[2];
    _matstorage[3] = otherStorage[3];
    _matstorage[4] = otherStorage[4];
    _matstorage[5] = otherStorage[5];
  }

  /// Returns a printable string
  @override
  String toString() => '${_matstorage[0]},${_matstorage[1]},'
    '${_matstorage[2]},${_matstorage[3]},'
    '${_matstorage[4]},${_matstorage[5]}';

  /// Check if two vectors are the same.
  @override
  bool operator ==(Object other) =>
      (other is Matrix) &&
      (_matstorage[0] == other._matstorage[0]) &&
      (_matstorage[1] == other._matstorage[1]) &&
      (_matstorage[2] == other._matstorage[2]) &&
      (_matstorage[3] == other._matstorage[3]) &&
      (_matstorage[4] == other._matstorage[4]) &&
      (_matstorage[5] == other._matstorage[5]);

  @override
  int get hashCode => quiver.hashObjects(_matstorage);

  /// Access the component of the vector at the index [i].
  double operator [](int i) => _matstorage[i];

  /// Set the component of the vector at the index [i].
  void operator []=(int i, double v) {
    _matstorage[i] = v;
  }

  /// Create a copy of [this].
  Matrix clone() => new Matrix.copy(this);

  /// Copy [this]
  Matrix copyInto(Matrix arg) {
    final argStorage = arg._matstorage;
    argStorage[0] = _matstorage[0];
    argStorage[1] = _matstorage[1];
    argStorage[2] = _matstorage[2];
    argStorage[3] = _matstorage[3];
    argStorage[4] = _matstorage[4];
    argStorage[5] = _matstorage[5];
    return arg;
  }

  /// Copies [this] into [array] starting at [offset].
  void copyIntoArray(List<double> array, [int offset = 0]) {
    array[offset + 0] = _matstorage[0];
    array[offset + 1] = _matstorage[1];
    array[offset + 2] = _matstorage[2];
    array[offset + 3] = _matstorage[3];
    array[offset + 4] = _matstorage[4];
    array[offset + 5] = _matstorage[5];
  }

  /// Copies elements from [array] into [this] starting at [offset].
  void copyFromArray(List<double> array, [int offset = 0]) {
    _matstorage[0] = array[offset + 0];
    _matstorage[1] = array[offset + 1];
    _matstorage[2] = array[offset + 2];
    _matstorage[3] = array[offset + 3];
    _matstorage[4] = array[offset + 4];
    _matstorage[5] = array[offset + 5];
  }

  void multiply(Matrix arg) {
    final m1 = _matstorage;
    final m2 = arg._matstorage;
    final m11 = m1[0] * m2[0] + m1[2] * m2[1];
    final m12 = m1[1] * m2[0] + m1[3] * m2[1];
    final m21 = m1[0] * m2[2] + m1[2] * m2[3];
    final m22 = m1[1] * m2[2] + m1[3] * m2[3];
    final dx = m1[0] * m2[4] + m1[2] * m2[5] + m1[4];
    final dy = m1[1] * m2[4] + m1[3] * m2[5] + m1[5];
    this.setValues(m11, m12, m21, m22, dx, dy);
  }

  void scale(Vector2 v) {
    _matstorage[0] = _matstorage[0] * v[0];
    _matstorage[1] = _matstorage[1] * v[0];
    _matstorage[2] = _matstorage[2] * v[1];
    _matstorage[3] = _matstorage[3] * v[1];
  }

  void rotate(double radian) {
    final c = math.cos(radian);
    final s = math.sin(radian);
    final m = _matstorage;
    final m11 = m[0] * c + m[2] * s;
    final m12 = m[1] * c + m[3] * s;
    final m21 = m[0] * -s + m[2] * c;
    final m22 = m[1] * -s + m[3] * c;
    _matstorage[0] = m11;
    _matstorage[1] = m12;
    _matstorage[2] = m21;
    _matstorage[3] = m22;
  }

  void translate(Vector2 v) {
    final m = _matstorage;
    final dx = m[4] + m[0] * v[0] + m[2] * v[1];
    final dy = m[5] + m[1] * v[0] + m[3] * v[1];
    _matstorage[4] = dx;
    _matstorage[5] = dy;
  }

  void transform(List<TransAction> actions) {
    for (final action in actions) {
      final type =action.type;
      final payload =action.payload;
      switch (type) {
        case TransActionType.translate:
          assert(payload.length == 2);
          this.translate(Vector2.array(payload));
          break;
        case TransActionType.scale:
          assert(payload.length == 2);
          this.scale(Vector2.array(payload));
          break;
        case TransActionType.rotate:
          assert(payload.length == 1);
          this.rotate(payload.first);
          break;
        default:
      }
    }
  }

  ///    m11  m21  0  dx
  ///    m12  m22  0  dy
  ///    0    0    1  0
  ///    0    0    0  1
  Float64List toCanvasMatrix() => Float64List.fromList([
    _matstorage[0],
    _matstorage[1],
    0,
    0,
    _matstorage[2],
    _matstorage[3],
    0,
    0,
    0,
    0,
    1,
    0,
    _matstorage[4],
    _matstorage[5],
    0,
    1,
  ]);
}
