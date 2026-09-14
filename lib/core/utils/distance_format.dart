/// Formata distâncias em metros para exibição.
///
/// O deslocamento passou a ser decimal porque anão e halfling andam 7,5 m.
/// Sem isso a ficha mostraria "7.5m", com ponto, e "9.0m" para valores
/// redondos.
String formatMeters(num? value, {String fallback = '—'}) {
  if (value == null) return fallback;

  final rounded = (value * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) {
    return '${rounded.toInt()} m';
  }

  return '${rounded.toStringAsFixed(1).replaceAll('.', ',')} m';
}
