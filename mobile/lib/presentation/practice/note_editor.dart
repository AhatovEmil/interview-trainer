import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../common/section_label.dart';
import '../providers.dart';

/// Заметка к вопросу.
///
/// Разбор объясняет, как правильно; заметка — что человек хочет запомнить
/// именно про себя: что забыл сказать, как формулировать в следующий раз.
/// Поэтому она живёт рядом с разбором, а не в отдельном разделе.
class NoteSection extends ConsumerWidget {
  const NoteSection({required this.questionId, super.key});

  final String questionId;

  Future<void> _edit(BuildContext context, WidgetRef ref, String current) async {
    final String? saved = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTypography.radiusLarge)),
      ),
      builder: (BuildContext context) => _NoteSheet(initial: current),
    );

    if (saved == null) {
      return;
    }
    await ref.read(practiceServiceProvider).saveNote(questionId: questionId, body: saved);
    ref.invalidate(noteProvider(questionId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    final String note = ref.watch(noteProvider(questionId)).valueOrNull ?? '';
    final bool isEmpty = note.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SectionLabel('Моя заметка'),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _edit(context, ref, note),
            borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isEmpty ? Colors.transparent : colors.surface,
                borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
                border: Border.all(color: colors.hairline),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    isEmpty ? Icons.edit_note_rounded : Icons.sticky_note_2_outlined,
                    size: 20,
                    color: colors.inkMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEmpty ? 'Записать, что забыли сказать' : note,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isEmpty ? colors.inkMuted : colors.inkPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteSheet extends StatefulWidget {
  const _NoteSheet({required this.initial});

  final String initial;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Заметка к вопросу', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Что забыли сказать, с чего начать ответ в следующий раз, куда посмотреть.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                autofocus: true,
                maxLines: 6,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Например: не упомянул про индексы по частичному совпадению',
                  filled: true,
                  fillColor: colors.surfaceRaised,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
                    borderSide: BorderSide(color: colors.hairline),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  if (widget.initial.isNotEmpty)
                    TextButton(
                      onPressed: () => Navigator.pop(context, ''),
                      child: const Text('Удалить'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, _controller.text),
                    child: const Text('Сохранить'),
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
