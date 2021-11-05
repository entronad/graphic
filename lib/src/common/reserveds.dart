/// The reserved variable idendifiers.
///
/// They are started with `'_:'`.
abstract class Reserveds {
  static const unitTag = '_:1';

  static bool legalIdentifiers(Iterable<String> identifiers) =>
      identifiers.every((identifier) => identifier != unitTag);
}
