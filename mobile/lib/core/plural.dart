/// Русские числительные: «1 направление», «2 направления», «5 направлений».
///
/// Правило одно на весь язык, поэтому живёт отдельно от экранов: интерфейс
/// растёт, и подстановка вида «направлени(й)» расползётся по всем спискам.
library;

/// Выбирает форму слова по числу.
///
/// [one] — форма для 1 (21, 31…), [few] — для 2–4 (22–24…),
/// [many] — для 0, 5–20 и всех остальных.
String plural(int count, String one, String few, String many) {
  final int mod100 = count.abs() % 100;
  if (mod100 >= 11 && mod100 <= 14) {
    return many;
  }
  return switch (count.abs() % 10) {
    1 => one,
    2 || 3 || 4 => few,
    _ => many,
  };
}

/// То же самое, но сразу с числом: «3 направления».
String withPlural(int count, String one, String few, String many) =>
    '$count ${plural(count, one, few, many)}';
