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
  static const VerificationMeta _selfAssessedGradeMeta =
      const VerificationMeta('selfAssessedGrade');
  @override
  late final GeneratedColumn<int> selfAssessedGrade = GeneratedColumn<int>(
      'self_assessed_grade', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
  List<GeneratedColumn> get $columns => [
        specializationId,
        selfAssessedGrade,
        targetGrade,
        isPrimary,
        answersCount,
        updatedAt
      ];
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
    if (data.containsKey('self_assessed_grade')) {
      context.handle(
          _selfAssessedGradeMeta,
          selfAssessedGrade.isAcceptableOrUnknown(
              data['self_assessed_grade']!, _selfAssessedGradeMeta));
    } else if (isInserting) {
      context.missing(_selfAssessedGradeMeta);
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
      selfAssessedGrade: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}self_assessed_grade'])!,
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

  /// Где человек сейчас — стартовая точка для оценки.
  final int selfAssessedGrade;

  /// К какому уровню готовится — именно он определяет выдачу.
  final int targetGrade;
  final bool isPrimary;
  final int answersCount;
  final DateTime updatedAt;
  const Profile(
      {required this.specializationId,
      required this.selfAssessedGrade,
      required this.targetGrade,
      required this.isPrimary,
      required this.answersCount,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['specialization_id'] = Variable<String>(specializationId);
    map['self_assessed_grade'] = Variable<int>(selfAssessedGrade);
    map['target_grade'] = Variable<int>(targetGrade);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['answers_count'] = Variable<int>(answersCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      specializationId: Value(specializationId),
      selfAssessedGrade: Value(selfAssessedGrade),
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
      selfAssessedGrade: serializer.fromJson<int>(json['selfAssessedGrade']),
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
      'selfAssessedGrade': serializer.toJson<int>(selfAssessedGrade),
      'targetGrade': serializer.toJson<int>(targetGrade),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'answersCount': serializer.toJson<int>(answersCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Profile copyWith(
          {String? specializationId,
          int? selfAssessedGrade,
          int? targetGrade,
          bool? isPrimary,
          int? answersCount,
          DateTime? updatedAt}) =>
      Profile(
        specializationId: specializationId ?? this.specializationId,
        selfAssessedGrade: selfAssessedGrade ?? this.selfAssessedGrade,
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
      selfAssessedGrade: data.selfAssessedGrade.present
          ? data.selfAssessedGrade.value
          : this.selfAssessedGrade,
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
          ..write('selfAssessedGrade: $selfAssessedGrade, ')
          ..write('targetGrade: $targetGrade, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('answersCount: $answersCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(specializationId, selfAssessedGrade,
      targetGrade, isPrimary, answersCount, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.specializationId == this.specializationId &&
          other.selfAssessedGrade == this.selfAssessedGrade &&
          other.targetGrade == this.targetGrade &&
          other.isPrimary == this.isPrimary &&
          other.answersCount == this.answersCount &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> specializationId;
  final Value<int> selfAssessedGrade;
  final Value<int> targetGrade;
  final Value<bool> isPrimary;
  final Value<int> answersCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.specializationId = const Value.absent(),
    this.selfAssessedGrade = const Value.absent(),
    this.targetGrade = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.answersCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String specializationId,
    required int selfAssessedGrade,
    required int targetGrade,
    this.isPrimary = const Value.absent(),
    this.answersCount = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : specializationId = Value(specializationId),
        selfAssessedGrade = Value(selfAssessedGrade),
        targetGrade = Value(targetGrade),
        updatedAt = Value(updatedAt);
  static Insertable<Profile> custom({
    Expression<String>? specializationId,
    Expression<int>? selfAssessedGrade,
    Expression<int>? targetGrade,
    Expression<bool>? isPrimary,
    Expression<int>? answersCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (specializationId != null) 'specialization_id': specializationId,
      if (selfAssessedGrade != null) 'self_assessed_grade': selfAssessedGrade,
      if (targetGrade != null) 'target_grade': targetGrade,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (answersCount != null) 'answers_count': answersCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith(
      {Value<String>? specializationId,
      Value<int>? selfAssessedGrade,
      Value<int>? targetGrade,
      Value<bool>? isPrimary,
      Value<int>? answersCount,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ProfilesCompanion(
      specializationId: specializationId ?? this.specializationId,
      selfAssessedGrade: selfAssessedGrade ?? this.selfAssessedGrade,
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
    if (selfAssessedGrade.present) {
      map['self_assessed_grade'] = Variable<int>(selfAssessedGrade.value);
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
          ..write('selfAssessedGrade: $selfAssessedGrade, ')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $AnswersTable answers = $AnswersTable(this);
  late final $TopicRatingsTable topicRatings = $TopicRatingsTable(this);
  late final $ReviewStatesTable reviewStates = $ReviewStatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [profiles, answers, topicRatings, reviewStates];
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  required String specializationId,
  required int selfAssessedGrade,
  required int targetGrade,
  Value<bool> isPrimary,
  Value<int> answersCount,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<String> specializationId,
  Value<int> selfAssessedGrade,
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

  ColumnFilters<int> get selfAssessedGrade => $composableBuilder(
      column: $table.selfAssessedGrade,
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

  ColumnOrderings<int> get selfAssessedGrade => $composableBuilder(
      column: $table.selfAssessedGrade,
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

  GeneratedColumn<int> get selfAssessedGrade => $composableBuilder(
      column: $table.selfAssessedGrade, builder: (column) => column);

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
            Value<int> selfAssessedGrade = const Value.absent(),
            Value<int> targetGrade = const Value.absent(),
            Value<bool> isPrimary = const Value.absent(),
            Value<int> answersCount = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfilesCompanion(
            specializationId: specializationId,
            selfAssessedGrade: selfAssessedGrade,
            targetGrade: targetGrade,
            isPrimary: isPrimary,
            answersCount: answersCount,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String specializationId,
            required int selfAssessedGrade,
            required int targetGrade,
            Value<bool> isPrimary = const Value.absent(),
            Value<int> answersCount = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfilesCompanion.insert(
            specializationId: specializationId,
            selfAssessedGrade: selfAssessedGrade,
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
}
