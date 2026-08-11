import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_trainer/data/local/app_database.dart';

/// Заметки к вопросам и вопросы с реальных собеседований.
///
/// И то и другое человек пишет руками, и потерять это неприятнее, чем любой
/// счётчик: восстановить неоткуда, сервера у приложения нет.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('Заметки', () {
    test('сохраняется и читается', () async {
      await db.saveNote(questionId: 'q1', body: 'не сказал про индексы');

      final QuestionNote? note = await db.noteFor('q1');

      expect(note?.body, 'не сказал про индексы');
    });

    test('повторное сохранение заменяет прежнюю, а не добавляет вторую', () async {
      await db.saveNote(questionId: 'q1', body: 'первая');
      await db.saveNote(questionId: 'q1', body: 'вторая');

      expect((await db.noteFor('q1'))?.body, 'вторая');
      expect((await db.allNotes()).length, 1);
    });

    test('пустой текст удаляет заметку', () async {
      await db.saveNote(questionId: 'q1', body: 'было что сказать');

      await db.saveNote(questionId: 'q1', body: '   ');

      expect(await db.noteFor('q1'), isNull);
    });

    test('текст обрезается по краям', () async {
      await db.saveNote(questionId: 'q1', body: '  с пробелами  ');

      expect((await db.noteFor('q1'))?.body, 'с пробелами');
    });

    test('заметки разных вопросов не смешиваются', () async {
      await db.saveNote(questionId: 'q1', body: 'первый');
      await db.saveNote(questionId: 'q2', body: 'второй');

      final Map<String, QuestionNote> all = await db.allNotes();

      expect(all['q1']?.body, 'первый');
      expect(all['q2']?.body, 'второй');
    });
  });

  group('Вопросы с собеседований', () {
    Future<void> add(String id, String title, {String? company}) => db.saveOwnQuestion(
          OwnQuestionsCompanion(
            id: Value<String>(id),
            specializationId: const Value<String>('backend_python'),
            title: Value<String>(title),
            company: Value<String?>(company),
            createdAt: Value<DateTime>(DateTime(2026, 8, int.parse(id))),
          ),
        );

    test('сохраняются и отдаются свежими сверху', () async {
      await add('1', 'первый');
      await add('2', 'второй');

      final List<OwnQuestion> items = await db.ownQuestionsFor('backend_python');

      expect(items.map((OwnQuestion item) => item.title).toList(), <String>['второй', 'первый']);
    });

    test('видны только вопросы своей специализации', () async {
      await add('1', 'питон');
      await db.saveOwnQuestion(
        OwnQuestionsCompanion(
          id: const Value<String>('2'),
          specializationId: const Value<String>('backend_go'),
          title: const Value<String>('го'),
          createdAt: Value<DateTime>(DateTime(2026, 8, 2)),
        ),
      );

      final List<OwnQuestion> items = await db.ownQuestionsFor('backend_python');

      expect(items.length, 1);
      expect(items.single.title, 'питон');
    });

    test('правка не создаёт вторую запись', () async {
      await add('1', 'как было');
      await add('1', 'как стало');

      final List<OwnQuestion> items = await db.ownQuestionsFor('backend_python');

      expect(items.length, 1);
      expect(items.single.title, 'как стало');
    });

    test('удаление убирает запись', () async {
      await add('1', 'лишний');

      await db.deleteOwnQuestion('1');

      expect(await db.ownQuestionsFor('backend_python'), isEmpty);
    });

    test('компания необязательна', () async {
      await add('1', 'без компании');

      expect((await db.ownQuestionsFor('backend_python')).single.company, isNull);
    });
  });

  test('полная очистка стирает и заметки, и свои вопросы', () async {
    await db.saveNote(questionId: 'q1', body: 'заметка');
    await db.saveOwnQuestion(
      OwnQuestionsCompanion(
        id: const Value<String>('1'),
        specializationId: const Value<String>('backend_python'),
        title: const Value<String>('вопрос'),
        createdAt: Value<DateTime>(DateTime(2026, 8, 1)),
      ),
    );

    await db.wipe();

    expect(await db.allNotes(), isEmpty);
    expect(await db.ownQuestionsFor('backend_python'), isEmpty);
  });
}
