// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedQuestionsTable extends CachedQuestions
    with TableInfo<$CachedQuestionsTable, CachedQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _specializationIdMeta =
      const VerificationMeta('specializationId');
  @override
  late final GeneratedColumn<String> specializationId = GeneratedColumn<String>(
      'specialization_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicCodeMeta =
      const VerificationMeta('topicCode');
  @override
  late final GeneratedColumn<String> topicCode = GeneratedColumn<String>(
      'topic_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicTitleMeta =
      const VerificationMeta('topicTitle');
  @override
  late final GeneratedColumn<String> topicTitle = GeneratedColumn<String>(
      'topic_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subtopicCodeMeta =
      const VerificationMeta('subtopicCode');
  @override
  late final GeneratedColumn<String> subtopicCode = GeneratedColumn<String>(
      'subtopic_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subtopicTitleMeta =
      const VerificationMeta('subtopicTitle');
  @override
  late final GeneratedColumn<String> subtopicTitle = GeneratedColumn<String>(
      'subtopic_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _minGradeMeta =
      const VerificationMeta('minGrade');
  @override
  late final GeneratedColumn<int> minGrade = GeneratedColumn<int>(
      'min_grade', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _peakGradeMeta =
      const VerificationMeta('peakGrade');
  @override
  late final GeneratedColumn<int> peakGrade = GeneratedColumn<int>(
      'peak_grade', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _maxGradeMeta =
      const VerificationMeta('maxGrade');
  @override
  late final GeneratedColumn<int> maxGrade = GeneratedColumn<int>(
      'max_grade', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
      'frequency', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _optionsJsonMeta =
      const VerificationMeta('optionsJson');
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
      'options_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isVerifiedMeta =
      const VerificationMeta('isVerified');
  @override
  late final GeneratedColumn<bool> isVerified = GeneratedColumn<bool>(
      'is_verified', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_verified" IN (0, 1))'));
  static const VerificationMeta _answerShortMeta =
      const VerificationMeta('answerShort');
  @override
  late final GeneratedColumn<String> answerShort = GeneratedColumn<String>(
      'answer_short', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _answerDetailedMeta =
      const VerificationMeta('answerDetailed');
  @override
  late final GeneratedColumn<String> answerDetailed = GeneratedColumn<String>(
      'answer_detailed', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commonMistakesJsonMeta =
      const VerificationMeta('commonMistakesJson');
  @override
  late final GeneratedColumn<String> commonMistakesJson =
      GeneratedColumn<String>('common_mistakes_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _followUpsJsonMeta =
      const VerificationMeta('followUpsJson');
  @override
  late final GeneratedColumn<String> followUpsJson = GeneratedColumn<String>(
      'follow_ups_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        specializationId,
        type,
        title,
        topicCode,
        topicTitle,
        subtopicCode,
        subtopicTitle,
        minGrade,
        peakGrade,
        maxGrade,
        frequency,
        optionsJson,
        isVerified,
        answerShort,
        answerDetailed,
        commonMistakesJson,
        followUpsJson,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_questions';
  @override
  VerificationContext validateIntegrity(Insertable<CachedQuestion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('specialization_id')) {
      context.handle(
          _specializationIdMeta,
          specializationId.isAcceptableOrUnknown(
              data['specialization_id']!, _specializationIdMeta));
    } else if (isInserting) {
      context.missing(_specializationIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('topic_code')) {
      context.handle(_topicCodeMeta,
          topicCode.isAcceptableOrUnknown(data['topic_code']!, _topicCodeMeta));
    } else if (isInserting) {
      context.missing(_topicCodeMeta);
    }
    if (data.containsKey('topic_title')) {
      context.handle(
          _topicTitleMeta,
          topicTitle.isAcceptableOrUnknown(
              data['topic_title']!, _topicTitleMeta));
    } else if (isInserting) {
      context.missing(_topicTitleMeta);
    }
    if (data.containsKey('subtopic_code')) {
      context.handle(
          _subtopicCodeMeta,
          subtopicCode.isAcceptableOrUnknown(
              data['subtopic_code']!, _subtopicCodeMeta));
    }
    if (data.containsKey('subtopic_title')) {
      context.handle(
          _subtopicTitleMeta,
          subtopicTitle.isAcceptableOrUnknown(
              data['subtopic_title']!, _subtopicTitleMeta));
    }
    if (data.containsKey('min_grade')) {
      context.handle(_minGradeMeta,
          minGrade.isAcceptableOrUnknown(data['min_grade']!, _minGradeMeta));
    } else if (isInserting) {
      context.missing(_minGradeMeta);
    }
    if (data.containsKey('peak_grade')) {
      context.handle(_peakGradeMeta,
          peakGrade.isAcceptableOrUnknown(data['peak_grade']!, _peakGradeMeta));
    } else if (isInserting) {
      context.missing(_peakGradeMeta);
    }
    if (data.containsKey('max_grade')) {
      context.handle(_maxGradeMeta,
          maxGrade.isAcceptableOrUnknown(data['max_grade']!, _maxGradeMeta));
    } else if (isInserting) {
      context.missing(_maxGradeMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('options_json')) {
      context.handle(
          _optionsJsonMeta,
          optionsJson.isAcceptableOrUnknown(
              data['options_json']!, _optionsJsonMeta));
    } else if (isInserting) {
      context.missing(_optionsJsonMeta);
    }
    if (data.containsKey('is_verified')) {
      context.handle(
          _isVerifiedMeta,
          isVerified.isAcceptableOrUnknown(
              data['is_verified']!, _isVerifiedMeta));
    } else if (isInserting) {
      context.missing(_isVerifiedMeta);
    }
    if (data.containsKey('answer_short')) {
      context.handle(
          _answerShortMeta,
          answerShort.isAcceptableOrUnknown(
              data['answer_short']!, _answerShortMeta));
    } else if (isInserting) {
      context.missing(_answerShortMeta);
    }
    if (data.containsKey('answer_detailed')) {
      context.handle(
          _answerDetailedMeta,
          answerDetailed.isAcceptableOrUnknown(
              data['answer_detailed']!, _answerDetailedMeta));
    } else if (isInserting) {
      context.missing(_answerDetailedMeta);
    }
    if (data.containsKey('common_mistakes_json')) {
      context.handle(
          _commonMistakesJsonMeta,
          commonMistakesJson.isAcceptableOrUnknown(
              data['common_mistakes_json']!, _commonMistakesJsonMeta));
    } else if (isInserting) {
      context.missing(_commonMistakesJsonMeta);
    }
    if (data.containsKey('follow_ups_json')) {
      context.handle(
          _followUpsJsonMeta,
          followUpsJson.isAcceptableOrUnknown(
              data['follow_ups_json']!, _followUpsJsonMeta));
    } else if (isInserting) {
      context.missing(_followUpsJsonMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id, specializationId};
  @override
  CachedQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedQuestion(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      specializationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}specialization_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      topicCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_code'])!,
      topicTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_title'])!,
      subtopicCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subtopic_code']),
      subtopicTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subtopic_title']),
      minGrade: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}min_grade'])!,
      peakGrade: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}peak_grade'])!,
      maxGrade: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_grade'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency'])!,
      optionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}options_json'])!,
      isVerified: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_verified'])!,
      answerShort: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}answer_short'])!,
      answerDetailed: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}answer_detailed'])!,
      commonMistakesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}common_mistakes_json'])!,
      followUpsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}follow_ups_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CachedQuestionsTable createAlias(String alias) {
    return $CachedQuestionsTable(attachedDatabase, alias);
  }
}

class CachedQuestion extends DataClass implements Insertable<CachedQuestion> {
  final String id;
  final String specializationId;
  final String type;
  final String title;
  final String topicCode;
  final String topicTitle;
  final String? subtopicCode;
  final String? subtopicTitle;
  final int minGrade;
  final int peakGrade;
  final int maxGrade;
  final int frequency;

  /// Варианты вместе с признаком правильности: без него офлайн не проверить ответ.
  final String optionsJson;
  final bool isVerified;
  final String answerShort;
  final String answerDetailed;
  final String commonMistakesJson;
  final String followUpsJson;
  final DateTime updatedAt;
  const CachedQuestion(
      {required this.id,
      required this.specializationId,
      required this.type,
      required this.title,
      required this.topicCode,
      required this.topicTitle,
      this.subtopicCode,
      this.subtopicTitle,
      required this.minGrade,
      required this.peakGrade,
      required this.maxGrade,
      required this.frequency,
      required this.optionsJson,
      required this.isVerified,
      required this.answerShort,
      required this.answerDetailed,
      required this.commonMistakesJson,
      required this.followUpsJson,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['specialization_id'] = Variable<String>(specializationId);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['topic_code'] = Variable<String>(topicCode);
    map['topic_title'] = Variable<String>(topicTitle);
    if (!nullToAbsent || subtopicCode != null) {
      map['subtopic_code'] = Variable<String>(subtopicCode);
    }
    if (!nullToAbsent || subtopicTitle != null) {
      map['subtopic_title'] = Variable<String>(subtopicTitle);
    }
    map['min_grade'] = Variable<int>(minGrade);
    map['peak_grade'] = Variable<int>(peakGrade);
    map['max_grade'] = Variable<int>(maxGrade);
    map['frequency'] = Variable<int>(frequency);
    map['options_json'] = Variable<String>(optionsJson);
    map['is_verified'] = Variable<bool>(isVerified);
    map['answer_short'] = Variable<String>(answerShort);
    map['answer_detailed'] = Variable<String>(answerDetailed);
    map['common_mistakes_json'] = Variable<String>(commonMistakesJson);
    map['follow_ups_json'] = Variable<String>(followUpsJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedQuestionsCompanion toCompanion(bool nullToAbsent) {
    return CachedQuestionsCompanion(
      id: Value(id),
      specializationId: Value(specializationId),
      type: Value(type),
      title: Value(title),
      topicCode: Value(topicCode),
      topicTitle: Value(topicTitle),
      subtopicCode: subtopicCode == null && nullToAbsent
          ? const Value.absent()
          : Value(subtopicCode),
      subtopicTitle: subtopicTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtopicTitle),
      minGrade: Value(minGrade),
      peakGrade: Value(peakGrade),
      maxGrade: Value(maxGrade),
      frequency: Value(frequency),
      optionsJson: Value(optionsJson),
      isVerified: Value(isVerified),
      answerShort: Value(answerShort),
      answerDetailed: Value(answerDetailed),
      commonMistakesJson: Value(commonMistakesJson),
      followUpsJson: Value(followUpsJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedQuestion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedQuestion(
      id: serializer.fromJson<String>(json['id']),
      specializationId: serializer.fromJson<String>(json['specializationId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      topicCode: serializer.fromJson<String>(json['topicCode']),
      topicTitle: serializer.fromJson<String>(json['topicTitle']),
      subtopicCode: serializer.fromJson<String?>(json['subtopicCode']),
      subtopicTitle: serializer.fromJson<String?>(json['subtopicTitle']),
      minGrade: serializer.fromJson<int>(json['minGrade']),
      peakGrade: serializer.fromJson<int>(json['peakGrade']),
      maxGrade: serializer.fromJson<int>(json['maxGrade']),
      frequency: serializer.fromJson<int>(json['frequency']),
      optionsJson: serializer.fromJson<String>(json['optionsJson']),
      isVerified: serializer.fromJson<bool>(json['isVerified']),
      answerShort: serializer.fromJson<String>(json['answerShort']),
      answerDetailed: serializer.fromJson<String>(json['answerDetailed']),
      commonMistakesJson:
          serializer.fromJson<String>(json['commonMistakesJson']),
      followUpsJson: serializer.fromJson<String>(json['followUpsJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'specializationId': serializer.toJson<String>(specializationId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'topicCode': serializer.toJson<String>(topicCode),
      'topicTitle': serializer.toJson<String>(topicTitle),
      'subtopicCode': serializer.toJson<String?>(subtopicCode),
      'subtopicTitle': serializer.toJson<String?>(subtopicTitle),
      'minGrade': serializer.toJson<int>(minGrade),
      'peakGrade': serializer.toJson<int>(peakGrade),
      'maxGrade': serializer.toJson<int>(maxGrade),
      'frequency': serializer.toJson<int>(frequency),
      'optionsJson': serializer.toJson<String>(optionsJson),
      'isVerified': serializer.toJson<bool>(isVerified),
      'answerShort': serializer.toJson<String>(answerShort),
      'answerDetailed': serializer.toJson<String>(answerDetailed),
      'commonMistakesJson': serializer.toJson<String>(commonMistakesJson),
      'followUpsJson': serializer.toJson<String>(followUpsJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedQuestion copyWith(
          {String? id,
          String? specializationId,
          String? type,
          String? title,
          String? topicCode,
          String? topicTitle,
          Value<String?> subtopicCode = const Value.absent(),
          Value<String?> subtopicTitle = const Value.absent(),
          int? minGrade,
          int? peakGrade,
          int? maxGrade,
          int? frequency,
          String? optionsJson,
          bool? isVerified,
          String? answerShort,
          String? answerDetailed,
          String? commonMistakesJson,
          String? followUpsJson,
          DateTime? updatedAt}) =>
      CachedQuestion(
        id: id ?? this.id,
        specializationId: specializationId ?? this.specializationId,
        type: type ?? this.type,
        title: title ?? this.title,
        topicCode: topicCode ?? this.topicCode,
        topicTitle: topicTitle ?? this.topicTitle,
        subtopicCode:
            subtopicCode.present ? subtopicCode.value : this.subtopicCode,
        subtopicTitle:
            subtopicTitle.present ? subtopicTitle.value : this.subtopicTitle,
        minGrade: minGrade ?? this.minGrade,
        peakGrade: peakGrade ?? this.peakGrade,
        maxGrade: maxGrade ?? this.maxGrade,
        frequency: frequency ?? this.frequency,
        optionsJson: optionsJson ?? this.optionsJson,
        isVerified: isVerified ?? this.isVerified,
        answerShort: answerShort ?? this.answerShort,
        answerDetailed: answerDetailed ?? this.answerDetailed,
        commonMistakesJson: commonMistakesJson ?? this.commonMistakesJson,
        followUpsJson: followUpsJson ?? this.followUpsJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CachedQuestion copyWithCompanion(CachedQuestionsCompanion data) {
    return CachedQuestion(
      id: data.id.present ? data.id.value : this.id,
      specializationId: data.specializationId.present
          ? data.specializationId.value
          : this.specializationId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      topicCode: data.topicCode.present ? data.topicCode.value : this.topicCode,
      topicTitle:
          data.topicTitle.present ? data.topicTitle.value : this.topicTitle,
      subtopicCode: data.subtopicCode.present
          ? data.subtopicCode.value
          : this.subtopicCode,
      subtopicTitle: data.subtopicTitle.present
          ? data.subtopicTitle.value
          : this.subtopicTitle,
      minGrade: data.minGrade.present ? data.minGrade.value : this.minGrade,
      peakGrade: data.peakGrade.present ? data.peakGrade.value : this.peakGrade,
      maxGrade: data.maxGrade.present ? data.maxGrade.value : this.maxGrade,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      optionsJson:
          data.optionsJson.present ? data.optionsJson.value : this.optionsJson,
      isVerified:
          data.isVerified.present ? data.isVerified.value : this.isVerified,
      answerShort:
          data.answerShort.present ? data.answerShort.value : this.answerShort,
      answerDetailed: data.answerDetailed.present
          ? data.answerDetailed.value
          : this.answerDetailed,
      commonMistakesJson: data.commonMistakesJson.present
          ? data.commonMistakesJson.value
          : this.commonMistakesJson,
      followUpsJson: data.followUpsJson.present
          ? data.followUpsJson.value
          : this.followUpsJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedQuestion(')
          ..write('id: $id, ')
          ..write('specializationId: $specializationId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('topicCode: $topicCode, ')
          ..write('topicTitle: $topicTitle, ')
          ..write('subtopicCode: $subtopicCode, ')
          ..write('subtopicTitle: $subtopicTitle, ')
          ..write('minGrade: $minGrade, ')
          ..write('peakGrade: $peakGrade, ')
          ..write('maxGrade: $maxGrade, ')
          ..write('frequency: $frequency, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('isVerified: $isVerified, ')
          ..write('answerShort: $answerShort, ')
          ..write('answerDetailed: $answerDetailed, ')
          ..write('commonMistakesJson: $commonMistakesJson, ')
          ..write('followUpsJson: $followUpsJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      specializationId,
      type,
      title,
      topicCode,
      topicTitle,
      subtopicCode,
      subtopicTitle,
      minGrade,
      peakGrade,
      maxGrade,
      frequency,
      optionsJson,
      isVerified,
      answerShort,
      answerDetailed,
      commonMistakesJson,
      followUpsJson,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedQuestion &&
          other.id == this.id &&
          other.specializationId == this.specializationId &&
          other.type == this.type &&
          other.title == this.title &&
          other.topicCode == this.topicCode &&
          other.topicTitle == this.topicTitle &&
          other.subtopicCode == this.subtopicCode &&
          other.subtopicTitle == this.subtopicTitle &&
          other.minGrade == this.minGrade &&
          other.peakGrade == this.peakGrade &&
          other.maxGrade == this.maxGrade &&
          other.frequency == this.frequency &&
          other.optionsJson == this.optionsJson &&
          other.isVerified == this.isVerified &&
          other.answerShort == this.answerShort &&
          other.answerDetailed == this.answerDetailed &&
          other.commonMistakesJson == this.commonMistakesJson &&
          other.followUpsJson == this.followUpsJson &&
          other.updatedAt == this.updatedAt);
}

class CachedQuestionsCompanion extends UpdateCompanion<CachedQuestion> {
  final Value<String> id;
  final Value<String> specializationId;
  final Value<String> type;
  final Value<String> title;
  final Value<String> topicCode;
  final Value<String> topicTitle;
  final Value<String?> subtopicCode;
  final Value<String?> subtopicTitle;
  final Value<int> minGrade;
  final Value<int> peakGrade;
  final Value<int> maxGrade;
  final Value<int> frequency;
  final Value<String> optionsJson;
  final Value<bool> isVerified;
  final Value<String> answerShort;
  final Value<String> answerDetailed;
  final Value<String> commonMistakesJson;
  final Value<String> followUpsJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CachedQuestionsCompanion({
    this.id = const Value.absent(),
    this.specializationId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.topicCode = const Value.absent(),
    this.topicTitle = const Value.absent(),
    this.subtopicCode = const Value.absent(),
    this.subtopicTitle = const Value.absent(),
    this.minGrade = const Value.absent(),
    this.peakGrade = const Value.absent(),
    this.maxGrade = const Value.absent(),
    this.frequency = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.answerShort = const Value.absent(),
    this.answerDetailed = const Value.absent(),
    this.commonMistakesJson = const Value.absent(),
    this.followUpsJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedQuestionsCompanion.insert({
    required String id,
    required String specializationId,
    required String type,
    required String title,
    required String topicCode,
    required String topicTitle,
    this.subtopicCode = const Value.absent(),
    this.subtopicTitle = const Value.absent(),
    required int minGrade,
    required int peakGrade,
    required int maxGrade,
    required int frequency,
    required String optionsJson,
    required bool isVerified,
    required String answerShort,
    required String answerDetailed,
    required String commonMistakesJson,
    required String followUpsJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        specializationId = Value(specializationId),
        type = Value(type),
        title = Value(title),
        topicCode = Value(topicCode),
        topicTitle = Value(topicTitle),
        minGrade = Value(minGrade),
        peakGrade = Value(peakGrade),
        maxGrade = Value(maxGrade),
        frequency = Value(frequency),
        optionsJson = Value(optionsJson),
        isVerified = Value(isVerified),
        answerShort = Value(answerShort),
        answerDetailed = Value(answerDetailed),
        commonMistakesJson = Value(commonMistakesJson),
        followUpsJson = Value(followUpsJson),
        updatedAt = Value(updatedAt);
  static Insertable<CachedQuestion> custom({
    Expression<String>? id,
    Expression<String>? specializationId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? topicCode,
    Expression<String>? topicTitle,
    Expression<String>? subtopicCode,
    Expression<String>? subtopicTitle,
    Expression<int>? minGrade,
    Expression<int>? peakGrade,
    Expression<int>? maxGrade,
    Expression<int>? frequency,
    Expression<String>? optionsJson,
    Expression<bool>? isVerified,
    Expression<String>? answerShort,
    Expression<String>? answerDetailed,
    Expression<String>? commonMistakesJson,
    Expression<String>? followUpsJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (specializationId != null) 'specialization_id': specializationId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (topicCode != null) 'topic_code': topicCode,
      if (topicTitle != null) 'topic_title': topicTitle,
      if (subtopicCode != null) 'subtopic_code': subtopicCode,
      if (subtopicTitle != null) 'subtopic_title': subtopicTitle,
      if (minGrade != null) 'min_grade': minGrade,
      if (peakGrade != null) 'peak_grade': peakGrade,
      if (maxGrade != null) 'max_grade': maxGrade,
      if (frequency != null) 'frequency': frequency,
      if (optionsJson != null) 'options_json': optionsJson,
      if (isVerified != null) 'is_verified': isVerified,
      if (answerShort != null) 'answer_short': answerShort,
      if (answerDetailed != null) 'answer_detailed': answerDetailed,
      if (commonMistakesJson != null)
        'common_mistakes_json': commonMistakesJson,
      if (followUpsJson != null) 'follow_ups_json': followUpsJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedQuestionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? specializationId,
      Value<String>? type,
      Value<String>? title,
      Value<String>? topicCode,
      Value<String>? topicTitle,
      Value<String?>? subtopicCode,
      Value<String?>? subtopicTitle,
      Value<int>? minGrade,
      Value<int>? peakGrade,
      Value<int>? maxGrade,
      Value<int>? frequency,
      Value<String>? optionsJson,
      Value<bool>? isVerified,
      Value<String>? answerShort,
      Value<String>? answerDetailed,
      Value<String>? commonMistakesJson,
      Value<String>? followUpsJson,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CachedQuestionsCompanion(
      id: id ?? this.id,
      specializationId: specializationId ?? this.specializationId,
      type: type ?? this.type,
      title: title ?? this.title,
      topicCode: topicCode ?? this.topicCode,
      topicTitle: topicTitle ?? this.topicTitle,
      subtopicCode: subtopicCode ?? this.subtopicCode,
      subtopicTitle: subtopicTitle ?? this.subtopicTitle,
      minGrade: minGrade ?? this.minGrade,
      peakGrade: peakGrade ?? this.peakGrade,
      maxGrade: maxGrade ?? this.maxGrade,
      frequency: frequency ?? this.frequency,
      optionsJson: optionsJson ?? this.optionsJson,
      isVerified: isVerified ?? this.isVerified,
      answerShort: answerShort ?? this.answerShort,
      answerDetailed: answerDetailed ?? this.answerDetailed,
      commonMistakesJson: commonMistakesJson ?? this.commonMistakesJson,
      followUpsJson: followUpsJson ?? this.followUpsJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (specializationId.present) {
      map['specialization_id'] = Variable<String>(specializationId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (topicCode.present) {
      map['topic_code'] = Variable<String>(topicCode.value);
    }
    if (topicTitle.present) {
      map['topic_title'] = Variable<String>(topicTitle.value);
    }
    if (subtopicCode.present) {
      map['subtopic_code'] = Variable<String>(subtopicCode.value);
    }
    if (subtopicTitle.present) {
      map['subtopic_title'] = Variable<String>(subtopicTitle.value);
    }
    if (minGrade.present) {
      map['min_grade'] = Variable<int>(minGrade.value);
    }
    if (peakGrade.present) {
      map['peak_grade'] = Variable<int>(peakGrade.value);
    }
    if (maxGrade.present) {
      map['max_grade'] = Variable<int>(maxGrade.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(frequency.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (isVerified.present) {
      map['is_verified'] = Variable<bool>(isVerified.value);
    }
    if (answerShort.present) {
      map['answer_short'] = Variable<String>(answerShort.value);
    }
    if (answerDetailed.present) {
      map['answer_detailed'] = Variable<String>(answerDetailed.value);
    }
    if (commonMistakesJson.present) {
      map['common_mistakes_json'] = Variable<String>(commonMistakesJson.value);
    }
    if (followUpsJson.present) {
      map['follow_ups_json'] = Variable<String>(followUpsJson.value);
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
    return (StringBuffer('CachedQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('specializationId: $specializationId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('topicCode: $topicCode, ')
          ..write('topicTitle: $topicTitle, ')
          ..write('subtopicCode: $subtopicCode, ')
          ..write('subtopicTitle: $subtopicTitle, ')
          ..write('minGrade: $minGrade, ')
          ..write('peakGrade: $peakGrade, ')
          ..write('maxGrade: $maxGrade, ')
          ..write('frequency: $frequency, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('isVerified: $isVerified, ')
          ..write('answerShort: $answerShort, ')
          ..write('answerDetailed: $answerDetailed, ')
          ..write('commonMistakesJson: $commonMistakesJson, ')
          ..write('followUpsJson: $followUpsJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAnswersTable extends LocalAnswers
    with TableInfo<$LocalAnswersTable, LocalAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAnswersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        submissionId,
        questionId,
        specializationId,
        selectedOptionsJson,
        freeText,
        selfAssessment,
        score,
        quality,
        answeredAt,
        syncedAt,
        attempts,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_answers';
  @override
  VerificationContext validateIntegrity(Insertable<LocalAnswer> instance,
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
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {submissionId};
  @override
  LocalAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAnswer(
      submissionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}submission_id'])!,
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_id'])!,
      specializationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}specialization_id'])!,
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
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $LocalAnswersTable createAlias(String alias) {
    return $LocalAnswersTable(attachedDatabase, alias);
  }
}

class LocalAnswer extends DataClass implements Insertable<LocalAnswer> {
  /// Ключ идемпотентности, сгенерированный на устройстве. Он же защищает от
  /// дублей на сервере при повторной отправке пачки.
  final String submissionId;
  final String questionId;
  final String specializationId;
  final String selectedOptionsJson;
  final String? freeText;
  final int? selfAssessment;

  /// Результат, посчитанный на устройстве по тем же правилам, что и на сервере.
  final double score;
  final int quality;
  final DateTime answeredAt;
  final DateTime? syncedAt;
  final int attempts;
  final String? lastError;
  const LocalAnswer(
      {required this.submissionId,
      required this.questionId,
      required this.specializationId,
      required this.selectedOptionsJson,
      this.freeText,
      this.selfAssessment,
      required this.score,
      required this.quality,
      required this.answeredAt,
      this.syncedAt,
      required this.attempts,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['submission_id'] = Variable<String>(submissionId);
    map['question_id'] = Variable<String>(questionId);
    map['specialization_id'] = Variable<String>(specializationId);
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
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  LocalAnswersCompanion toCompanion(bool nullToAbsent) {
    return LocalAnswersCompanion(
      submissionId: Value(submissionId),
      questionId: Value(questionId),
      specializationId: Value(specializationId),
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
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory LocalAnswer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAnswer(
      submissionId: serializer.fromJson<String>(json['submissionId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      specializationId: serializer.fromJson<String>(json['specializationId']),
      selectedOptionsJson:
          serializer.fromJson<String>(json['selectedOptionsJson']),
      freeText: serializer.fromJson<String?>(json['freeText']),
      selfAssessment: serializer.fromJson<int?>(json['selfAssessment']),
      score: serializer.fromJson<double>(json['score']),
      quality: serializer.fromJson<int>(json['quality']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'submissionId': serializer.toJson<String>(submissionId),
      'questionId': serializer.toJson<String>(questionId),
      'specializationId': serializer.toJson<String>(specializationId),
      'selectedOptionsJson': serializer.toJson<String>(selectedOptionsJson),
      'freeText': serializer.toJson<String?>(freeText),
      'selfAssessment': serializer.toJson<int?>(selfAssessment),
      'score': serializer.toJson<double>(score),
      'quality': serializer.toJson<int>(quality),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  LocalAnswer copyWith(
          {String? submissionId,
          String? questionId,
          String? specializationId,
          String? selectedOptionsJson,
          Value<String?> freeText = const Value.absent(),
          Value<int?> selfAssessment = const Value.absent(),
          double? score,
          int? quality,
          DateTime? answeredAt,
          Value<DateTime?> syncedAt = const Value.absent(),
          int? attempts,
          Value<String?> lastError = const Value.absent()}) =>
      LocalAnswer(
        submissionId: submissionId ?? this.submissionId,
        questionId: questionId ?? this.questionId,
        specializationId: specializationId ?? this.specializationId,
        selectedOptionsJson: selectedOptionsJson ?? this.selectedOptionsJson,
        freeText: freeText.present ? freeText.value : this.freeText,
        selfAssessment:
            selfAssessment.present ? selfAssessment.value : this.selfAssessment,
        score: score ?? this.score,
        quality: quality ?? this.quality,
        answeredAt: answeredAt ?? this.answeredAt,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        attempts: attempts ?? this.attempts,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  LocalAnswer copyWithCompanion(LocalAnswersCompanion data) {
    return LocalAnswer(
      submissionId: data.submissionId.present
          ? data.submissionId.value
          : this.submissionId,
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      specializationId: data.specializationId.present
          ? data.specializationId.value
          : this.specializationId,
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
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnswer(')
          ..write('submissionId: $submissionId, ')
          ..write('questionId: $questionId, ')
          ..write('specializationId: $specializationId, ')
          ..write('selectedOptionsJson: $selectedOptionsJson, ')
          ..write('freeText: $freeText, ')
          ..write('selfAssessment: $selfAssessment, ')
          ..write('score: $score, ')
          ..write('quality: $quality, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      submissionId,
      questionId,
      specializationId,
      selectedOptionsJson,
      freeText,
      selfAssessment,
      score,
      quality,
      answeredAt,
      syncedAt,
      attempts,
      lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAnswer &&
          other.submissionId == this.submissionId &&
          other.questionId == this.questionId &&
          other.specializationId == this.specializationId &&
          other.selectedOptionsJson == this.selectedOptionsJson &&
          other.freeText == this.freeText &&
          other.selfAssessment == this.selfAssessment &&
          other.score == this.score &&
          other.quality == this.quality &&
          other.answeredAt == this.answeredAt &&
          other.syncedAt == this.syncedAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class LocalAnswersCompanion extends UpdateCompanion<LocalAnswer> {
  final Value<String> submissionId;
  final Value<String> questionId;
  final Value<String> specializationId;
  final Value<String> selectedOptionsJson;
  final Value<String?> freeText;
  final Value<int?> selfAssessment;
  final Value<double> score;
  final Value<int> quality;
  final Value<DateTime> answeredAt;
  final Value<DateTime?> syncedAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<int> rowid;
  const LocalAnswersCompanion({
    this.submissionId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.specializationId = const Value.absent(),
    this.selectedOptionsJson = const Value.absent(),
    this.freeText = const Value.absent(),
    this.selfAssessment = const Value.absent(),
    this.score = const Value.absent(),
    this.quality = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAnswersCompanion.insert({
    required String submissionId,
    required String questionId,
    required String specializationId,
    this.selectedOptionsJson = const Value.absent(),
    this.freeText = const Value.absent(),
    this.selfAssessment = const Value.absent(),
    required double score,
    required int quality,
    required DateTime answeredAt,
    this.syncedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : submissionId = Value(submissionId),
        questionId = Value(questionId),
        specializationId = Value(specializationId),
        score = Value(score),
        quality = Value(quality),
        answeredAt = Value(answeredAt);
  static Insertable<LocalAnswer> custom({
    Expression<String>? submissionId,
    Expression<String>? questionId,
    Expression<String>? specializationId,
    Expression<String>? selectedOptionsJson,
    Expression<String>? freeText,
    Expression<int>? selfAssessment,
    Expression<double>? score,
    Expression<int>? quality,
    Expression<DateTime>? answeredAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (submissionId != null) 'submission_id': submissionId,
      if (questionId != null) 'question_id': questionId,
      if (specializationId != null) 'specialization_id': specializationId,
      if (selectedOptionsJson != null)
        'selected_options_json': selectedOptionsJson,
      if (freeText != null) 'free_text': freeText,
      if (selfAssessment != null) 'self_assessment': selfAssessment,
      if (score != null) 'score': score,
      if (quality != null) 'quality': quality,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAnswersCompanion copyWith(
      {Value<String>? submissionId,
      Value<String>? questionId,
      Value<String>? specializationId,
      Value<String>? selectedOptionsJson,
      Value<String?>? freeText,
      Value<int?>? selfAssessment,
      Value<double>? score,
      Value<int>? quality,
      Value<DateTime>? answeredAt,
      Value<DateTime?>? syncedAt,
      Value<int>? attempts,
      Value<String?>? lastError,
      Value<int>? rowid}) {
    return LocalAnswersCompanion(
      submissionId: submissionId ?? this.submissionId,
      questionId: questionId ?? this.questionId,
      specializationId: specializationId ?? this.specializationId,
      selectedOptionsJson: selectedOptionsJson ?? this.selectedOptionsJson,
      freeText: freeText ?? this.freeText,
      selfAssessment: selfAssessment ?? this.selfAssessment,
      score: score ?? this.score,
      quality: quality ?? this.quality,
      answeredAt: answeredAt ?? this.answeredAt,
      syncedAt: syncedAt ?? this.syncedAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
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
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnswersCompanion(')
          ..write('submissionId: $submissionId, ')
          ..write('questionId: $questionId, ')
          ..write('specializationId: $specializationId, ')
          ..write('selectedOptionsJson: $selectedOptionsJson, ')
          ..write('freeText: $freeText, ')
          ..write('selfAssessment: $selfAssessment, ')
          ..write('score: $score, ')
          ..write('quality: $quality, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _specializationIdMeta =
      const VerificationMeta('specializationId');
  @override
  late final GeneratedColumn<String> specializationId = GeneratedColumn<String>(
      'specialization_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [specializationId, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(Insertable<SyncMetadataData> instance,
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
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {specializationId};
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      specializationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}specialization_id'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final String specializationId;
  final DateTime? lastSyncedAt;
  const SyncMetadataData({required this.specializationId, this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['specialization_id'] = Variable<String>(specializationId);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      specializationId: Value(specializationId),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory SyncMetadataData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      specializationId: serializer.fromJson<String>(json['specializationId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'specializationId': serializer.toJson<String>(specializationId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  SyncMetadataData copyWith(
          {String? specializationId,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      SyncMetadataData(
        specializationId: specializationId ?? this.specializationId,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      specializationId: data.specializationId.present
          ? data.specializationId.value
          : this.specializationId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('specializationId: $specializationId, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(specializationId, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.specializationId == this.specializationId &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<String> specializationId;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.specializationId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String specializationId,
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : specializationId = Value(specializationId);
  static Insertable<SyncMetadataData> custom({
    Expression<String>? specializationId,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (specializationId != null) 'specialization_id': specializationId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith(
      {Value<String>? specializationId,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return SyncMetadataCompanion(
      specializationId: specializationId ?? this.specializationId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (specializationId.present) {
      map['specialization_id'] = Variable<String>(specializationId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('specializationId: $specializationId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedProfileTable extends CachedProfile
    with TableInfo<$CachedProfileTable, CachedProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _savedAtMeta =
      const VerificationMeta('savedAt');
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
      'saved_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, payloadJson, savedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_profile';
  @override
  VerificationContext validateIntegrity(Insertable<CachedProfileData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(_savedAtMeta,
          savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta));
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedProfileData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      savedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}saved_at'])!,
    );
  }

  @override
  $CachedProfileTable createAlias(String alias) {
    return $CachedProfileTable(attachedDatabase, alias);
  }
}

class CachedProfileData extends DataClass
    implements Insertable<CachedProfileData> {
  /// Строка всегда одна: профиль на устройстве ровно один.
  final int id;
  final String payloadJson;
  final DateTime savedAt;
  const CachedProfileData(
      {required this.id, required this.payloadJson, required this.savedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['payload_json'] = Variable<String>(payloadJson);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  CachedProfileCompanion toCompanion(bool nullToAbsent) {
    return CachedProfileCompanion(
      id: Value(id),
      payloadJson: Value(payloadJson),
      savedAt: Value(savedAt),
    );
  }

  factory CachedProfileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedProfileData(
      id: serializer.fromJson<int>(json['id']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  CachedProfileData copyWith(
          {int? id, String? payloadJson, DateTime? savedAt}) =>
      CachedProfileData(
        id: id ?? this.id,
        payloadJson: payloadJson ?? this.payloadJson,
        savedAt: savedAt ?? this.savedAt,
      );
  CachedProfileData copyWithCompanion(CachedProfileCompanion data) {
    return CachedProfileData(
      id: data.id.present ? data.id.value : this.id,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedProfileData(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payloadJson, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedProfileData &&
          other.id == this.id &&
          other.payloadJson == this.payloadJson &&
          other.savedAt == this.savedAt);
}

class CachedProfileCompanion extends UpdateCompanion<CachedProfileData> {
  final Value<int> id;
  final Value<String> payloadJson;
  final Value<DateTime> savedAt;
  const CachedProfileCompanion({
    this.id = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.savedAt = const Value.absent(),
  });
  CachedProfileCompanion.insert({
    this.id = const Value.absent(),
    required String payloadJson,
    required DateTime savedAt,
  })  : payloadJson = Value(payloadJson),
        savedAt = Value(savedAt);
  static Insertable<CachedProfileData> custom({
    Expression<int>? id,
    Expression<String>? payloadJson,
    Expression<DateTime>? savedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (savedAt != null) 'saved_at': savedAt,
    });
  }

  CachedProfileCompanion copyWith(
      {Value<int>? id, Value<String>? payloadJson, Value<DateTime>? savedAt}) {
    return CachedProfileCompanion(
      id: id ?? this.id,
      payloadJson: payloadJson ?? this.payloadJson,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedProfileCompanion(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedQuestionsTable cachedQuestions =
      $CachedQuestionsTable(this);
  late final $LocalAnswersTable localAnswers = $LocalAnswersTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $CachedProfileTable cachedProfile = $CachedProfileTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [cachedQuestions, localAnswers, syncMetadata, cachedProfile];
}

typedef $$CachedQuestionsTableCreateCompanionBuilder = CachedQuestionsCompanion
    Function({
  required String id,
  required String specializationId,
  required String type,
  required String title,
  required String topicCode,
  required String topicTitle,
  Value<String?> subtopicCode,
  Value<String?> subtopicTitle,
  required int minGrade,
  required int peakGrade,
  required int maxGrade,
  required int frequency,
  required String optionsJson,
  required bool isVerified,
  required String answerShort,
  required String answerDetailed,
  required String commonMistakesJson,
  required String followUpsJson,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CachedQuestionsTableUpdateCompanionBuilder = CachedQuestionsCompanion
    Function({
  Value<String> id,
  Value<String> specializationId,
  Value<String> type,
  Value<String> title,
  Value<String> topicCode,
  Value<String> topicTitle,
  Value<String?> subtopicCode,
  Value<String?> subtopicTitle,
  Value<int> minGrade,
  Value<int> peakGrade,
  Value<int> maxGrade,
  Value<int> frequency,
  Value<String> optionsJson,
  Value<bool> isVerified,
  Value<String> answerShort,
  Value<String> answerDetailed,
  Value<String> commonMistakesJson,
  Value<String> followUpsJson,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CachedQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedQuestionsTable> {
  $$CachedQuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specializationId => $composableBuilder(
      column: $table.specializationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicCode => $composableBuilder(
      column: $table.topicCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicTitle => $composableBuilder(
      column: $table.topicTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subtopicCode => $composableBuilder(
      column: $table.subtopicCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subtopicTitle => $composableBuilder(
      column: $table.subtopicTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minGrade => $composableBuilder(
      column: $table.minGrade, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get peakGrade => $composableBuilder(
      column: $table.peakGrade, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxGrade => $composableBuilder(
      column: $table.maxGrade, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get answerShort => $composableBuilder(
      column: $table.answerShort, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get answerDetailed => $composableBuilder(
      column: $table.answerDetailed,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commonMistakesJson => $composableBuilder(
      column: $table.commonMistakesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get followUpsJson => $composableBuilder(
      column: $table.followUpsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedQuestionsTable> {
  $$CachedQuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specializationId => $composableBuilder(
      column: $table.specializationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicCode => $composableBuilder(
      column: $table.topicCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicTitle => $composableBuilder(
      column: $table.topicTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subtopicCode => $composableBuilder(
      column: $table.subtopicCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subtopicTitle => $composableBuilder(
      column: $table.subtopicTitle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minGrade => $composableBuilder(
      column: $table.minGrade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get peakGrade => $composableBuilder(
      column: $table.peakGrade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxGrade => $composableBuilder(
      column: $table.maxGrade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get answerShort => $composableBuilder(
      column: $table.answerShort, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get answerDetailed => $composableBuilder(
      column: $table.answerDetailed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commonMistakesJson => $composableBuilder(
      column: $table.commonMistakesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get followUpsJson => $composableBuilder(
      column: $table.followUpsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedQuestionsTable> {
  $$CachedQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get specializationId => $composableBuilder(
      column: $table.specializationId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get topicCode =>
      $composableBuilder(column: $table.topicCode, builder: (column) => column);

  GeneratedColumn<String> get topicTitle => $composableBuilder(
      column: $table.topicTitle, builder: (column) => column);

  GeneratedColumn<String> get subtopicCode => $composableBuilder(
      column: $table.subtopicCode, builder: (column) => column);

  GeneratedColumn<String> get subtopicTitle => $composableBuilder(
      column: $table.subtopicTitle, builder: (column) => column);

  GeneratedColumn<int> get minGrade =>
      $composableBuilder(column: $table.minGrade, builder: (column) => column);

  GeneratedColumn<int> get peakGrade =>
      $composableBuilder(column: $table.peakGrade, builder: (column) => column);

  GeneratedColumn<int> get maxGrade =>
      $composableBuilder(column: $table.maxGrade, builder: (column) => column);

  GeneratedColumn<int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => column);

  GeneratedColumn<bool> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => column);

  GeneratedColumn<String> get answerShort => $composableBuilder(
      column: $table.answerShort, builder: (column) => column);

  GeneratedColumn<String> get answerDetailed => $composableBuilder(
      column: $table.answerDetailed, builder: (column) => column);

  GeneratedColumn<String> get commonMistakesJson => $composableBuilder(
      column: $table.commonMistakesJson, builder: (column) => column);

  GeneratedColumn<String> get followUpsJson => $composableBuilder(
      column: $table.followUpsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedQuestionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedQuestionsTable,
    CachedQuestion,
    $$CachedQuestionsTableFilterComposer,
    $$CachedQuestionsTableOrderingComposer,
    $$CachedQuestionsTableAnnotationComposer,
    $$CachedQuestionsTableCreateCompanionBuilder,
    $$CachedQuestionsTableUpdateCompanionBuilder,
    (
      CachedQuestion,
      BaseReferences<_$AppDatabase, $CachedQuestionsTable, CachedQuestion>
    ),
    CachedQuestion,
    PrefetchHooks Function()> {
  $$CachedQuestionsTableTableManager(
      _$AppDatabase db, $CachedQuestionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> specializationId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> topicCode = const Value.absent(),
            Value<String> topicTitle = const Value.absent(),
            Value<String?> subtopicCode = const Value.absent(),
            Value<String?> subtopicTitle = const Value.absent(),
            Value<int> minGrade = const Value.absent(),
            Value<int> peakGrade = const Value.absent(),
            Value<int> maxGrade = const Value.absent(),
            Value<int> frequency = const Value.absent(),
            Value<String> optionsJson = const Value.absent(),
            Value<bool> isVerified = const Value.absent(),
            Value<String> answerShort = const Value.absent(),
            Value<String> answerDetailed = const Value.absent(),
            Value<String> commonMistakesJson = const Value.absent(),
            Value<String> followUpsJson = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedQuestionsCompanion(
            id: id,
            specializationId: specializationId,
            type: type,
            title: title,
            topicCode: topicCode,
            topicTitle: topicTitle,
            subtopicCode: subtopicCode,
            subtopicTitle: subtopicTitle,
            minGrade: minGrade,
            peakGrade: peakGrade,
            maxGrade: maxGrade,
            frequency: frequency,
            optionsJson: optionsJson,
            isVerified: isVerified,
            answerShort: answerShort,
            answerDetailed: answerDetailed,
            commonMistakesJson: commonMistakesJson,
            followUpsJson: followUpsJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String specializationId,
            required String type,
            required String title,
            required String topicCode,
            required String topicTitle,
            Value<String?> subtopicCode = const Value.absent(),
            Value<String?> subtopicTitle = const Value.absent(),
            required int minGrade,
            required int peakGrade,
            required int maxGrade,
            required int frequency,
            required String optionsJson,
            required bool isVerified,
            required String answerShort,
            required String answerDetailed,
            required String commonMistakesJson,
            required String followUpsJson,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedQuestionsCompanion.insert(
            id: id,
            specializationId: specializationId,
            type: type,
            title: title,
            topicCode: topicCode,
            topicTitle: topicTitle,
            subtopicCode: subtopicCode,
            subtopicTitle: subtopicTitle,
            minGrade: minGrade,
            peakGrade: peakGrade,
            maxGrade: maxGrade,
            frequency: frequency,
            optionsJson: optionsJson,
            isVerified: isVerified,
            answerShort: answerShort,
            answerDetailed: answerDetailed,
            commonMistakesJson: commonMistakesJson,
            followUpsJson: followUpsJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedQuestionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedQuestionsTable,
    CachedQuestion,
    $$CachedQuestionsTableFilterComposer,
    $$CachedQuestionsTableOrderingComposer,
    $$CachedQuestionsTableAnnotationComposer,
    $$CachedQuestionsTableCreateCompanionBuilder,
    $$CachedQuestionsTableUpdateCompanionBuilder,
    (
      CachedQuestion,
      BaseReferences<_$AppDatabase, $CachedQuestionsTable, CachedQuestion>
    ),
    CachedQuestion,
    PrefetchHooks Function()>;
typedef $$LocalAnswersTableCreateCompanionBuilder = LocalAnswersCompanion
    Function({
  required String submissionId,
  required String questionId,
  required String specializationId,
  Value<String> selectedOptionsJson,
  Value<String?> freeText,
  Value<int?> selfAssessment,
  required double score,
  required int quality,
  required DateTime answeredAt,
  Value<DateTime?> syncedAt,
  Value<int> attempts,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$LocalAnswersTableUpdateCompanionBuilder = LocalAnswersCompanion
    Function({
  Value<String> submissionId,
  Value<String> questionId,
  Value<String> specializationId,
  Value<String> selectedOptionsJson,
  Value<String?> freeText,
  Value<int?> selfAssessment,
  Value<double> score,
  Value<int> quality,
  Value<DateTime> answeredAt,
  Value<DateTime?> syncedAt,
  Value<int> attempts,
  Value<String?> lastError,
  Value<int> rowid,
});

class $$LocalAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAnswersTable> {
  $$LocalAnswersTableFilterComposer({
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

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$LocalAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAnswersTable> {
  $$LocalAnswersTableOrderingComposer({
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

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$LocalAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAnswersTable> {
  $$LocalAnswersTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$LocalAnswersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalAnswersTable,
    LocalAnswer,
    $$LocalAnswersTableFilterComposer,
    $$LocalAnswersTableOrderingComposer,
    $$LocalAnswersTableAnnotationComposer,
    $$LocalAnswersTableCreateCompanionBuilder,
    $$LocalAnswersTableUpdateCompanionBuilder,
    (
      LocalAnswer,
      BaseReferences<_$AppDatabase, $LocalAnswersTable, LocalAnswer>
    ),
    LocalAnswer,
    PrefetchHooks Function()> {
  $$LocalAnswersTableTableManager(_$AppDatabase db, $LocalAnswersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> submissionId = const Value.absent(),
            Value<String> questionId = const Value.absent(),
            Value<String> specializationId = const Value.absent(),
            Value<String> selectedOptionsJson = const Value.absent(),
            Value<String?> freeText = const Value.absent(),
            Value<int?> selfAssessment = const Value.absent(),
            Value<double> score = const Value.absent(),
            Value<int> quality = const Value.absent(),
            Value<DateTime> answeredAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalAnswersCompanion(
            submissionId: submissionId,
            questionId: questionId,
            specializationId: specializationId,
            selectedOptionsJson: selectedOptionsJson,
            freeText: freeText,
            selfAssessment: selfAssessment,
            score: score,
            quality: quality,
            answeredAt: answeredAt,
            syncedAt: syncedAt,
            attempts: attempts,
            lastError: lastError,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String submissionId,
            required String questionId,
            required String specializationId,
            Value<String> selectedOptionsJson = const Value.absent(),
            Value<String?> freeText = const Value.absent(),
            Value<int?> selfAssessment = const Value.absent(),
            required double score,
            required int quality,
            required DateTime answeredAt,
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalAnswersCompanion.insert(
            submissionId: submissionId,
            questionId: questionId,
            specializationId: specializationId,
            selectedOptionsJson: selectedOptionsJson,
            freeText: freeText,
            selfAssessment: selfAssessment,
            score: score,
            quality: quality,
            answeredAt: answeredAt,
            syncedAt: syncedAt,
            attempts: attempts,
            lastError: lastError,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalAnswersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalAnswersTable,
    LocalAnswer,
    $$LocalAnswersTableFilterComposer,
    $$LocalAnswersTableOrderingComposer,
    $$LocalAnswersTableAnnotationComposer,
    $$LocalAnswersTableCreateCompanionBuilder,
    $$LocalAnswersTableUpdateCompanionBuilder,
    (
      LocalAnswer,
      BaseReferences<_$AppDatabase, $LocalAnswersTable, LocalAnswer>
    ),
    LocalAnswer,
    PrefetchHooks Function()>;
typedef $$SyncMetadataTableCreateCompanionBuilder = SyncMetadataCompanion
    Function({
  required String specializationId,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$SyncMetadataTableUpdateCompanionBuilder = SyncMetadataCompanion
    Function({
  Value<String> specializationId,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get specializationId => $composableBuilder(
      column: $table.specializationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get specializationId => $composableBuilder(
      column: $table.specializationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get specializationId => $composableBuilder(
      column: $table.specializationId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$SyncMetadataTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncMetadataTable,
    SyncMetadataData,
    $$SyncMetadataTableFilterComposer,
    $$SyncMetadataTableOrderingComposer,
    $$SyncMetadataTableAnnotationComposer,
    $$SyncMetadataTableCreateCompanionBuilder,
    $$SyncMetadataTableUpdateCompanionBuilder,
    (
      SyncMetadataData,
      BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>
    ),
    SyncMetadataData,
    PrefetchHooks Function()> {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> specializationId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetadataCompanion(
            specializationId: specializationId,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String specializationId,
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetadataCompanion.insert(
            specializationId: specializationId,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncMetadataTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncMetadataTable,
    SyncMetadataData,
    $$SyncMetadataTableFilterComposer,
    $$SyncMetadataTableOrderingComposer,
    $$SyncMetadataTableAnnotationComposer,
    $$SyncMetadataTableCreateCompanionBuilder,
    $$SyncMetadataTableUpdateCompanionBuilder,
    (
      SyncMetadataData,
      BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>
    ),
    SyncMetadataData,
    PrefetchHooks Function()>;
typedef $$CachedProfileTableCreateCompanionBuilder = CachedProfileCompanion
    Function({
  Value<int> id,
  required String payloadJson,
  required DateTime savedAt,
});
typedef $$CachedProfileTableUpdateCompanionBuilder = CachedProfileCompanion
    Function({
  Value<int> id,
  Value<String> payloadJson,
  Value<DateTime> savedAt,
});

class $$CachedProfileTableFilterComposer
    extends Composer<_$AppDatabase, $CachedProfileTable> {
  $$CachedProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
      column: $table.savedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedProfileTable> {
  $$CachedProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
      column: $table.savedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedProfileTable> {
  $$CachedProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$CachedProfileTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedProfileTable,
    CachedProfileData,
    $$CachedProfileTableFilterComposer,
    $$CachedProfileTableOrderingComposer,
    $$CachedProfileTableAnnotationComposer,
    $$CachedProfileTableCreateCompanionBuilder,
    $$CachedProfileTableUpdateCompanionBuilder,
    (
      CachedProfileData,
      BaseReferences<_$AppDatabase, $CachedProfileTable, CachedProfileData>
    ),
    CachedProfileData,
    PrefetchHooks Function()> {
  $$CachedProfileTableTableManager(_$AppDatabase db, $CachedProfileTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> savedAt = const Value.absent(),
          }) =>
              CachedProfileCompanion(
            id: id,
            payloadJson: payloadJson,
            savedAt: savedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String payloadJson,
            required DateTime savedAt,
          }) =>
              CachedProfileCompanion.insert(
            id: id,
            payloadJson: payloadJson,
            savedAt: savedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedProfileTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedProfileTable,
    CachedProfileData,
    $$CachedProfileTableFilterComposer,
    $$CachedProfileTableOrderingComposer,
    $$CachedProfileTableAnnotationComposer,
    $$CachedProfileTableCreateCompanionBuilder,
    $$CachedProfileTableUpdateCompanionBuilder,
    (
      CachedProfileData,
      BaseReferences<_$AppDatabase, $CachedProfileTable, CachedProfileData>
    ),
    CachedProfileData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedQuestionsTableTableManager get cachedQuestions =>
      $$CachedQuestionsTableTableManager(_db, _db.cachedQuestions);
  $$LocalAnswersTableTableManager get localAnswers =>
      $$LocalAnswersTableTableManager(_db, _db.localAnswers);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$CachedProfileTableTableManager get cachedProfile =>
      $$CachedProfileTableTableManager(_db, _db.cachedProfile);
}
