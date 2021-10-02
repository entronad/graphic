/// Variable identifiers should not be reserved Strings.
/// Reserved strings are started with '_:'.
/// They are checked in parseVariable.
abstract class Reserveds {
  static const unitTag = '_:1';

  static bool legalIdentifiers(Iterable<String> identifiers) =>
    identifiers.every((identifier) =>
      identifier != unitTag
    );
}
