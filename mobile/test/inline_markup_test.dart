import 'package:flutter_test/flutter_test.dart';
import 'package:interview_trainer/core/inline_markup.dart';

void main() {
  group('Снятие inline-разметки', () {
    test('обратные кавычки вокруг кода', () {
      expect(
        stripInlineMarkup('Клиент отправляет `PUT /users/42` с телом'),
        'Клиент отправляет PUT /users/42 с телом',
      );
    });

    test('жирный', () {
      expect(stripInlineMarkup('Это **важно** знать'), 'Это важно знать');
    });

    test('курсив', () {
      expect(stripInlineMarkup('Читается *по-разному*'), 'Читается по-разному');
    });

    test('одиночная звёздочка остаётся: это умножение, а не разметка', () {
      expect(stripInlineMarkup('сложность O(n * log n)'), 'сложность O(n * log n)');
    });

    test('текст без разметки не меняется', () {
      const String plain = 'Что такое GIL и зачем он нужен?';
      expect(stripInlineMarkup(plain), plain);
    });

    test('несколько фрагментов в одной строке', () {
      expect(
        stripInlineMarkup('Вызовите `selectinload`, а не **joinedload**'),
        'Вызовите selectinload, а не joinedload',
      );
    });
  });
}
