// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _specializationIdMeta =
      const VerificationMeta('specializationId');
  @override
  late final GeneratedColumn<String> specializationId = GeneratedColumn<String>(
      'specialization_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetGradeMeta =
      const VerificationMeta('targetGrade');
  @override
  late final GeneratedColumn<int> targetGrade = GeneratedColumn<int>(
      'target_grade', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isPrimaryMeta =
      const VerificationMeta('isPrimary');
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
      'is_primary', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_primary" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _answersCountMeta =
      const VerificationMeta('answersCount');
  @override
  late final GeneratedColumn<int> answersCount = GeneratedColumn<int>(
      'answers_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [specializationId, targetGrade, isPrimary, answersCount, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(Insertable<Profile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('specialization_id')) {
      context.handle(
          _specializationIdMeta,
          specializationId.isAcceptableOrUnknown(
              data['specialization_id']!, _specializationIdMeta));
    } else if (isInserting) {
      context.missing(_specializationIdMeta);
    }
    if (data.containsKey('target_grade')) {
      context.handle(
          _targetGradeMeta,
          targetGrade.isAcceptableOrUnknown(
              data['target_grade']!, _targetGradeMeta));
    } else if (isInserting) {
      context.missing(_targetGradeMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(_isPrimaryMeta,
          isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta));
    }
    if (data.containsKey('answers_count')) {
      context.handle(
          _answersCountMeta,
          answersCount.isAcceptableOrUnknown(
              data['answers_count']!, _answersCountMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {specializationId};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      specializationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}specialization_id'])!,
      targetGrade: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_grade'])!,
      isPrimary: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_primary'])!,
      answersCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}answers_count'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String specializationId;

  /// К какому уровню готовится — именно он определяет выдачу.
  ///
  /// Уровень здесь один. Самооценка была вторым полем и не окупала себя: её
  /// спрашивали на старте, а использовали только для подписи под целевым
  /// уровнем. Сам уровень приложение всё равно измеряет по ответам.
  final int targetGrade;
  final bool isPrimary;
  final int answersCount;
  final DateTime updatedAt;
  const Profile(
      {required this.specializationId,
      required this.targetGrade,
      required this.isPrimary,
      required this.answersCount,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['specialization_id'] = Variable<String>(specializationId);
    map['target_grade'] = Variable<int>(targetGrade);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['answers_count'] = Variable<int>(answersCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      specializationId: Value(specializationId),
      targetGrade: Value(targetGrade),
      isPrimary: Value(isPrimary),
      answersCount: Value(answersCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      specializationId: serializer.fromJson<String>(json['specializationId']),
      targetGrade: serializer.fromJson<int>(json['targetGrade']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      answersCount: serializer.fromJson<int>(json['answersCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'specializationId': serializer.toJson<String>(specializationId),
      'targetGrade': serializer.toJson<int>(targetGrade),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'answersCount': serializer.toJson<int>(answersCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Profile copyWith(
          {String? specializationId,
          int? targetGrade,
          bool? isPrimary,
          int? answersCount,
          DateTime? updatedAt}) =>
      Profile(
        specializationId: specializationId ?? this.specializationId,
        targetGrade: targetGrade ?? this.targetGrade,
        isPrimary: isPrimary ?? this.isPrimary,
        answersCount: answersCount ?? this.answersCount,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      specializationId: data.specializationId.present
          ? data.specializationId.value
          : this.specializationId,
      targetGrade:
          data.targetGrade.present ? data.targetGrade.value : this.targetGrade,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      answersCount: data.answersCount.present
          ? data.answersCount.value
          : this.answersCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('specializationId: $specializationId, ')
          ..write('targetGrade: $targetGrade, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('answersCount: $answersCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      specializationId, targetGrade, isPrimary, answersCount, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.specializationId == this.specializationId &&
          other.targetGrade == this.targetGrade &&
          other.isPrimary == this.isPrimary &&
          other.answersCount == this.answersCount &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> specializationId;
  final Value<int> targetGrade;
  final Value<bool> isPrimary;
  final Value<int> answersCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.specializationId = const Value.absent(),
    this.targetGrade = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.answersCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String specializationId,
    required int targetGrade,
    this.isPrimary = const Value.absent(),
    this.answersCount = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : specializationId = Value(specializationId),
        targetGrade = Value(targetGrade),
        updatedAt = Value(updatedAt);
  static Insertable<Profile> custom({
    Expression<String>? specializationId,
    Expression<int>? targetGrade,
    Expression<bool>? isPrimary,
    Expression<int>? answersCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (specializationId != null) 'specialization_id': specializationId,
      if (targetGrade != null) 'target_grade': targetGrade,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (answersCount != null) 'answers_count': answersCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith(
      {Value<String>? specializationId,
      Value<int>? targetGrade,
      Value<bool>? isPrimary,
      Value<int>? answersCount,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ProfilesCompanion(
      specializationId: specializationId ?? this.specializationId,
      targetGrade: targetGrade ?? this.targetGrade,
      isPrimary: isPrimary ?? this.isPrimary,
      answersCount: answersCount ?? this.answersCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (specializationId.present) {
      map['specialization_id'] = Variable<String>(specializationId.value);
    }
    if (targetGrade.present) {
      map['target_grade'] = Variable<int>(targetGrade.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (answersCount.present) {
      map['answers_count'] = Variable<int>(answersCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('specializationId: $specializationId, ')
          ..write('targetGrade: $targetGrade, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('answersCount: $answersCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnswersTable extends Answers with TableInfo<$AnswersTable, Answer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _submissionIdMeta =
      const VerificationMeta('submissionId');
  @override
  late final GeneratedColumn<String> submissionId = GeneratedColumn<String>(
      'submission_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
      'question_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _specializationIdMeta =
      const VerificationMeta('specializationId');
  @override
  late final GeneratedColumn<String> specializationId = GeneratedColumn<String>(
      'specialization_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicCodeMeta =
      const VerificationMeta('topicCode');
  @override
  late final GeneratedColumn<String> topicCode = GeneratedColumn<String>(
      'topic_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _selectedOptionsJsonMeta =
      const VerificationMeta('selectedOptionsJson');
  @override
  late final GeneratedColumn<String> selectedOptionsJson =
      GeneratedColumn<String>('selected_options_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _freeTextMeta =
      const VerificationMeta('freeText');
  @override
  late final GeneratedColumn<String> freeText = GeneratedColumn<String>(
      'free_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _selfAssessmentMeta =
      const VerificationMeta('selfAssessment');
  @override
  late final GeneratedColumn<int> selfAssessment = GeneratedColumn<int>(
      'self_assessment', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
      'score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _qualityMeta =
      const VerificationMeta('quality');
  @override
  late final GeneratedColumn<int> quality = GeneratedColumn<int>(
      'quality', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _answeredAtMeta =
      const VerificationMeta('answeredAt');
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
      'answered_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        submissionId,
        questionId,
        specializationId,
        topicCode,
        selectedOptionsJson,
        freeText,
        selfAssessment,
        score,
        quality,
        answeredAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'answers';
  @override
  VerificationContext validateIntegrity(Insertable<Answer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('submission_id')) {
      context.handle(
          _submissionIdMeta,
          submissionId.isAcceptableOrUnknown(
              data['submission_id']!, _submissionIdMeta));
    } else if (isInserting) {
      context.missing(_submissionIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('specialization_id')) {
      context.handle(
          _specializationIdMeta,
          specializationId.isAcceptableOrUnknown(
              data['specialization_id']!, _specializationIdMeta));
    } else if (isInserting) {
      context.missing(_specializationIdMeta);
    }
    if (data.containsKey('topic_code')) {
      context.handle(_topicCodeMeta,
          topicCode.isAcceptableOrUnknown(data['topic_code']!, _topicCodeMeta));
    } else if (isInserting) {
      context.missing(_topicCodeMeta);
    }
    if (data.containsKey('selected_options_json')) {
      context.handle(
          _selectedOptionsJsonMeta,
          selectedOptionsJson.isAcceptableOrUnknown(
              data['selected_options_json']!, _selectedOptionsJsonMeta));
    }
    if (data.containsKey('free_text')) {
      context.handle(_freeTextMeta,
          freeText.isAcceptableOrUnknown(data['free_text']!, _freeTextMeta));
    }
    if (data.containsKey('self_assessment')) {
      context.handle(
          _selfAssessmentMeta,
          selfAssessment.isAcceptableOrUnknown(
              data['self_assessment']!, _selfAssessmentMeta));
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('quality')) {
      context.handle(_qualityMeta,
          quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta));
    } else if (isInserting) {
      context.missing(_qualityMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(
          _answeredAtMeta,
          answeredAt.isAcceptableOrUnknown(
              data['answered_at']!, _answeredAtMeta));
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {submissionId};
  @override
  Answer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Answer(
      submissionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}submission_id'])!,
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_id'])!,
      specializationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}specialization_id'])!,
      topicCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_code'])!,
      selectedOptionsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}selected_options_json'])!,
      freeText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}free_text']),
      selfAssessment: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}self_assessment']),
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}score'])!,
      quality: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quality'])!,
      answeredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}answered_at'])!,
    );
  }

  @override
  $AnswersTable createAlias(String alias) {
    return $AnswersTable(attachedDatabase, alias);
  }
}

class Answer extends DataClass implements Insertable<Answer> {
  /// Идентификатор попытки. Защищает от двойной записи при повторном нажатии.
  final String submissionId;
  final String questionId;
  final String specializationId;

  /// Раздел дублируется сюда, чтобы статистика не искала вопрос в банке.
  final String topicCode;
  final String selectedOptionsJson;
  final String? freeText;
  final int? selfAssessment;
  final double score;
  final int quality;
  final DateTime answeredAt;
  const Answer(
      {required this.submissionId,
      required this.questionId,
      required this.specializationId,
      required this.topicCode,
      required this.selectedOptionsJson,
      this.freeText,
      this.selfAssessment,
      required this.score,
      required this.quality,
      required this.answeredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['submission_id'] = Variable<String>(submissionId);
    map['question_id'] = Variable<String>(questionId);
    map['specialization_id'] = Variable<String>(specializationId);
    map['topic_code'] = Variable<String>(topicCode);
    map['selected_options_json'] = Variable<String>(selectedOptionsJson);
    if (!nullToAbsent || freeText != null) {
      map['free_text'] = Variable<String>(freeText);
    }
    if (!nullToAbsent || selfAssessment != null) {
      map['self_assessment'] = Variable<int>(selfAssessment);
    }
    map['score'] = Variable<double>(score);
    map['quality'] = Variable<int>(quality);
    map['answered_at'] = Variable<DateTime>(answeredAt);
    return map;
  }

  AnswersCompanion toCompanion(bool nullToAbsent) {
    return AnswersCompanion(
      submissionId: Value(submissionId),
      questionId: Value(questionId),
      specializationId: Value(specializationId),
      topicCode: Value(topicCode),
      selectedOptionsJson: Value(selectedOptionsJson),
      freeText: freeText == null && nullToAbsent
          ? const Value.absent()
          : Value(freeText),
      selfAssessment: selfAssessment == null && nullToAbsent
          ? const Value.absent()
          : Value(selfAssessment),
      score: Value(score),
      quality: Value(quality),
      answeredAt: Value(answeredAt),
    );
  }

  factory Answer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Answer(
      submissionId: serializer.fromJson<String>(json['submissionId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      specializationId: serializer.fromJson<String>(json['specializationId']),
      topicCode: serializer.fromJson<String>(json['topicCode']),
      selectedOptionsJson:
          serializer.fromJson<String>(json['selectedOptionsJson']),
      freeText: serializer.fromJson<String?>(json['freeText']),
      selfAssessment: serializer.fromJson<int?>(json['selfAssessment']),
      score: serializer.fromJson<double>(json['score']),
      quality: serializer.fromJson<int>(json['quality']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'submissionId': serializer.toJson<String>(submissionId),
      'questionId': serializer.toJson<String>(questionId),
      'specializationId': serializer.toJson<String>(specializationId),
      'topicCode': serializer.toJson<String>(topicCode),
      'selectedOptionsJson': serializer.toJson<String>(selectedOptionsJson),
      'freeText': serializer.toJson<String?>(freeText),
      'selfAssessment': serializer.toJson<int?>(selfAssessment),
      'score': serializer.toJson<double>(score),
      'quality': serializer.toJson<int>(quality),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
    };
  }

  Answer copyWith(
          {String? submissionId,
          String? questionId,
          String? specializationId,
          String? topicCode,
          String? selectedOptionsJson,
          Value<String?> freeText = const Value.absent(),
          Value<int?> selfAssessment = const Value.absent(),
          double? score,
          int? quality,
          DateTime? answeredAt}) =>
      Answer(
        submissionId: submissionId ?? this.submissionId,
        questionId: questionId ?? this.questionId,
        specializationId: specializationId ?? this.specializationId,
        topicCode: topicCode ?? this.topicCode,
        selectedOptionsJson: selectedOptionsJson ?? this.selectedOptionsJson,
        freeText: freeText.present ? freeText.value : this.freeText,
        selfAssessment:
            selfAssessment.present ? selfAssessment.value : this.selfAssessment,
        score: score ?? this.score,
        quality: quality ?? this.quality,
        answeredAt: answeredAt ?? this.answeredAt,
      );
  Answer copyWithCompanion(AnswersCompanion data) {
    return Answer(
      submissionId: data.submissionId.present
          ? data.submissionId.value
          : this.submissionId,
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      specializationId: data.specializationId.present
          ? data.specializationId.value
          : this.specializationId,
      topicCode: data.topicCode.present ? data.topicCode.value : this.topicCode,
      selectedOptionsJson: data.selectedOptionsJson.present
          ? data.selectedOptionsJson.value
          : this.selectedOptionsJson,
      freeText: data.freeText.present ? data.freeText.value : this.freeText,
      selfAssessment: data.selfAssessment.present
          ? data.selfAssessment.value
          : this.selfAssessment,
      score: data.score.present ? data.score.value : this.score,
      quality: data.quality.present ? data.quality.value : this.quality,
      answeredAt:
          data.answeredAt.present ? data.answeredAt.value : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Answer(')
          ..write('submissionId: $submissionId, ')
          ..write('questionId: $questionId, ')
          ..write('specializationId: $specializationId, ')
          ..write('topicCode: $topicCode, ')
          ..write('selectedOptionsJson: $selectedOptionsJson, ')
          ..write('freeText: $freeText, ')
          ..write('selfAssessment: $selfAssessment, ')
          ..write('score: $score, ')
          ..write('quality: $quality, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      submissionId,
      questionId,
      specializationId,
      topicCode,
      selectedOptionsJson,
      freeText,
      selfAssessment,
      score,
      quality,
      answeredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Answer &&
          other.submissionId == this.submissionId &&
          other.questionId == this.questionId &&
          other.specializationId == this.specializationId &&
          other.topicCode == this.topicCode &&
          other.selectedOptionsJson == this.selectedOptionsJson &&
          other.freeText == this.freeText &&
          other.selfAssessment == this.selfAssessment &&
          other.score == this.score &&
          other.quality == this.quality &&
          other.answeredAt == this.answeredAt);
}

class AnswersCompanion extends UpdateCompanion<Answer> {
  final Value<String> submissionId;
  final Value<String> questionId;
  final Value<String> specializationId;
  final Value<String> topicCode;
  final Value<String> selectedOptionsJson;
  final Value<String?> freeText;
  final Value<int?> selfAssessment;
  final Value<double> score;
  final Value<int> quality;
  final Value<DateTime> answeredAt;
  final Value<int> rowid;
  const AnswersCompanion({
    this.submissionId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.specializationId = const Value.absent(),
    this.topicCode = const Value.absent(),
    this.selectedOptionsJson = const Value.absent(),
    this.freeText = const Value.absent(),
    this.selfAssessment = const Value.absent(),
    this.score = const Value.absent(),
    this.quality = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnswersCompanion.insert({
    required String submissionId,
    required String questionId,
    required String specializationId,
    required String topicCode,
    this.selectedOptionsJson = const Value.absent(),
    this.freeText = const Value.absent(),
    this.selfAssessment = const Value.absent(),
    required double score,
    required int quality,
    required DateTime answeredAt,
    this.rowid = const Value.absent(),
  })  : submissionId = Value(submissionId),
        questionId = Value(questionId),
        specializationId = Value(specializationId),
        topicCode = Value(topicCode),
        score = Value(score),
        quality = Value(quality),
        answeredAt = Value(answeredAt);
  static Insertable<Answer> custom({
    Expression<String>? submissionId,
    Expression<String>? questionId,
    Expression<String>? specializationId,
    Expression<String>? topicCode,
    Expression<String>? selectedOptionsJson,
    Expression<String>? freeText,
    Expression<int>? selfAssessment,
    Expression<double>? score,
    Expression<int>? quality,
    Expression<DateTime>? answeredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (submissionId != null) 'submission_id': submissionId,
      if (questionId != null) 'question_id': questionId,
      if (specializationId != null) 'specialization_id': specializationId,
      if (topicCode != null) 'topic_code': topicCode,
      if (selectedOptionsJson != null)
        'selected_options_json': selectedOptionsJson,
      if (freeText != null) 'free_text': freeText,
      if (selfAssessment != null) 'self_assessment': selfAssessment,
      if (score != null) 'score': score,
      if (quality != null) 'quality': quality,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnswersCompanion copyWith(
      {Value<String>? submissionId,
      Value<String>? questionId,
      Value<String>? specializationId,
      Value<String>? topicCode,
      Value<String>? selectedOptionsJson,
      Value<String?>? freeText,
      Value<int?>? selfAssessment,
      Value<double>? score,
      Value<int>? quality,
      Value<DateTime>? answeredAt,
      Value<int>? rowid}) {
    return AnswersCompanion(
      submissionId: submissionId ?? this.submissionId,
      questionId: questionId ?? this.questionId,
      specializationId: specializationId ?? this.specializationId,
      topicCode: topicCode ?? this.topicCode,
      selectedOptionsJson: selectedOptionsJson ?? this.selectedOptionsJson,
      freeText: freeText ?? this.freeText,
      selfAssessment: selfAssessment ?? this.selfAssessment,
      score: score ?? this.score,
      quality: quality ?? this.quality,
      answeredAt: answeredAt ?? this.answeredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (submissionId.present) {
      map['submission_id'] = Variable<String>(submissionId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (specializationId.present) {
      map['specialization_id'] = Variable<String>(specializationId.value);
    }
    if (topicCode.present) {
      map['topic_code'] = Variable<String>(topicCode.value);
    }
    if (selectedOptionsJson.present) {
      map['selected_options_json'] =
          Variable<String>(selectedOptionsJson.value);
    }
    if (freeText.present) {
      map['free_text'] = Variable<String>(freeText.value);
    }
    if (selfAssessment.present) {
      map['self_assessment'] = Variable<int>(selfAssessment.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (quality.present) {
      map['quality'] = Variable<int>(quality.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnswersCompanion(')
          ..write('submissionId: $submissionId, ')
          ..write('questionId: $questionId, ')
          ..write('specializationId: $specializationId, ')
          ..write('topicCode: $topicCode, ')
          ..write('selectedOptionsJson: $selectedOptionsJson, ')
          ..write('freeText: $freeText, ')
          ..write('selfAssessment: $selfAssessment, ')
          ..write('score: $score, ')
          ..write('quality: $quality, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TopicRatingsTable extends TopicRatings
    with TableInfo<$TopicRatingsTable, TopicRating> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TopicRatingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _specializationIdMeta =
      const VerificationMeta('specializationId');
  @override
  late final GeneratedColumn<String> specializationId = GeneratedColumn<String>(
      'specialization_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicCodeMeta =
      const VerificationMeta('topicCode');
  @override
  late final GeneratedColumn<String> topicCode = GeneratedColumn<String>(
      'topic_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
      'rating', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _answersCountMeta =
      const VerificationMeta('answersCount');
  @override
  late final GeneratedColumn<int> answersCount = GeneratedColumn<int>(
      'answers_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [specializationId, topicCode, rating, answersCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'topic_ratings';
  @override
  VerificationContext validateIntegrity(Insertable<TopicRating> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('specialization_id')) {
      context.handle(
          _specializationIdMeta,
          specializationId.isAcceptableOrUnknown(
              data['specialization_id']!, _specializationIdMeta));
    } else if (isInserting) {
      context.missing(_specializationIdMeta);
    }
    if (data.containsKey('topic_code')) {
      context.handle(_topicCodeMeta,
          topicCode.isAcceptableOrUnknown(data['topic_code']!, _topicCodeMeta));
    } else if (isInserting) {
      context.missing(_topicCodeMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('answers_count')) {
      context.handle(
          _answersCountMeta,
          answersCount.isAcceptableOrUnknown(
              data['answers_count']!, _answersCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {specializationId, topicCode};
  @override
  TopicRating map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TopicRating(
      specializationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}specialization_id'])!,
      topicCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_code'])!,
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rating'])!,
      answersCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}answers_count'])!,
    );
  }

  @override
  $TopicRatingsTable createAlias(String alias) {
    return $TopicRatingsTable(attachedDatabase, alias);
  }
}

class TopicRating extends DataClass implements Insertable<TopicRating> {
  final String specializationId;
  final String topicCode;
  final double rating;
  final int answersCount;
  const TopicRating(
      {required this.specializationId,
      required this.topicCode,
      required this.rating,
      required this.answersCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['specialization_id'] = Variable<String>(specializationId);
    map['topic_code'] = Variable<String>(topicCode);
    map['rating'] = Variable<double>(rating);
    map['answers_count'] = Variable<int>(answersCount);
    return map;
  }

  TopicRatingsCompanion toCompanion(bool nullToAbsent) {
    return TopicRatingsCompanion(
      specializationId: Value(specializationId),
      topicCode: Value(topicCode),
      rating: Value(rating),
      answersCount: Value(answersCount),
    );
  }

  factory TopicRating.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TopicRating(
      specializationId: serializer.fromJson<String>(json['specializationId']),
      topicCode: serializer.fromJson<String>(json['topicCode']),
      rating: serializer.fromJson<double>(json['rating']),
      answersCount: serializer.fromJson<int>(json['answersCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'specializationId': serializer.toJson<String>(specializationId),
      'topicCode': serializer.toJson<String>(topicCode),
      'rating': serializer.toJson<double>(rating),
      'answersCount': serializer.toJson<int>(answersCount),
    };
  }

  TopicRating copyWith(
          {String? specializationId,
          String? topicCode,
          double? rating,
          int? answersCount}) =>
      TopicRating(
        specializationId: specializationId ?? this.specializationId,
        topicCode: topicCode ?? this.topicCode,
        rating: rating ?? this.rating,
        answersCount: answersCount ?? this.answersCount,
      );
  TopicRating copyWithCompanion(TopicRatingsCompanion data) {
    return TopicRating(
      specializationId: data.specializationId.present
          ? data.specializationId.value
          : this.specializationId,
      topicCode: data.topicCode.present ? data.topicCode.value : this.topicCode,
      rating: data.rating.present ? data.rating.value : this.rating,
      answersCount: data.answersCount.present
          ? data.answersCount.value
          : this.answersCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TopicRating(')
          ..write('specializationId: $specializationId, ')
          ..write('topicCode: $topicCode, ')
          ..write('rating: $rating, ')
          ..write('answersCount: $answersCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(specializationId, topicCode, rating, answersCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TopicRating &&
          other.specializationId == this.specializationId &&
          other.topicCode == this.topicCode &&
          other.rating == this.rating &&
          other.answersCount == this.answersCount);
}

class TopicRatingsCompanion extends UpdateCompanion<TopicRating> {
  final Value<String> specializationId;
  final Value<String> topicCode;
  final Value<double> rating;
  final Value<int> answersCount;
  final Value<int> rowid;
  const TopicRatingsCompanion({
    this.specializationId = const Value.absent(),
    this.topicCode = const Value.absent(),
    this.rating = const Value.absent(),
    this.answersCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TopicRatingsCompanion.insert({
    required String specializationId,
    required String topicCode,
    required double rating,
    this.answersCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : specializationId = Value(specializationId),
        topicCode = Value(topicCode),
        rating = Value(rating);
  static Insertable<TopicRating> custom({
    Expression<String>? specializationId,
    Expression<String>? topicCode,
    Expression<double>? rating,
    Expression<int>? answersCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (specializationId != null) 'specialization_id': specializationId,
      if (topicCode != null) 'topic_code': topicCode,
      if (rating != null) 'rating': rating,
      if (answersCount != null) 'answers_count': answersCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TopicRatingsCompanion copyWith(
      {Value<String>? specializationId,
      Value<String>? topicCode,
      Value<double>? rating,
      Value<int>? answersCount,
      Value<int>? rowid}) {
    return TopicRatingsCompanion(
      specializationId: specializationId ?? this.specializationId,
      topicCode: topicCode ?? this.topicCode,
      rating: rating ?? this.rating,
      answersCount: answersCount ?? this.answersCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (specializationId.present) {
      map['specialization_id'] = Variable<String>(specializationId.value);
    }
    if (topicCode.present) {
      map['topic_code'] = Variable<String>(topicCode.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (answersCount.present) {
      map['answers_count'] = Variable<int>(answersCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TopicRatingsCompanion(')
          ..write('specializationId: $specializationId, ')
          ..write('topicCode: $topicCode, ')
          ..write('rating: $rating, ')
          ..write('answersCount: $answersCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewStatesTable extends ReviewStates
    with TableInfo<$ReviewStatesTable, ReviewState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
      'question_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _easinessFactorMeta =
      const VerificationMeta('easinessFactor');
  @override
  late final GeneratedColumn<double> easinessFactor = GeneratedColumn<double>(
      'easiness_factor', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _repetitionsMeta =
      const VerificationMeta('repetitions');
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
      'repetitions', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _intervalDaysMeta =
      const VerificationMeta('intervalDays');
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
      'interval_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
      'due_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastReviewedAtMeta =
      const VerificationMeta('lastReviewedAt');
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>('last_reviewed_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        questionId,
        easinessFactor,
        repetitions,
        intervalDays,
        dueAt,
        lastReviewedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_states';
  @override
  VerificationContext validateIntegrity(Insertable<ReviewState> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('easiness_factor')) {
      context.handle(
          _easinessFactorMeta,
          easinessFactor.isAcceptableOrUnknown(
              data['easiness_factor']!, _easinessFactorMeta));
    } else if (isInserting) {
      context.missing(_easinessFactorMeta);
    }
    if (data.containsKey('repetitions')) {
      context.handle(
          _repetitionsMeta,
          repetitions.isAcceptableOrUnknown(
              data['repetitions']!, _repetitionsMeta));
    } else if (isInserting) {
      context.missing(_repetitionsMeta);
    }
    if (data.containsKey('interval_days')) {
      context.handle(
          _intervalDaysMeta,
          intervalDays.isAcceptableOrUnknown(
              data['interval_days']!, _intervalDaysMeta));
    } else if (isInserting) {
      context.missing(_intervalDaysMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
          _dueAtMeta, dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta));
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
          _lastReviewedAtMeta,
          lastReviewedAt.isAcceptableOrUnknown(
              data['last_reviewed_at']!, _lastReviewedAtMeta));
    } else if (isInserting) {
      context.missing(_lastReviewedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId};
  @override
  ReviewState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewState(
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_id'])!,
      easinessFactor: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}easiness_factor'])!,
      repetitions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}repetitions'])!,
      intervalDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval_days'])!,
      dueAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_at'])!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_reviewed_at'])!,
    );
  }

  @override
  $ReviewStatesTable createAlias(String alias) {
    return $ReviewStatesTable(attachedDatabase, alias);
  }
}

class ReviewState extends DataClass implements Insertable<ReviewState> {
  final String questionId;
  final double easinessFactor;
  final int repetitions;
  final int intervalDays;
  final DateTime dueAt;
  final DateTime lastReviewedAt;
  const ReviewState(
      {required this.questionId,
      required this.easinessFactor,
      required this.repetitions,
      required this.intervalDays,
      required this.dueAt,
      required this.lastReviewedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<String>(questionId);
    map['easiness_factor'] = Variable<double>(easinessFactor);
    map['repetitions'] = Variable<int>(repetitions);
    map['interval_days'] = Variable<int>(intervalDays);
    map['due_at'] = Variable<DateTime>(dueAt);
    map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    return map;
  }

  ReviewStatesCompanion toCompanion(bool nullToAbsent) {
    return ReviewStatesCompanion(
      questionId: Value(questionId),
      easinessFactor: Value(easinessFactor),
      repetitions: Value(repetitions),
      intervalDays: Value(intervalDays),
      dueAt: Value(dueAt),
      lastReviewedAt: Value(lastReviewedAt),
    );
  }

  factory ReviewState.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewState(
      questionId: serializer.fromJson<String>(json['questionId']),
      easinessFactor: serializer.fromJson<double>(json['easinessFactor']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      lastReviewedAt: serializer.fromJson<DateTime>(json['lastReviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<String>(questionId),
      'easinessFactor': serializer.toJson<double>(easinessFactor),
      'repetitions': serializer.toJson<int>(repetitions),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'lastReviewedAt': serializer.toJson<DateTime>(lastReviewedAt),
    };
  }

  ReviewState copyWith(
          {String? questionId,
          double? easinessFactor,
          int? repetitions,
          int? intervalDays,
          DateTime? dueAt,
          DateTime? lastReviewedAt}) =>
      ReviewState(
        questionId: questionId ?? this.questionId,
        easinessFactor: easinessFactor ?? this.easinessFactor,
        repetitions: repetitions ?? this.repetitions,
        intervalDays: intervalDays ?? this.intervalDays,
        dueAt: dueAt ?? this.dueAt,
        lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      );
  ReviewState copyWithCompanion(ReviewStatesCompanion data) {
    return ReviewState(
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      easinessFactor: data.easinessFactor.present
          ? data.easinessFactor.value
          : this.easinessFactor,
      repetitions:
          data.repetitions.present ? data.repetitions.value : this.repetitions,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewState(')
          ..write('questionId: $questionId, ')
          ..write('easinessFactor: $easinessFactor, ')
          ..write('repetitions: $repetitions, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(questionId, easinessFactor, repetitions,
      intervalDays, dueAt, lastReviewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewState &&
          other.questionId == this.questionId &&
          other.easinessFactor == this.easinessFactor &&
          other.repetitions == this.repetitions &&
          other.intervalDays == this.intervalDays &&
          other.dueAt == this.dueAt &&
          other.lastReviewedAt == this.lastReviewedAt);
}

class ReviewStatesCompanion extends UpdateCompanion<ReviewState> {
  final Value<String> questionId;
  final Value<double> easinessFactor;
  final Value<int> repetitions;
  final Value<int> intervalDays;
  final Value<DateTime> dueAt;
  final Value<DateTime> lastReviewedAt;
  final Value<int> rowid;
  const ReviewStatesCompanion({
    this.questionId = const Value.absent(),
    this.easinessFactor = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewStatesCompanion.insert({
    required String questionId,
    required double easinessFactor,
    required int repetitions,
    required int intervalDays,
    required DateTime dueAt,
    required DateTime lastReviewedAt,
    this.rowid = const Value.absent(),
  })  : questionId = Value(questionId),
        easinessFactor = Value(easinessFactor),
        repetitions = Value(repetitions),
        intervalDays = Value(intervalDays),
        dueAt = Value(dueAt),
        lastReviewedAt = Value(lastReviewedAt);
  static Insertable<ReviewState> custom({
    Expression<String>? questionId,
    Expression<double>? easinessFactor,
    Expression<int>? repetitions,
    Expression<int>? intervalDays,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? lastReviewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (easinessFactor != null) 'easiness_factor': easinessFactor,
      if (repetitions != null) 'repetitions': repetitions,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (dueAt != null) 'due_at': dueAt,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewStatesCompanion copyWith(
      {Value<String>? questionId,
      Value<double>? easinessFactor,
      Value<int>? repetitions,
      Value<int>? intervalDays,
      Value<DateTime>? dueAt,
      Value<DateTime>? lastReviewedAt,
      Value<int>? rowid}) {
    return ReviewStatesCompanion(
      questionId: questionId ?? this.questionId,
      easinessFactor: easinessFactor ?? this.easinessFactor,
      repetitions: repetitions ?? this.repetitions,
      intervalDays: intervalDays ?? this.intervalDays,
      dueAt: dueAt ?? this.dueAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (easinessFactor.present) {
      map['easiness_factor'] = Variable<double>(easinessFactor.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewStatesCompanion(')
          ..write('questionId: $questionId, ')
          ..write('easinessFactor: $easinessFactor, ')
          ..write('repetitions: $repetitions, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudyPlansTable extends StudyPlans
    with TableInfo<$StudyPlansTable, StudyPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _specializationIdMeta =
      const VerificationMeta('specializationId');
  @override
  late final GeneratedColumn<String> specializationId = GeneratedColumn<String>(
      'specialization_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _interviewDateMeta =
      const VerificationMeta('interviewDate');
  @override
  late final GeneratedColumn<DateTime> interviewDate =
      GeneratedColumn<DateTime>('interview_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _targetGradeMeta =
      const VerificationMeta('targetGrade');
  @override
  late final GeneratedColumn<int> targetGrade = GeneratedColumn<int>(
      'target_grade', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dailyCapacityMeta =
      const VerificationMeta('dailyCapacity');
  @override
  late final GeneratedColumn<int> dailyCapacity = GeneratedColumn<int>(
      'daily_capacity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        specializationId,
        interviewDate,
        targetGrade,
        dailyCapacity,
        isActive,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_plans';
  @override
  VerificationContext validateIntegrity(Insertable<StudyPlan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('specialization_id')) {
      context.handle(
          _specializationIdMeta,
          specializationId.isAcceptableOrUnknown(
              data['specialization_id']!, _specializationIdMeta));
    } else if (isInserting) {
      context.missing(_specializationIdMeta);
    }
    if (data.containsKey('interview_date')) {
      context.handle(
          _interviewDateMeta,
          interviewDate.isAcceptableOrUnknown(
              data['interview_date']!, _interviewDateMeta));
    } else if (isInserting) {
      context.missing(_interviewDateMeta);
    }
    if (data.containsKey('target_grade')) {
      context.handle(
          _targetGradeMeta,
          targetGrade.isAcceptableOrUnknown(
              data['target_grade']!, _targetGradeMeta));
    } else if (isInserting) {
      context.missing(_targetGradeMeta);
    }
    if (data.containsKey('daily_capacity')) {
      context.handle(
          _dailyCapacityMeta,
          dailyCapacity.isAcceptableOrUnknown(
              data['daily_capacity']!, _dailyCapacityMeta));
    } else if (isInserting) {
      context.missing(_dailyCapacityMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudyPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyPlan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      specializationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}specialization_id'])!,
      interviewDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}interview_date'])!,
      targetGrade: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_grade'])!,
      dailyCapacity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}daily_capacity'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $StudyPlansTable createAlias(String alias) {
    return $StudyPlansTable(attachedDatabase, alias);
  }
}

class StudyPlan extends DataClass implements Insertable<StudyPlan> {
  final int id;
  final String specializationId;
  final DateTime interviewDate;
  final int targetGrade;
  final int dailyCapacity;
  final bool isActive;
  final DateTime createdAt;
  const StudyPlan(
      {required this.id,
      required this.specializationId,
      required this.interviewDate,
      required this.targetGrade,
      required this.dailyCapacity,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['specialization_id'] = Variable<String>(specializationId);
    map['interview_date'] = Variable<DateTime>(interviewDate);
    map['target_grade'] = Variable<int>(targetGrade);
    map['daily_capacity'] = Variable<int>(dailyCapacity);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StudyPlansCompanion toCompanion(bool nullToAbsent) {
    return StudyPlansCompanion(
      id: Value(id),
      specializationId: Value(specializationId),
      interviewDate: Value(interviewDate),
      targetGrade: Value(targetGrade),
      dailyCapacity: Value(dailyCapacity),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory StudyPlan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyPlan(
      id: serializer.fromJson<int>(json['id']),
      specializationId: serializer.fromJson<String>(json['specializationId']),
      interviewDate: serializer.fromJson<DateTime>(json['interviewDate']),
      targetGrade: serializer.fromJson<int>(json['targetGrade']),
      dailyCapacity: serializer.fromJson<int>(json['dailyCapacity']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'specializationId': serializer.toJson<String>(specializationId),
      'interviewDate': serializer.toJson<DateTime>(interviewDate),
      'targetGrade': serializer.toJson<int>(targetGrade),
      'dailyCapacity': serializer.toJson<int>(dailyCapacity),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StudyPlan copyWith(
          {int? id,
          String? specializationId,
          DateTime? interviewDate,
          int? targetGrade,
          int? dailyCapacity,
          bool? isActive,
          DateTime? createdAt}) =>
      StudyPlan(
        id: id ?? this.id,
        specializationId: specializationId ?? this.specializationId,
        interviewDate: interviewDate ?? this.interviewDate,
        targetGrade: targetGrade ?? this.targetGrade,
        dailyCapacity: dailyCapacity ?? this.dailyCapacity,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  StudyPlan copyWithCompanion(StudyPlansCompanion data) {
    return StudyPlan(
      id: data.id.present ? data.id.value : this.id,
      specializationId: data.specializationId.present
          ? data.specializationId.value
          : this.specializationId,
      interviewDate: data.interviewDate.present
          ? data.interviewDate.value
          : this.interviewDate,
      targetGrade:
          data.targetGrade.present ? data.targetGrade.value : this.targetGrade,
      dailyCapacity: data.dailyCapacity.present
          ? data.dailyCapacity.value
          : this.dailyCapacity,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyPlan(')
          ..write('id: $id, ')
          ..write('specializationId: $specializationId, ')
          ..write('interviewDate: $interviewDate, ')
          ..write('targetGrade: $targetGrade, ')
          ..write('dailyCapacity: $dailyCapacity, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, specializationId, interviewDate,
      targetGrade, dailyCapacity, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyPlan &&
          other.id == this.id &&
          other.specializationId == this.specializationId &&
          other.interviewDate == this.interviewDate &&
          other.targetGrade == this.targetGrade &&
          other.dailyCapacity == this.dailyCapacity &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class StudyPlansCompanion extends UpdateCompanion<StudyPlan> {
  final Value<int> id;
  final Value<String> specializationId;
  final Value<DateTime> interviewDate;
  final Value<int> targetGrade;
  final Value<int> dailyCapacity;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const StudyPlansCompanion({
    this.id = const Value.absent(),
    this.specializationId = const Value.absent(),
    this.interviewDate = const Value.absent(),
    this.targetGrade = const Value.absent(),
    this.dailyCapacity = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  StudyPlansCompanion.insert({
    this.id = const Value.absent(),
    required String specializationId,
    required DateTime interviewDate,
    required int targetGrade,
    required int dailyCapacity,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
  })  : specializationId = Value(specializationId),
        interviewDate = Value(interviewDate),
        targetGrade = Value(targetGrade),
        dailyCapacity = Value(dailyCapacity),
        createdAt = Value(createdAt);
  static Insertable<StudyPlan> custom({
    Expression<int>? id,
    Expression<String>? specializationId,
    Expression<DateTime>? interviewDate,
    Expression<int>? targetGrade,
    Expression<int>? dailyCapacity,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (specializationId != null) 'specialization_id': specializationId,
      if (interviewDate != null) 'interview_date': interviewDate,
      if (targetGrade != null) 'target_grade': targetGrade,
      if (dailyCapacity != null) 'daily_capacity': dailyCapacity,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  StudyPlansCompanion copyWith(
      {Value<int>? id,
      Value<String>? specializationId,
      Value<DateTime>? interviewDate,
      Value<int>? targetGrade,
      Value<int>? dailyCapacity,
      Value<bool>? isActive,
      Value<DateTime>? createdAt}) {
    return StudyPlansCompanion(
      id: id ?? this.id,
      specializationId: specializationId ?? this.specializationId,
      interviewDate: interviewDate ?? this.interviewDate,
      targetGrade: targetGrade ?? this.targetGrade,
      dailyCapacity: dailyCapacity ?? this.dailyCapacity,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (specializationId.present) {
      map['specialization_id'] = Variable<String>(specializationId.value);
    }
    if (interviewDate.present) {
      map['interview_date'] = Variable<DateTime>(interviewDate.value);
    }
    if (targetGrade.present) {
      map['target_grade'] = Variable<int>(targetGrade.value);
    }
    if (dailyCapacity.present) {
      map['daily_capacity'] = Variable<int>(dailyCapacity.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyPlansCompanion(')
          ..write('id: $id, ')
          ..write('specializationId: $specializationId, ')
          ..write('interviewDate: $interviewDate, ')
          ..write('targetGrade: $targetGrade, ')
          ..write('dailyCapacity: $dailyCapacity, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StudyPlanDaysTable extends StudyPlanDays
    with TableInfo<$StudyPlanDaysTable, StudyPlanDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyPlanDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
      'plan_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dayIndexMeta =
      const VerificationMeta('dayIndex');
  @override
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>(
      'day_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
      'day', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _topicCodesMeta =
      const VerificationMeta('topicCodes');
  @override
  late final GeneratedColumn<String> topicCodes = GeneratedColumn<String>(
      'topic_codes', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _newQuestionsMeta =
      const VerificationMeta('newQuestions');
  @override
  late final GeneratedColumn<int> newQuestions = GeneratedColumn<int>(
      'new_questions', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reviewOnlyMeta =
      const VerificationMeta('reviewOnly');
  @override
  late final GeneratedColumn<bool> reviewOnly = GeneratedColumn<bool>(
      'review_only', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("review_only" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [planId, dayIndex, day, topicCodes, newQuestions, reviewOnly];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_plan_days';
  @override
  VerificationContext validateIntegrity(Insertable<StudyPlanDay> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plan_id')) {
      context.handle(_planIdMeta,
          planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta));
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('day_index')) {
      context.handle(_dayIndexMeta,
          dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta));
    } else if (isInserting) {
      context.missing(_dayIndexMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('topic_codes')) {
      context.handle(
          _topicCodesMeta,
          topicCodes.isAcceptableOrUnknown(
              data['topic_codes']!, _topicCodesMeta));
    } else if (isInserting) {
      context.missing(_topicCodesMeta);
    }
    if (data.containsKey('new_questions')) {
      context.handle(
          _newQuestionsMeta,
          newQuestions.isAcceptableOrUnknown(
              data['new_questions']!, _newQuestionsMeta));
    } else if (isInserting) {
      context.missing(_newQuestionsMeta);
    }
    if (data.containsKey('review_only')) {
      context.handle(
          _reviewOnlyMeta,
          reviewOnly.isAcceptableOrUnknown(
              data['review_only']!, _reviewOnlyMeta));
    } else if (isInserting) {
      context.missing(_reviewOnlyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {planId, dayIndex};
  @override
  StudyPlanDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyPlanDay(
      planId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}plan_id'])!,
      dayIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_index'])!,
      day: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}day'])!,
      topicCodes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_codes'])!,
      newQuestions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}new_questions'])!,
      reviewOnly: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}review_only'])!,
    );
  }

  @override
  $StudyPlanDaysTable createAlias(String alias) {
    return $StudyPlanDaysTable(attachedDatabase, alias);
  }
}

class StudyPlanDay extends DataClass implements Insertable<StudyPlanDay> {
  final int planId;
  final int dayIndex;
  final DateTime day;

  /// Коды разделов на день, через запятую. Отдельная таблица ради трёх
  /// значений на строку не окупается.
  final String topicCodes;
  final int newQuestions;
  final bool reviewOnly;
  const StudyPlanDay(
      {required this.planId,
      required this.dayIndex,
      required this.day,
      required this.topicCodes,
      required this.newQuestions,
      required this.reviewOnly});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plan_id'] = Variable<int>(planId);
    map['day_index'] = Variable<int>(dayIndex);
    map['day'] = Variable<DateTime>(day);
    map['topic_codes'] = Variable<String>(topicCodes);
    map['new_questions'] = Variable<int>(newQuestions);
    map['review_only'] = Variable<bool>(reviewOnly);
    return map;
  }

  StudyPlanDaysCompanion toCompanion(bool nullToAbsent) {
    return StudyPlanDaysCompanion(
      planId: Value(planId),
      dayIndex: Value(dayIndex),
      day: Value(day),
      topicCodes: Value(topicCodes),
      newQuestions: Value(newQuestions),
      reviewOnly: Value(reviewOnly),
    );
  }

  factory StudyPlanDay.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyPlanDay(
      planId: serializer.fromJson<int>(json['planId']),
      dayIndex: serializer.fromJson<int>(json['dayIndex']),
      day: serializer.fromJson<DateTime>(json['day']),
      topicCodes: serializer.fromJson<String>(json['topicCodes']),
      newQuestions: serializer.fromJson<int>(json['newQuestions']),
      reviewOnly: serializer.fromJson<bool>(json['reviewOnly']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'planId': serializer.toJson<int>(planId),
      'dayIndex': serializer.toJson<int>(dayIndex),
      'day': serializer.toJson<DateTime>(day),
      'topicCodes': serializer.toJson<String>(topicCodes),
      'newQuestions': serializer.toJson<int>(newQuestions),
      'reviewOnly': serializer.toJson<bool>(reviewOnly),
    };
  }

  StudyPlanDay copyWith(
          {int? planId,
          int? dayIndex,
          DateTime? day,
          String? topicCodes,
          int? newQuestions,
          bool? reviewOnly}) =>
      StudyPlanDay(
        planId: planId ?? this.planId,
        dayIndex: dayIndex ?? this.dayIndex,
        day: day ?? this.day,
        topicCodes: topicCodes ?? this.topicCodes,
        newQuestions: newQuestions ?? this.newQuestions,
        reviewOnly: reviewOnly ?? this.reviewOnly,
      );
  StudyPlanDay copyWithCompanion(StudyPlanDaysCompanion data) {
    return StudyPlanDay(
      planId: data.planId.present ? data.planId.value : this.planId,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      day: data.day.present ? data.day.value : this.day,
      topicCodes:
          data.topicCodes.present ? data.topicCodes.value : this.topicCodes,
      newQuestions: data.newQuestions.present
          ? data.newQuestions.value
          : this.newQuestions,
      reviewOnly:
          data.reviewOnly.present ? data.reviewOnly.value : this.reviewOnly,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyPlanDay(')
          ..write('planId: $planId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('day: $day, ')
          ..write('topicCodes: $topicCodes, ')
          ..write('newQuestions: $newQuestions, ')
          ..write('reviewOnly: $reviewOnly')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(planId, dayIndex, day, topicCodes, newQuestions, reviewOnly);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyPlanDay &&
          other.planId == this.planId &&
          other.dayIndex == this.dayIndex &&
          other.day == this.day &&
          other.topicCodes == this.topicCodes &&
          other.newQuestions == this.newQuestions &&
          other.reviewOnly == this.reviewOnly);
}

class StudyPlanDaysCompanion extends UpdateCompanion<StudyPlanDay> {
  final Value<int> planId;
  final Value<int> dayIndex;
  final Value<DateTime> day;
  final Value<String> topicCodes;
  final Value<int> newQuestions;
  final Value<bool> reviewOnly;
  final Value<int> rowid;
  const StudyPlanDaysCompanion({
    this.planId = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.day = const Value.absent(),
    this.topicCodes = const Value.absent(),
    this.newQuestions = const Value.absent(),
    this.reviewOnly = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyPlanDaysCompanion.insert({
    required int planId,
    required int dayIndex,
    required DateTime day,
    required String topicCodes,
    required int newQuestions,
    required bool reviewOnly,
    this.rowid = const Value.absent(),
  })  : planId = Value(planId),
        dayIndex = Value(dayIndex),
        day = Value(day),
        topicCodes = Value(topicCodes),
        newQuestions = Value(newQuestions),
        reviewOnly = Value(reviewOnly);
  static Insertable<StudyPlanDay> custom({
    Expression<int>? planId,
    Expression<int>? dayIndex,
    Expression<DateTime>? day,
    Expression<String>? topicCodes,
    Expression<int>? newQuestions,
    Expression<bool>? reviewOnly,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (planId != null) 'plan_id': planId,
      if (dayIndex != null) 'day_index': dayIndex,
      if (day != null) 'day': day,
      if (topicCodes != null) 'topic_codes': topicCodes,
      if (newQuestions != null) 'new_questions': newQuestions,
      if (reviewOnly != null) 'review_only': reviewOnly,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyPlanDaysCompanion copyWith(
      {Value<int>? planId,
      Value<int>? dayIndex,
      Value<DateTime>? day,
      Value<String>? topicCodes,
      Value<int>? newQuestions,
      Value<bool>? reviewOnly,
      Value<int>? rowid}) {
    return StudyPlanDaysCompanion(
      planId: planId ?? this.planId,
      dayIndex: dayIndex ?? this.dayIndex,
      day: day ?? this.day,
      topicCodes: topicCodes ?? this.topicCodes,
      newQuestions: newQuestions ?? this.newQuestions,
      reviewOnly: reviewOnly ?? this.reviewOnly,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (topicCodes.present) {
      map['topic_codes'] = Variable<String>(topicCodes.value);
    }
    if (newQuestions.present) {
      map['new_questions'] = Variable<int>(newQuestions.value);
    }
    if (reviewOnly.present) {
      map['review_only'] = Variable<bool>(reviewOnly.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyPlanDaysCompanion(')
          ..write('planId: $planId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('day: $day, ')
          ..write('topicCodes: $topicCodes, ')
          ..write('newQuestions: $newQuestions, ')
          ..write('reviewOnly: $reviewOnly, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $AnswersTable answers = $AnswersTable(this);
  late final $TopicRatingsTable topicRatings = $TopicRatingsTable(this);
  late final $ReviewStatesTable reviewStates = $ReviewStatesTable(this);
  late final $StudyPlansTable studyPlans = $StudyPlansTable(this);
  late final $StudyPlanDaysTable studyPlanDays = $StudyPlanDaysTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        profiles,
        answers,
        topicRatings,
        reviewStates,
        studyPlans,
        studyPlanDays
      ];
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  required String specializationId,
  required int targetGrade,
  Value<bool> isPrimary,
  Value<int> answersCount,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<String> specializationId,
  Value<int> targetGrade,
  Value<bool> isPrimary,
  Value<int> answersCount,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get specializationId => $composableBuilder(
      column: $table.specializationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetGrade => $composableBuilder(
      column: $table.targetGrade, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get answersCount => $composableBuilder(
      column: $table.answersCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get specializationId => $composableBuilder(
      column: $table.specializationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetGrade => $composableBuilder(
      column: $table.targetGrade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get answersCount => $composableBuilder(
      column: $table.answersCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get specializationId => $composableBuilder(
      column: $table.specializationId, builder: (column) => column);

  GeneratedColumn<int> get targetGrade => $composableBuilder(
      column: $table.targetGrade, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<int> get answersCount => $composableBuilder(
      column: $table.answersCount, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProfilesTable,
    Profile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableAnnotationComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
    Profile,
    PrefetchHooks Function()> {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> specializationId = const Value.absent(),
            Value<int> targetGrade = const Value.absent(),
            Value<bool> isPrimary = const Value.absent(),
            Value<int> answersCount = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfilesCompanion(
            specializationId: specializationId,
            targetGrade: targetGrade,
            isPrimary: isPrimary,
            answersCount: answersCount,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String specializationId,
            required int targetGrade,
            Value<bool> isPrimary = const Value.absent(),
            Value<int> answersCount = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfilesCompanion.insert(
            specializationId: specializationId,
            targetGrade: targetGrade,
            isPrimary: isPrimary,
            answersCount: answersCount,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProfilesTable,
    Profile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableAnnotationComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
    Profile,
    PrefetchHooks Function()>;
typedef $$AnswersTableCreateCompanionBuilder = AnswersCompanion Function({
  required String submissionId,
  required String questionId,
  required String specializationId,
  required String topicCode,
  Value<String> selectedOptionsJson,
  Value<String?> freeText,
  Value<int?> selfAssessment,
  required double score,
  required int quality,
  required DateTime answeredAt,
  Value<int> rowid,
});
typedef $$AnswersTableUpdateCompanionBuilder = AnswersCompanion Function({
  Value<String> submissionId,
  Value<String> questionId,
  Value<String> specializationId,
  Value<String> topicCode,
  Value<String> selectedOptionsJson,
  Value<String?> freeText,
  Value<int?> selfAssessment,
  Value<double> score,
  Value<int> quality,
  Value<DateTime> answeredAt,
  Value<int> rowid,
});

class $$AnswersTableFilterComposer
    extends Composer<_$AppDatabase, $AnswersTable> {
  $$AnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get submissionId => $composableBuilder(
      column: $table.submissionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specializationId => $composableBuilder(
      column: $table.specializationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicCode => $composableBuilder(
      column: $table.topicCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get selectedOptionsJson => $composableBuilder(
      column: $table.selectedOptionsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get freeText => $composableBuilder(
      column: $table.freeText, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get selfAssessment => $composableBuilder(
      column: $table.selfAssessment,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quality => $composableBuilder(
      column: $table.quality, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
      column: $table.answeredAt, builder: (column) => ColumnFilters(column));
}

class $$AnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $AnswersTable> {
  $$AnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get submissionId => $composableBuilder(
      column: $table.submissionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specializationId => $composableBuilder(
      column: $table.specializationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicCode => $composableBuilder(
      column: $table.topicCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get selectedOptionsJson => $composableBuilder(
      column: $table.selectedOptionsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get freeText => $composableBuilder(
      column: $table.freeText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get selfAssessment => $composableBuilder(
      column: $table.selfAssessment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quality => $composableBuilder(
      column: $table.quality, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
      column: $table.answeredAt, builder: (column) => ColumnOrderings(column));
}

class $$AnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnswersTable> {
  $$AnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get submissionId => $composableBuilder(
      column: $table.submissionId, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => column);

  GeneratedColumn<String> get specializationId => $composableBuilder(
      column: $table.specializationId, builder: (column) => column);

  GeneratedColumn<String> get topicCode =>
      $composableBuilder(column: $table.topicCode, builder: (column) => column);

  GeneratedColumn<String> get selectedOptionsJson => $composableBuilder(
      column: $table.selectedOptionsJson, builder: (column) => column);

  GeneratedColumn<String> get freeText =>
      $composableBuilder(column: $table.freeText, builder: (column) => column);

  GeneratedColumn<int> get selfAssessment => $composableBuilder(
      column: $table.selfAssessment, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
      column: $table.answeredAt, builder: (column) => column);
}

class $$AnswersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnswersTable,
    Answer,
    $$AnswersTableFilterComposer,
    $$AnswersTableOrderingComposer,
    $$AnswersTableAnnotationComposer,
    $$AnswersTableCreateCompanionBuilder,
    $$AnswersTableUpdateCompanionBuilder,
    (Answer, BaseReferences<_$AppDatabase, $AnswersTable, Answer>),
    Answer,
    PrefetchHooks Function()> {
  $$AnswersTableTableManager(_$AppDatabase db, $AnswersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> submissionId = const Value.absent(),
            Value<String> questionId = const Value.absent(),
            Value<String> specializationId = const Value.absent(),
            Value<String> topicCode = const Value.absent(),
            Value<String> selectedOptionsJson = const Value.absent(),
            Value<String?> freeText = const Value.absent(),
            Value<int?> selfAssessment = const Value.absent(),
            Value<double> score = const Value.absent(),
            Value<int> quality = const Value.absent(),
            Value<DateTime> answeredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnswersCompanion(
            submissionId: submissionId,
            questionId: questionId,
            specializationId: specializationId,
            topicCode: topicCode,
            selectedOptionsJson: selectedOptionsJson,
            freeText: freeText,
            selfAssessment: selfAssessment,
            score: score,
            quality: quality,
            answeredAt: answeredAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String submissionId,
            required String questionId,
            required String specializationId,
            required String topicCode,
            Value<String> selectedOptionsJson = const Value.absent(),
            Value<String?> freeText = const Value.absent(),
            Value<int?> selfAssessment = const Value.absent(),
            required double score,
            required int quality,
            required DateTime answeredAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AnswersCompanion.insert(
            submissionId: submissionId,
            questionId: questionId,
            specializationId: specializationId,
            topicCode: topicCode,
            selectedOptionsJson: selectedOptionsJson,
            freeText: freeText,
            selfAssessment: selfAssessment,
            score: score,
            quality: quality,
            answeredAt: answeredAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AnswersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AnswersTable,
    Answer,
    $$AnswersTableFilterComposer,
    $$AnswersTableOrderingComposer,
    $$AnswersTableAnnotationComposer,
    $$AnswersTableCreateCompanionBuilder,
    $$AnswersTableUpdateCompanionBuilder,
    (Answer, BaseReferences<_$AppDatabase, $AnswersTable, Answer>),
    Answer,
    PrefetchHooks Function()>;
typedef $$TopicRatingsTableCreateCompanionBuilder = TopicRatingsCompanion
    Function({
  required String specializationId,
  required String topicCode,
  required double rating,
  Value<int> answersCount,
  Value<int> rowid,
});
typedef $$TopicRatingsTableUpdateCompanionBuilder = TopicRatingsCompanion
    Function({
  Value<String> specializationId,
  Value<String> topicCode,
  Value<double> rating,
  Value<int> answersCount,
  Value<int> rowid,
});

class $$TopicRatingsTableFilterComposer
    extends Composer<_$AppDatabase, $TopicRatingsTable> {
  $$TopicRatingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get specializationId => $composableBuilder(
      column: $table.specializationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicCode => $composableBuilder(
      column: $table.topicCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get answersCount => $composableBuilder(
      column: $table.answersCount, builder: (column) => ColumnFilters(column));
}

class $$TopicRatingsTableOrderingComposer
    extends Composer<_$AppDatabase, $TopicRatingsTable> {
  $$TopicRatingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get specializationId => $composableBuilder(
      column: $table.specializationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicCode => $composableBuilder(
      column: $table.topicCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get answersCount => $composableBuilder(
      column: $table.answersCount,
      builder: (column) => ColumnOrderings(column));
}

class $$TopicRatingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TopicRatingsTable> {
  $$TopicRatingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get specializationId => $composableBuilder(
      column: $table.specializationId, builder: (column) => column);

  GeneratedColumn<String> get topicCode =>
      $composableBuilder(column: $table.topicCode, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get answersCount => $composableBuilder(
      column: $table.answersCount, builder: (column) => column);
}

class $$TopicRatingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TopicRatingsTable,
    TopicRating,
    $$TopicRatingsTableFilterComposer,
    $$TopicRatingsTableOrderingComposer,
    $$TopicRatingsTableAnnotationComposer,
    $$TopicRatingsTableCreateCompanionBuilder,
    $$TopicRatingsTableUpdateCompanionBuilder,
    (
      TopicRating,
      BaseReferences<_$AppDatabase, $TopicRatingsTable, TopicRating>
    ),
    TopicRating,
    PrefetchHooks Function()> {
  $$TopicRatingsTableTableManager(_$AppDatabase db, $TopicRatingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TopicRatingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TopicRatingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TopicRatingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> specializationId = const Value.absent(),
            Value<String> topicCode = const Value.absent(),
            Value<double> rating = const Value.absent(),
            Value<int> answersCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TopicRatingsCompanion(
            specializationId: specializationId,
            topicCode: topicCode,
            rating: rating,
            answersCount: answersCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String specializationId,
            required String topicCode,
            required double rating,
            Value<int> answersCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TopicRatingsCompanion.insert(
            specializationId: specializationId,
            topicCode: topicCode,
            rating: rating,
            answersCount: answersCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TopicRatingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TopicRatingsTable,
    TopicRating,
    $$TopicRatingsTableFilterComposer,
    $$TopicRatingsTableOrderingComposer,
    $$TopicRatingsTableAnnotationComposer,
    $$TopicRatingsTableCreateCompanionBuilder,
    $$TopicRatingsTableUpdateCompanionBuilder,
    (
      TopicRating,
      BaseReferences<_$AppDatabase, $TopicRatingsTable, TopicRating>
    ),
    TopicRating,
    PrefetchHooks Function()>;
typedef $$ReviewStatesTableCreateCompanionBuilder = ReviewStatesCompanion
    Function({
  required String questionId,
  required double easinessFactor,
  required int repetitions,
  required int intervalDays,
  required DateTime dueAt,
  required DateTime lastReviewedAt,
  Value<int> rowid,
});
typedef $$ReviewStatesTableUpdateCompanionBuilder = ReviewStatesCompanion
    Function({
  Value<String> questionId,
  Value<double> easinessFactor,
  Value<int> repetitions,
  Value<int> intervalDays,
  Value<DateTime> dueAt,
  Value<DateTime> lastReviewedAt,
  Value<int> rowid,
});

class $$ReviewStatesTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewStatesTable> {
  $$ReviewStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get easinessFactor => $composableBuilder(
      column: $table.easinessFactor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get intervalDays => $composableBuilder(
      column: $table.intervalDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
      column: $table.lastReviewedAt,
      builder: (column) => ColumnFilters(column));
}

class $$ReviewStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewStatesTable> {
  $$ReviewStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get easinessFactor => $composableBuilder(
      column: $table.easinessFactor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get intervalDays => $composableBuilder(
      column: $table.intervalDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
      column: $table.lastReviewedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ReviewStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewStatesTable> {
  $$ReviewStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => column);

  GeneratedColumn<double> get easinessFactor => $composableBuilder(
      column: $table.easinessFactor, builder: (column) => column);

  GeneratedColumn<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
      column: $table.intervalDays, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
      column: $table.lastReviewedAt, builder: (column) => column);
}

class $$ReviewStatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReviewStatesTable,
    ReviewState,
    $$ReviewStatesTableFilterComposer,
    $$ReviewStatesTableOrderingComposer,
    $$ReviewStatesTableAnnotationComposer,
    $$ReviewStatesTableCreateCompanionBuilder,
    $$ReviewStatesTableUpdateCompanionBuilder,
    (
      ReviewState,
      BaseReferences<_$AppDatabase, $ReviewStatesTable, ReviewState>
    ),
    ReviewState,
    PrefetchHooks Function()> {
  $$ReviewStatesTableTableManager(_$AppDatabase db, $ReviewStatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> questionId = const Value.absent(),
            Value<double> easinessFactor = const Value.absent(),
            Value<int> repetitions = const Value.absent(),
            Value<int> intervalDays = const Value.absent(),
            Value<DateTime> dueAt = const Value.absent(),
            Value<DateTime> lastReviewedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewStatesCompanion(
            questionId: questionId,
            easinessFactor: easinessFactor,
            repetitions: repetitions,
            intervalDays: intervalDays,
            dueAt: dueAt,
            lastReviewedAt: lastReviewedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String questionId,
            required double easinessFactor,
            required int repetitions,
            required int intervalDays,
            required DateTime dueAt,
            required DateTime lastReviewedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewStatesCompanion.insert(
            questionId: questionId,
            easinessFactor: easinessFactor,
            repetitions: repetitions,
            intervalDays: intervalDays,
            dueAt: dueAt,
            lastReviewedAt: lastReviewedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReviewStatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReviewStatesTable,
    ReviewState,
    $$ReviewStatesTableFilterComposer,
    $$ReviewStatesTableOrderingComposer,
    $$ReviewStatesTableAnnotationComposer,
    $$ReviewStatesTableCreateCompanionBuilder,
    $$ReviewStatesTableUpdateCompanionBuilder,
    (
      ReviewState,
      BaseReferences<_$AppDatabase, $ReviewStatesTable, ReviewState>
    ),
    ReviewState,
    PrefetchHooks Function()>;
typedef $$StudyPlansTableCreateCompanionBuilder = StudyPlansCompanion Function({
  Value<int> id,
  required String specializationId,
  required DateTime interviewDate,
  required int targetGrade,
  required int dailyCapacity,
  Value<bool> isActive,
  required DateTime createdAt,
});
typedef $$StudyPlansTableUpdateCompanionBuilder = StudyPlansCompanion Function({
  Value<int> id,
  Value<String> specializationId,
  Value<DateTime> interviewDate,
  Value<int> targetGrade,
  Value<int> dailyCapacity,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});

class $$StudyPlansTableFilterComposer
    extends Composer<_$AppDatabase, $StudyPlansTable> {
  $$StudyPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specializationId => $composableBuilder(
      column: $table.specializationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get interviewDate => $composableBuilder(
      column: $table.interviewDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetGrade => $composableBuilder(
      column: $table.targetGrade, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dailyCapacity => $composableBuilder(
      column: $table.dailyCapacity, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$StudyPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyPlansTable> {
  $$StudyPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specializationId => $composableBuilder(
      column: $table.specializationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get interviewDate => $composableBuilder(
      column: $table.interviewDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetGrade => $composableBuilder(
      column: $table.targetGrade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dailyCapacity => $composableBuilder(
      column: $table.dailyCapacity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$StudyPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyPlansTable> {
  $$StudyPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get specializationId => $composableBuilder(
      column: $table.specializationId, builder: (column) => column);

  GeneratedColumn<DateTime> get interviewDate => $composableBuilder(
      column: $table.interviewDate, builder: (column) => column);

  GeneratedColumn<int> get targetGrade => $composableBuilder(
      column: $table.targetGrade, builder: (column) => column);

  GeneratedColumn<int> get dailyCapacity => $composableBuilder(
      column: $table.dailyCapacity, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StudyPlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudyPlansTable,
    StudyPlan,
    $$StudyPlansTableFilterComposer,
    $$StudyPlansTableOrderingComposer,
    $$StudyPlansTableAnnotationComposer,
    $$StudyPlansTableCreateCompanionBuilder,
    $$StudyPlansTableUpdateCompanionBuilder,
    (StudyPlan, BaseReferences<_$AppDatabase, $StudyPlansTable, StudyPlan>),
    StudyPlan,
    PrefetchHooks Function()> {
  $$StudyPlansTableTableManager(_$AppDatabase db, $StudyPlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> specializationId = const Value.absent(),
            Value<DateTime> interviewDate = const Value.absent(),
            Value<int> targetGrade = const Value.absent(),
            Value<int> dailyCapacity = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              StudyPlansCompanion(
            id: id,
            specializationId: specializationId,
            interviewDate: interviewDate,
            targetGrade: targetGrade,
            dailyCapacity: dailyCapacity,
            isActive: isActive,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String specializationId,
            required DateTime interviewDate,
            required int targetGrade,
            required int dailyCapacity,
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
          }) =>
              StudyPlansCompanion.insert(
            id: id,
            specializationId: specializationId,
            interviewDate: interviewDate,
            targetGrade: targetGrade,
            dailyCapacity: dailyCapacity,
            isActive: isActive,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StudyPlansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StudyPlansTable,
    StudyPlan,
    $$StudyPlansTableFilterComposer,
    $$StudyPlansTableOrderingComposer,
    $$StudyPlansTableAnnotationComposer,
    $$StudyPlansTableCreateCompanionBuilder,
    $$StudyPlansTableUpdateCompanionBuilder,
    (StudyPlan, BaseReferences<_$AppDatabase, $StudyPlansTable, StudyPlan>),
    StudyPlan,
    PrefetchHooks Function()>;
typedef $$StudyPlanDaysTableCreateCompanionBuilder = StudyPlanDaysCompanion
    Function({
  required int planId,
  required int dayIndex,
  required DateTime day,
  required String topicCodes,
  required int newQuestions,
  required bool reviewOnly,
  Value<int> rowid,
});
typedef $$StudyPlanDaysTableUpdateCompanionBuilder = StudyPlanDaysCompanion
    Function({
  Value<int> planId,
  Value<int> dayIndex,
  Value<DateTime> day,
  Value<String> topicCodes,
  Value<int> newQuestions,
  Value<bool> reviewOnly,
  Value<int> rowid,
});

class $$StudyPlanDaysTableFilterComposer
    extends Composer<_$AppDatabase, $StudyPlanDaysTable> {
  $$StudyPlanDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get planId => $composableBuilder(
      column: $table.planId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayIndex => $composableBuilder(
      column: $table.dayIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicCodes => $composableBuilder(
      column: $table.topicCodes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get newQuestions => $composableBuilder(
      column: $table.newQuestions, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get reviewOnly => $composableBuilder(
      column: $table.reviewOnly, builder: (column) => ColumnFilters(column));
}

class $$StudyPlanDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyPlanDaysTable> {
  $$StudyPlanDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get planId => $composableBuilder(
      column: $table.planId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayIndex => $composableBuilder(
      column: $table.dayIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicCodes => $composableBuilder(
      column: $table.topicCodes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get newQuestions => $composableBuilder(
      column: $table.newQuestions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get reviewOnly => $composableBuilder(
      column: $table.reviewOnly, builder: (column) => ColumnOrderings(column));
}

class $$StudyPlanDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyPlanDaysTable> {
  $$StudyPlanDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<int> get dayIndex =>
      $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get topicCodes => $composableBuilder(
      column: $table.topicCodes, builder: (column) => column);

  GeneratedColumn<int> get newQuestions => $composableBuilder(
      column: $table.newQuestions, builder: (column) => column);

  GeneratedColumn<bool> get reviewOnly => $composableBuilder(
      column: $table.reviewOnly, builder: (column) => column);
}

class $$StudyPlanDaysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudyPlanDaysTable,
    StudyPlanDay,
    $$StudyPlanDaysTableFilterComposer,
    $$StudyPlanDaysTableOrderingComposer,
    $$StudyPlanDaysTableAnnotationComposer,
    $$StudyPlanDaysTableCreateCompanionBuilder,
    $$StudyPlanDaysTableUpdateCompanionBuilder,
    (
      StudyPlanDay,
      BaseReferences<_$AppDatabase, $StudyPlanDaysTable, StudyPlanDay>
    ),
    StudyPlanDay,
    PrefetchHooks Function()> {
  $$StudyPlanDaysTableTableManager(_$AppDatabase db, $StudyPlanDaysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyPlanDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyPlanDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyPlanDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> planId = const Value.absent(),
            Value<int> dayIndex = const Value.absent(),
            Value<DateTime> day = const Value.absent(),
            Value<String> topicCodes = const Value.absent(),
            Value<int> newQuestions = const Value.absent(),
            Value<bool> reviewOnly = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StudyPlanDaysCompanion(
            planId: planId,
            dayIndex: dayIndex,
            day: day,
            topicCodes: topicCodes,
            newQuestions: newQuestions,
            reviewOnly: reviewOnly,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int planId,
            required int dayIndex,
            required DateTime day,
            required String topicCodes,
            required int newQuestions,
            required bool reviewOnly,
            Value<int> rowid = const Value.absent(),
          }) =>
              StudyPlanDaysCompanion.insert(
            planId: planId,
            dayIndex: dayIndex,
            day: day,
            topicCodes: topicCodes,
            newQuestions: newQuestions,
            reviewOnly: reviewOnly,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StudyPlanDaysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StudyPlanDaysTable,
    StudyPlanDay,
    $$StudyPlanDaysTableFilterComposer,
    $$StudyPlanDaysTableOrderingComposer,
    $$StudyPlanDaysTableAnnotationComposer,
    $$StudyPlanDaysTableCreateCompanionBuilder,
    $$StudyPlanDaysTableUpdateCompanionBuilder,
    (
      StudyPlanDay,
      BaseReferences<_$AppDatabase, $StudyPlanDaysTable, StudyPlanDay>
    ),
    StudyPlanDay,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$AnswersTableTableManager get answers =>
      $$AnswersTableTableManager(_db, _db.answers);
  $$TopicRatingsTableTableManager get topicRatings =>
      $$TopicRatingsTableTableManager(_db, _db.topicRatings);
  $$ReviewStatesTableTableManager get reviewStates =>
      $$ReviewStatesTableTableManager(_db, _db.reviewStates);
  $$StudyPlansTableTableManager get studyPlans =>
      $$StudyPlansTableTableManager(_db, _db.studyPlans);
  $$StudyPlanDaysTableTableManager get studyPlanDays =>
      $$StudyPlanDaysTableTableManager(_db, _db.studyPlanDays);
}
