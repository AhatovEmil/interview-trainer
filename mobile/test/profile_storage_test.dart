import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_trainer/data/local/app_database.dart';
import 'package:interview_trainer/domain/models/grade.dart';

/// Хранение профиля.
///
/// Профиль — единственное, что приложение помнит о человеке: выбранный стек и
/// уровень, к которому он готовится. Самооценки в нём больше нет, и эти тесты
/// закрепляют, что осталось ровно то, что нужно, а смена стека не теряет
/// прогресс по прежнему.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('профиль хранит стек и целевой уровень', () async {
    await db.saveProfile(specializationId: 'backend_python', targetGrade: Grade.middle);

    final Profile? profile = await db.primaryProfile();

    expect(profile?.specializationId, 'backend_python');
    expect(profile?.targetGrade, Grade.middle);
    expect(profile?.isPrimary, isTrue);
  });

  test('основной профиль ровно один', () async {
    await db.saveProfile(specializationId: 'backend_python', targetGrade: Grade.middle);
    await db.saveProfile(specializationId: 'backend_go', targetGrade: Grade.senior);

    final List<Profile> all = await db.allProfiles();

    expect(all.length, 2, reason: 'прогресс по прежнему стеку остаётся');
    expect(
      all.where((Profile row) => row.isPrimary).map((Profile row) => row.specializationId),
      <String>['backend_go'],
    );
  });

  test('смена уровня не обнуляет счётчик ответов', () async {
    await db.saveProfile(specializationId: 'backend_python', targetGrade: Grade.junior);
    await db.bumpAnswersCount('backend_python');
    await db.bumpAnswersCount('backend_python');

    await db.saveProfile(specializationId: 'backend_python', targetGrade: Grade.senior);

    final Profile? profile = await db.primaryProfile();
    expect(profile?.targetGrade, Grade.senior);
    expect(profile?.answersCount, 2);
  });

  test('возврат к прежнему стеку застаёт его уровень на месте', () async {
    await db.saveProfile(specializationId: 'backend_python', targetGrade: Grade.lead);
    await db.saveProfile(specializationId: 'backend_go', targetGrade: Grade.junior);
    await db.saveProfile(specializationId: 'backend_python', targetGrade: Grade.lead);

    expect((await db.profileFor('backend_go'))?.targetGrade, Grade.junior);
    expect((await db.primaryProfile())?.targetGrade, Grade.lead);
  });
}
