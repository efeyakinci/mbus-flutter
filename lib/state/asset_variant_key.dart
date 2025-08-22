/// Canonical, deterministic string signature for a variant context.
/// Sorts keys and flattens to "k1:v1;k2:v2;..."
String canonicalVariantKey(Map<String, Object?> ctx) {
  final entries = ctx.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  final sb = StringBuffer();
  for (final e in entries) {
    sb.write(e.key);
    sb.write(':');
    sb.write(e.value);
    sb.write(';');
  }
  return sb.toString();
}
