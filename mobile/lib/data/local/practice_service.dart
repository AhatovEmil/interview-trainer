import 'dart:math';

import 'package:drift/drift.dart' show Value;

import '../../domain/models/profile.dart';
import '../../domain/models/question.dart';
import '../../domain/models/question_list.dart';
import '../../domain/rating.dart' as elo;
import '../../domain/scheduler.dart';
import '../content/question_bank.dart';
import 'app_database.dart';
import 'offline_grader.dart';

/// Тренировка на устройстве.
///
/// Порт серверного `app/services/practice.py`: выбор следующего вопроса, приём
/// ответа с пересчётом Elo и планированием повторения, список вопросов и
/// статистика по темам. Сервера у приложения нет, и всё это считается здесь.
///
/// Правила подбора те же, что были на сервере (CLAUDE.md §3.4–3.6):
/// повторения имеют приоритет над новыми вопросами; вопрос вне диапазона
/// `[minGrade, maxGrade]` целевого уровня не выдаётся вовсе; среди подходящих
/// выше приоритет у темы с большим весом, низким рейтингом и пиком ближе к цели.
class PracticeService {
  PracticeService({
    required AppDatabase database,
    required QuestionBank bank,
    ReviewScheduler? scheduler,
    DateTime Function()? clock,
    Random? random,
  })  : _db = database,
        _bank = bank,
        _scheduler = scheduler ?? getScheduler(),
        _now = clock ?? DateTime.now,
        _random = random ?? Random();

  final AppDatabase _db;
  final QuestionBank _bank;
  final ReviewScheduler _scheduler;
  final DateTime Function() _now;
  final Random _random;

  static const OfflineGrader _grader = OfflineGrader();

  /// Сколько лучших кандидатов участвует в жеребьёвке.
  ///
  /// Строго лучший вопрос сделал бы порядок выдачи детерминированным: человек,
  /// переустановивший приложение, получил бы ровно ту же последовательность.
  static const int _shortlist = 5;

  // --- выдача -----------------------------------------------------------------

  Future<NextQuestion?> nextQuestion(String specializationId) async {
    final Profile? profile = await _db.profileFor(specializationId);
    if (profile == null) {
      return null;
    }

    final DateTime now = _now();
    final List<ReviewState> due = await _db.dueReviews(now);
    for (final ReviewState state in due) {
      final BankQuestion? candidate = _bank.byId(state.questionId);
      if (candidate != null && candidate.specializations.contains(specializationId)) {
        return NextQuestion(
          question: candidate.question,
          isReview: true,
          dueAt: state.dueAt,
        );
      }
    }

    final BankQuestion? fresh = await _pickNew(specializationId, profile.targetGrade);
    if (fresh == null) {
      return null;
    }
    return NextQuestion(question: fresh.question, isReview: false, dueAt: null);
  }

  Future<BankQuestion?> _pickNew(String specializationId, int targetGrade) async {
    final Set<String> answered = await _db.answeredQuestionIds(specializationId);
    final Map<String, TopicRating> ratings = await _db.ratingsFor(specializationId);
    final Map<String, double> weights = _bank.topicWeights(specializationId, targetGrade);

    final List<BankQuestion> candidates = _bank
        .forSpecialization(specializationId)
        .where(
          (BankQuestion item) =>
              !answered.contains(item.question.id) &&
              item.question.minGrade <= targetGrade &&
              item.question.maxGrade >= targetGrade,
        )
        .toList();

    if (candidates.isEmpty) {
      return null;
    }

    candidates.sort((BankQuestion a, BankQuestion b) {
      final int byScore = _priority(b, targetGrade, weights, ratings)
          .compareTo(_priority(a, targetGrade, weights, ratings));
      // Стабильный порядок при равном приоритете: без него сортировка зависела
      // бы от порядка в файле и менялась при любой правке контента.
      return byScore != 0 ? byScore : a.question.id.compareTo(b.question.id);
    });

    final int limit = candidates.length < _shortlist ? candidates.length : _shortlist;
    return candidates[_random.nextInt(limit)];
  }

  /// Приоритет вопроса: важность темы, пробел по ней и близость пика к цели.
  double _priority(
    BankQuestion item,
    int targetGrade,
    Map<String, double> weights,
    Map<String, TopicRating> ratings,
  ) {
    final double weight = weights[item.question.topicCode] ?? 0;
    final double rating = ratings[item.question.topicCode]?.rating ?? elo.kStartRating;
    final double gap = 1 - elo.normalizedRating(rating);

    // Чем дальше пик вопроса от целевого уровня, тем он менее уместен.
    final int distance = (item.question.peakGrade - targetGrade).abs();
    final double proximity = 1 / (1 + distance);

    // Частота на реальных собеседованиях — прямой множитель: то, что спрашивают
    // всегда, важнее редкого, при прочих равных.
    final double frequency = item.question.frequency / 5;

    return weight * gap * proximity * frequency;
  }

  // --- ответ ------------------------------------------------------------------

  Future<AnswerResult> submitAnswer({
    required String specializationId,
    required String submissionId,
    required String questionId,
    List<String> selectedOptions = const <String>[],
    String? freeText,
    int? selfAssessment,
  }) async {
    final BankQuestion? item = _bank.byId(questionId);
    if (item == null) {
      throw ArgumentError('вопрос $questionId не найден в банке');
    }

    final GradedAnswer graded = _grader.grade(
      question: item.question,
      selectedOptions: selectedOptions,
      selfAssessment: selfAssessment,
    );

    final DateTime now = _now();
    final String topic = item.question.topicCode;

    final Map<String, TopicRating> ratings = await _db.ratingsFor(specializationId);
    final TopicRating? current = ratings[topic];
    final double ratingBefore = current?.rating ?? elo.kStartRating;
    final int answersOnTopic = current?.answersCount ?? 0;

    final elo.EloUpdate update = elo.applyElo(
      userRating: ratingBefore,
      questionRating: item.difficultyRating,
      score: graded.score,
      answersOnTopic: answersOnTopic,
    );

    final ReviewSnapshot before = await _snapshot(questionId);
    final ReviewSnapshot after = _scheduler.review(before, graded.quality, now);

    await _db.saveAnswer(
      AnswersCompanion(
        submissionId: Value<String>(submissionId),
        questionId: Value<String>(questionId),
        specializationId: Value<String>(specializationId),
        topicCode: Value<String>(topic),
        selectedOptionsJson: Value<String>(_encodeOptions(selectedOptions)),
        freeText: Value<String?>(freeText),
        selfAssessment: Value<int?>(selfAssessment),
        score: Value<double>(graded.score),
        quality: Value<int>(graded.quality),
        answeredAt: Value<DateTime>(now),
      ),
    );
    await _db.saveTopicRating(
      specializationId: specializationId,
      topicCode: topic,
      rating: update.userRatingAfter,
      answersCount: answersOnTopic + 1,
    );
    await _db.saveReviewState(
      ReviewStatesCompanion(
        questionId: Value<String>(questionId),
        easinessFactor: Value<double>(after.easinessFactor),
        repetitions: Value<int>(after.repetitions),
        intervalDays: Value<int>(after.intervalDays),
        dueAt: Value<DateTime>(after.dueAt!),
        lastReviewedAt: Value<DateTime>(now),
      ),
    );
    await _db.bumpAnswersCount(specializationId);

    return AnswerResult(
      score: graded.score,
      quality: graded.quality,
      explanation: item.explanation,
      ratingBefore: update.userRatingBefore,
      ratingAfter: update.userRatingAfter,
      ratingDelta: update.userDelta,
      grade: elo.gradeFromRating(update.userRatingAfter),
      nextReviewAt: after.dueAt,
    );
  }

  Future<ReviewSnapshot> _snapshot(String questionId) async {
    final ReviewState? state = await _db.reviewStateFor(questionId);
    if (state == null) {
      return const ReviewSnapshot();
    }
    return ReviewSnapshot(
      easinessFactor: state.easinessFactor,
      repetitions: state.repetitions,
      intervalDays: state.intervalDays,
      dueAt: state.dueAt,
    );
  }

  static String _encodeOptions(List<String> options) =>
      options.isEmpty ? '[]' : '["${options.join('","')}"]';

  // --- список -----------------------------------------------------------------

  Future<QuestionListSummary> questionList(String specializationId) async {
    final Profile? profile = await _db.profileFor(specializationId);
    final int targetGrade = profile?.targetGrade ?? 0;

    final List<Answer> answers = await _db.answersFor(specializationId);
    final Map<String, ReviewState> reviews = await _db.allReviewStates();

    // Последняя попытка, а не лучшая: список показывает текущее положение дел,
    // иначе забытый вопрос выглядел бы освоенным.
    final Map<String, Answer> lastByQuestion = <String, Answer>{};
    final Map<String, int> attempts = <String, int>{};
    for (final Answer answer in answers) {
      lastByQuestion[answer.questionId] = answer;
      attempts[answer.questionId] = (attempts[answer.questionId] ?? 0) + 1;
    }

    final List<QuestionListItem> items = _bank
        .forSpecialization(specializationId)
        .map((BankQuestion item) {
      final Answer? last = lastByQuestion[item.question.id];
      return QuestionListItem(
        id: item.question.id,
        title: item.question.title,
        topicCode: item.question.topicCode,
        topicTitle: item.question.topicTitle,
        peakGrade: item.question.peakGrade,
        frequency: item.question.frequency,
        status: last == null
            ? QuestionStatus.unanswered
            : _statusFromScore(last.score),
        answersCount: attempts[item.question.id] ?? 0,
        lastAnsweredAt: last?.answeredAt,
        dueAt: reviews[item.question.id]?.dueAt,
        inGradeRange: item.question.minGrade <= targetGrade &&
            item.question.maxGrade >= targetGrade,
      );
    }).toList(growable: false);

    return QuestionListSummary(
      specializationId: specializationId,
      total: items.length,
      answered: items.where((QuestionListItem item) => item.status.isAnswered).length,
      correct: items.where((QuestionListItem item) => item.status == QuestionStatus.correct).length,
      partial: items.where((QuestionListItem item) => item.status == QuestionStatus.partial).length,
      wrong: items.where((QuestionListItem item) => item.status == QuestionStatus.wrong).length,
      items: items,
    );
  }

  static QuestionStatus _statusFromScore(double score) {
    if (score >= elo.kScoreCorrect) {
      return QuestionStatus.correct;
    }
    return score > 0 ? QuestionStatus.partial : QuestionStatus.wrong;
  }

  Future<NextQuestion?> questionById(String specializationId, String questionId) async {
    final BankQuestion? item = _bank.byId(questionId);
    if (item == null || !item.specializations.contains(specializationId)) {
      return null;
    }
    final ReviewState? state = await _db.reviewStateFor(questionId);
    return NextQuestion(
      question: item.question,
      isReview: state != null,
      dueAt: state?.dueAt,
    );
  }

  // --- статистика -------------------------------------------------------------

  Future<PracticeStats> stats(String specializationId) async {
    final Profile? profile = await _db.profileFor(specializationId);
    final int targetGrade = profile?.targetGrade ?? 0;

    final Map<String, TopicRating> ratings = await _db.ratingsFor(specializationId);
    final Map<String, double> weights = _bank.topicWeights(specializationId, targetGrade);
    final Map<String, String> titles = _bank.topicTitles(specializationId);
    final int answersCount = await _db.countAnswers(specializationId);

    final List<TopicStats> topics = ratings.entries
        .map(
          (MapEntry<String, TopicRating> entry) => TopicStats(
            topicCode: entry.key,
            title: titles[entry.key] ?? entry.key,
            rating: entry.value.rating,
            grade: elo.gradeFromRating(entry.value.rating),
            gradeCode: '',
            answersCount: entry.value.answersCount,
            weight: weights[entry.key] ?? 0,
          ),
        )
        .toList()
      ..sort((TopicStats a, TopicStats b) => a.rating.compareTo(b.rating));

    final double? overall = elo.overallRating(
      <String, double>{
        for (final MapEntry<String, TopicRating> entry in ratings.entries)
          entry.key: entry.value.rating,
      },
      weights,
    );

    // До двадцати ответов оценку по специализации не показываем: на трёх
    // вопросах она была бы шумом, выданным за измерение (CLAUDE.md §3.5).
    final bool enoughData = answersCount >= elo.kMinAnswersForEstimate;

    return PracticeStats(
      specializationId: specializationId,
      answersCount: answersCount,
      topics: topics,
      overallRating: enoughData ? overall : null,
      overallGrade: enoughData && overall != null ? elo.gradeFromRating(overall) : null,
      overallGradeCode: null,
      lock: enoughData ? null : StatsLock.notEnoughData,
    );
  }
}
