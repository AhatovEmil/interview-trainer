/// Снятие inline-разметки markdown с текста, который выводится обычным Text.
///
/// Формулировки вопросов и разборы приходят из YAML, где принято помечать код
/// обратными кавычками, а акценты — звёздочками. Рисовать их отдельными стилями
/// пока не нужно, но и показывать сырые символы пользователю нельзя.
library;

/// Убирает `**жирный**`, `*курсив*` и `` `код` ``, оставляя сам текст.
String stripInlineMarkup(String value) {
  final String withoutBold = value.replaceAll('**', '');
  final String withoutCode = withoutBold.replaceAll('`', '');
  // Одиночные звёздочки убираем только парные, иначе пострадает умножение (a * b).
  return withoutCode.replaceAllMapped(
    RegExp(r'\*(\S(?:[^*\n]*\S)?)\*'),
    (Match match) => match.group(1)!,
  );
}
