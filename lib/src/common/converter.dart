/// The base class of a converter.
abstract class Converter<I, O> {
  /// Converts an input to output.
  O convert(I input);

  /// Inverts an output to input.
  I invert(O output);
}
