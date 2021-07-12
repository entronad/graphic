abstract class Converter<I, O> {
  O convert(I input);

  I invert(O output);
}
