import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/local/app_database.dart';
import '../common/async_button.dart';
import '../providers.dart';

/// Вопросы, услышанные на реальном собеседовании.
///
/// Записывать их нужно сразу, пока помнишь формулировку: через день остаётся
/// «спрашивали что-то про индексы». Всё хранится локально — отправлять некуда,
/// сервера у приложения нет.
class OwnQuestionsScreen extends ConsumerWidget {
  const OwnQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? specialization = ref.watch(sessionProvider).specializationId;
    if (specialization == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Вопросы с собеседований')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, ref, specialization),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Записать'),
      ),
      body: ref.watch(ownQuestionsProvider(specialization)).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace _) => Padding(
              padding: const EdgeInsets.all(20),
              child: Text(error.toString()),
            ),
            data: (List<OwnQuestion> items) => items.isEmpty
                ? const _Empty()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) => _Row(
                      item: items[index],
                      onEdit: () => _openForm(
                        context,
                        ref,
                        specialization,
                        existing: items[index],
                      ),
                      onDelete: () => _delete(context, ref, specialization, items[index]),
                    ),
                  ),
          ),
    );
  }

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref,
    String specialization, {
    OwnQuestion? existing,
  }) async {
    final _FormResult? result = await showModalBottomSheet<_FormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTypography.radiusLarge)),
      ),
      builder: (BuildContext context) => _Form(existing: existing),
    );

    if (result == null) {
      return;
    }

    await ref.read(practiceServiceProvider).saveOwnQuestion(
          OwnQuestionsCompanion(
            // Идентификатор из времени создания: сервера нет, согласовывать
            // ключи не с кем, а сортировка по нему совпадает с хронологией.
            id: Value<String>(
              existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
            ),
            specializationId: Value<String>(specialization),
            title: Value<String>(result.title),
            answer: Value<String?>(result.answer),
            company: Value<String?>(result.company),
            createdAt: Value<DateTime>(existing?.createdAt ?? DateTime.now()),
          ),
        );
    ref.invalidate(ownQuestionsProvider(specialization));
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    String specialization,
    OwnQuestion item,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Удалить вопрос?'),
        content: Text(item.title),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Оставить')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(practiceServiceProvider).deleteOwnQuestion(item.id);
      ref.invalidate(ownQuestionsProvider(specialization));
    }
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.onEdit, required this.onDelete});

  final OwnQuestion item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    final String? answer = item.answer;
    final String? company = item.company;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEdit,
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
            border: Border.all(color: colors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(item.title, style: theme.textTheme.bodyLarge),
              if (answer != null && answer.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  answer,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: colors.inkSecondary),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  if (company != null && company.isNotEmpty) ...<Widget>[
                    Text(
                      company,
                      style: theme.textTheme.labelMedium?.copyWith(color: colors.accent),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    _formatDate(item.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
      child: Column(
        children: <Widget>[
          Icon(Icons.edit_note_rounded, size: 36, color: colors.inkMuted),
          const SizedBox(height: 14),
          Text(
            'Пока пусто',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Сразу после собеседования запишите сюда вопросы, которые задавали. '
            'Через день формулировка забудется, а список останется.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FormResult {
  const _FormResult({required this.title, this.answer, this.company});

  final String title;
  final String? answer;
  final String? company;
}

class _Form extends StatefulWidget {
  const _Form({this.existing});

  final OwnQuestion? existing;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _answer =
      TextEditingController(text: widget.existing?.answer ?? '');
  late final TextEditingController _company =
      TextEditingController(text: widget.existing?.company ?? '');

  bool _titleTouched = false;

  @override
  void dispose() {
    _title.dispose();
    _answer.dispose();
    _company.dispose();
    super.dispose();
  }

  void _submit() {
    final String title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _titleTouched = true);
      return;
    }
    Navigator.pop(
      context,
      _FormResult(
        title: title,
        answer: _answer.text.trim().isEmpty ? null : _answer.text.trim(),
        company: _company.text.trim().isEmpty ? null : _company.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.existing == null ? 'Вопрос с собеседования' : 'Правка вопроса',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _Field(
                controller: _title,
                label: 'Что спросили',
                hint: 'Например: как устроен индекс и когда он не сработает',
                lines: 3,
                autofocus: true,
                error: _titleTouched && _title.text.trim().isEmpty
                    ? 'Без формулировки запись бесполезна'
                    : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _answer,
                label: 'Что ответили или что стоило ответить',
                hint: 'Необязательно',
                lines: 3,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _company,
                label: 'Компания',
                hint: 'Необязательно',
                lines: 1,
              ),
              const SizedBox(height: 20),
              AsyncButton(label: 'Сохранить', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.lines,
    this.autofocus = false,
    this.error,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int lines;
  final bool autofocus;
  final String? error;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return TextField(
      controller: controller,
      autofocus: autofocus,
      minLines: lines,
      maxLines: lines + 3,
      textCapitalization: TextCapitalization.sentences,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: error,
        filled: true,
        fillColor: colors.surfaceRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
          borderSide: BorderSide(color: colors.hairline),
        ),
      ),
    );
  }
}

const List<String> _months = <String>[
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентября',
  'октября',
  'ноября',
  'декабря',
];

String _formatDate(DateTime date) => '${date.day} ${_months[date.month - 1]}';
