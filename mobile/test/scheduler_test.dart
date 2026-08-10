import 'package:flutter_test/flutter_test.dart';
import 'package:interview_trainer/domain/scheduler.dart';

/// Проверки перенесены с сервера (backend/tests/test_scheduler.py).
/// Причина та же, что у рейтинга: интервалы, посчитанные на устройстве и на
/// сервере, обязаны совпадать, иначе включение синхронизации перетасует всю
/// очередь повторений.
void main() {
  final DateTime now = DateTime.utc(2026, 8, 10, 12);
  final ReviewScheduler scheduler = getScheduler();

  group('Успешные повторения', () {
    test('первое даёт один день', () {
      final ReviewSnapshot state = scheduler.review(const ReviewSnapshot(), 4, now);

      expect(state.repetitions, 1);
      expect(state.intervalDays, kFirstIntervalDays);
      expect(state.dueAt, now.add(const Duration(days: 1)));
    });

    test('второе даёт шесть дней', () {
      final ReviewSnapshot first = scheduler.review(const ReviewSnapshot(), 4, now);

      final ReviewSnapshot second = scheduler.review(first, 4, now);

      expect(second.repetitions, 2);
      expect(second.intervalDays, kSecondIntervalDays);
      expect(second.dueAt, now.add(const Duration(days: 6)));
    });

    test('третье умножает интервал на коэффициент лёгкости', () {
      const ReviewSnapshot state = ReviewSnapshot(
        easinessFactor: 2.5,
        repetitions: 2,
        intervalDays: 6,
      );

      final ReviewSnapshot third = scheduler.review(state, 5, now);

      expect(third.repetitions, 3);
      expect(third.intervalDays, (6 * third.easinessFactor).round());
    });

    test('серия верных ответов удлиняет интервалы', () {
      ReviewSnapshot state = const ReviewSnapshot();
      final List<int> intervals = <int>[];

      for (int i = 0; i < 5; i++) {
        state = scheduler.review(state, 5, now);
        intervals.add(state.intervalDays);
      }

      for (int i = 1; i < intervals.length; i++) {
        expect(intervals[i], greaterThan(intervals[i - 1]));
      }
    });
  });

  group('Провал', () {
    test('сбрасывает цепочку и возвращает вопрос завтра', () {
      const ReviewSnapshot state = ReviewSnapshot(
        easinessFactor: 2.6,
        repetitions: 5,
        intervalDays: 40,
      );

      final ReviewSnapshot failed = scheduler.review(state, 2, now);

      expect(failed.repetitions, 0);
      expect(failed.intervalDays, kFirstIntervalDays);
      expect(failed.dueAt, now.add(const Duration(days: 1)));
    });

    test('всё равно снижает коэффициент лёгкости', () {
      const ReviewSnapshot state = ReviewSnapshot(
        easinessFactor: 2.5,
        repetitions: 3,
        intervalDays: 15,
      );

      final ReviewSnapshot failed = scheduler.review(state, 0, now);

      expect(failed.easinessFactor, lessThan(state.easinessFactor));
    });
  });

  group('Коэффициент лёгкости', () {
    test('совпадает с формулой SM-2', () {
      const Map<int, double> expected = <int, double>{
        5: 2.6,
        4: 2.5,
        3: 2.36,
        2: 2.18,
        1: 1.96,
        0: 1.7,
      };

      expected.forEach((int quality, double value) {
        final ReviewSnapshot state = scheduler.review(
          const ReviewSnapshot(easinessFactor: 2.5),
          quality,
          now,
        );
        expect(state.easinessFactor, closeTo(value, 1e-9), reason: 'качество $quality');
      });
    });

    test('не опускается ниже нижней границы', () {
      ReviewSnapshot state = const ReviewSnapshot(easinessFactor: kMinEasinessFactor);

      for (int i = 0; i < 20; i++) {
        state = scheduler.review(state, 0, now);
      }

      expect(state.easinessFactor, kMinEasinessFactor);
    });
  });

  group('Границы', () {
    test('качество вне диапазона 0–5 отвергается', () {
      expect(() => scheduler.review(const ReviewSnapshot(), 6, now), throwsArgumentError);
      expect(() => scheduler.review(const ReviewSnapshot(), -1, now), throwsArgumentError);
    });
  });
}
