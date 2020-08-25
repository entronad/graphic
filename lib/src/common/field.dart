const cross = '*';

// Exclude empty list.
List<String> parseField(String field) =>
  field?.split(cross);
