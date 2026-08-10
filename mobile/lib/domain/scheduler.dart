/// Планировщик интервальных повторений (CLAUDE.md §3.6).
///
/// Порт серверной `app/services/scheduler.py`. Алгоритм спрятан за
/// интерфейсом: заменить SM-2 на FSRS можно подменой реализации, вызывающий
/// код при этом не меняется.
library;

const double kMinEasinessFactor = 1.3;
const double kDefaultEasinessFactor = 2.5;

/// Порог качества: ниже — цепочка повторений сбрасывается.
const int kFailureThreshold = 3;

const int kFirstIntervalDays = 1;
const int kSecondIntervalDays = 6;

const int kMinQuality = 0;
const int kMaxQuality = 5;

/// Снимок состояния повторения. Неизменяемый: планировщик возвращает новый.
class ReviewSnapshot {
  const ReviewSnapshot({
    this.easinessFactor = kDefaultEasinessFactor,
    this.repetitions = 0,
    this.intervalDays = 0,
    this.dueAt,
  });

  final double easinessFactor;
  final int repetitions;
  final int intervalDays;
  final DateTime? dueAt;

  bool get isNew => repetitions == 0;

  ReviewSnapshot copyWith({
    double? easinessFactor,
    int? repetitions,
    int? intervalDays,
    DateTime? dueAt,
  }) =>
      ReviewSnapshot(
        easinessFactor: easinessFactor ?? this.easinessFactor,
        repetitions: repetitions ?? this.repetitions,
        intervalDays: intervalDays ?? this.intervalDays,
        dueAt: dueAt ?? this.dueAt,
      );
}

/// Контракт планировщика: из состояния и оценки получить новое состояние.
abstract interface class ReviewScheduler {
  ReviewSnapshot review(ReviewSnapshot state, int quality, DateTime now);
}

/// Классический SM-2.
class Sm2Scheduler implements ReviewScheduler {
  const Sm2Scheduler();

  @override
  ReviewSnapshot review(ReviewSnapshot state, int quality, DateTime now) {
    if (quality < kMinQuality || quality > kMaxQuality) {
      throw ArgumentError(
        'качество ответа $quality вне диапазона $kMinQuality–$kMaxQuality',
      );
    }

    final double easiness = _nextEasinessFactor(state.easinessFactor, quality);

    final int repetitions;
    final int intervalDays;
    if (quality < kFailureThreshold) {
      // Провал сбрасывает цепочку: вопрос вернётся завтра.
      repetitions = 0;
      intervalDays = kFirstIntervalDays;
    } else {
      repetitions = state.repetitions + 1;
      intervalDays = _nextInterval(repetitions, state.intervalDays, easiness);
    }

    return ReviewSnapshot(
      easinessFactor: easiness,
      repetitions: repetitions,
      intervalDays: intervalDays,
      dueAt: now.add(Duration(days: intervalDays)),
    );
  }

  static double _nextEasinessFactor(double easiness, int quality) {
    final double delta = 0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02);
    final double next = easiness + delta;
    return next < kMinEasinessFactor ? kMinEasinessFactor : next;
  }

  static int _nextInterval(int repetitions, int intervalDays, double easiness) {
    if (repetitions == 1) {
      return kFirstIntervalDays;
    }
    if (repetitions == 2) {
      return kSecondIntervalDays;
    }
    final int next = (intervalDays * easiness).round();
    return next < kFirstIntervalDays ? kFirstIntervalDays : next;
  }
}

/// Точка подмены алгоритма для всего приложения.
ReviewScheduler getScheduler() => const Sm2Scheduler();
