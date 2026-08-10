import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/grade.dart';
import '../../domain/models/question_report.dart';
import '../../domain/models/taxonomy.dart';
import '../common/async_button.dart';
import '../common/section_label.dart';
import '../common/surface_card.dart';
import '../providers.dart';

/// Отправка вопроса, который реально задали на собеседовании (CLAUDE.md §7).
///
/// Экран честно говорит, что вопрос уходит на проверку, а не в банк: иначе
/// пользователь будет искать свою формулировку в списке и решит, что отправка
/// не сработала.
class ReportQuestionScreen extends ConsumerStatefulWidget {
  const ReportQuestionScreen({super.key});

  @override
  ConsumerState<ReportQuestionScreen> createState() => _ReportQuestionScreenState();
}

class _ReportQuestionScreenState extends ConsumerState<ReportQuestionScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _details = TextEditingController();
  final TextEditingController _company = TextEditingController();

  String? _topicCode;
  int? _askedGrade;
  bool _isSending = false;

  /// Та же граница, что и на сервере: короче — уже не вопрос, а обрывок.
  static const int _minTitleLength = 15;

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    _company.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    final String? specialization = ref.watch(sessionProvider).specializationId;
    final List<Topic> topics = _topicsFor(specialization);

    if (specialization == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Вопрос с собеседования')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: <Widget>[
            SurfaceCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.how_to_vote_outlined, size: 18, color: colors.inkMuted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Вопрос попадёт на проверку, а не сразу в банк. Разбор к нему '
                      'напишет человек — так в тренажёре не появляется мусор.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionLabel('Формулировка'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _title,
              maxLines: 4,
              minLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Как задали вопрос — своими словами, но полностью',
              ),
              validator: (String? value) {
                final String text = (value ?? '').trim();
                if (text.length < _minTitleLength) {
                  return 'Слишком коротко: по обрывку вопрос не восстановить';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const SectionLabel('Раздел'),
            const SizedBox(height: 10),
            DropdownButtonFormField<String?>(
              initialValue: _topicCode,
              decoration: const InputDecoration(hintText: 'Не знаю'),
              items: <DropdownMenuItem<String?>>[
                const DropdownMenuItem<String?>(child: Text('Не знаю')),
                for (final Topic topic in topics)
                  DropdownMenuItem<String?>(value: topic.code, child: Text(topic.title)),
              ],
              onChanged: (String? value) => setState(() => _topicCode = value),
            ),
            const SizedBox(height: 24),
            const SectionLabel('Грейд позиции'),
            const SizedBox(height: 10),
            DropdownButtonFormField<int?>(
              initialValue: _askedGrade,
              decoration: const InputDecoration(hintText: 'Не указывать'),
              items: <DropdownMenuItem<int?>>[
                const DropdownMenuItem<int?>(child: Text('Не указывать')),
                for (int grade = Grade.min; grade <= Grade.max; grade++)
                  DropdownMenuItem<int?>(value: grade, child: Text(Grade.title(grade))),
              ],
              onChanged: (int? value) => setState(() => _askedGrade = value),
            ),
            const SizedBox(height: 24),
            const SectionLabel('Компания'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _company,
              decoration: const InputDecoration(hintText: 'Необязательно'),
            ),
            const SizedBox(height: 24),
            const SectionLabel('Что уточняли дальше'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _details,
              maxLines: 5,
              minLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Необязательно: чего ждали в ответе, что спросили следом',
              ),
            ),
            const SizedBox(height: 28),
            AsyncButton(
              label: 'Отправить',
              isLoading: _isSending,
              onPressed: () => _submit(specialization),
            ),
          ],
        ),
      ),
    );
  }

  List<Topic> _topicsFor(String? specializationId) {
    if (specializationId == null) {
      return const <Topic>[];
    }
    final Taxonomy? taxonomy = ref.watch(taxonomyProvider).valueOrNull;
    if (taxonomy == null) {
      return const <Topic>[];
    }
    for (final Profession profession in taxonomy.professions) {
      for (final Specialization specialization in profession.specializations) {
        if (specialization.id == specializationId) {
          return specialization.topics;
        }
      }
    }
    return const <Topic>[];
  }

  Future<void> _submit(String specialization) async {
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isSending = true);
    try {
      final QuestionReportResult result =
          await ref.read(practiceRepositoryProvider).reportQuestion(
                specializationId: specialization,
                title: _title.text.trim(),
                topicCode: _topicCode,
                details: _details.text.trim(),
                company: _company.text.trim(),
                askedGrade: _askedGrade,
              );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              result.isDuplicate
                  ? 'Такой вопрос вы уже присылали — он в очереди'
                  : 'Спасибо, вопрос ушёл на проверку',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } on ApiException catch (error) {
      if (mounted) {
        showError(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }
}
