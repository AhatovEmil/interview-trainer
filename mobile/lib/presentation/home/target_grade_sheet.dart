import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/grade.dart';
import '../../domain/models/profile.dart';
import '../common/choice_tile.dart';
import '../providers.dart';

/// Смена уровня, к которому человек готовится.
///
/// Это не настройка «для галочки»: от целевого уровня зависит, какие вопросы
/// вообще попадут в выдачу. Поэтому он вынесен на главный экран, а не спрятан
/// в профиль — цель меняется чаще, чем стек.
Future<void> showTargetGradeSheet(BuildContext context, WidgetRef ref) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTypography.radiusLarge)),
      ),
      builder: (BuildContext context) => const _TargetGradeSheet(),
    );

class _TargetGradeSheet extends ConsumerStatefulWidget {
  const _TargetGradeSheet();

  @override
  ConsumerState<_TargetGradeSheet> createState() => _TargetGradeSheetState();
}

class _TargetGradeSheetState extends ConsumerState<_TargetGradeSheet> {
  int? _saving;

  Future<void> _select(int target) async {
    final UserSpecialization? profile = ref.read(sessionProvider).profile;
    if (profile == null) {
      return;
    }
    setState(() => _saving = target);
    try {
      await ref.read(sessionProvider.notifier).completeOnboarding(
            specializationId: profile.specializationId,
            grade: profile.selfAssessedGrade,
            targetGrade: target,
          );
      // Выдача и список вопросов считаются от целевого уровня — после смены
      // они устарели.
      ref.invalidate(questionListProvider(profile.specializationId));
      ref.invalidate(statsProvider(profile.specializationId));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _saving = null);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    final UserSpecialization? profile = ref.watch(sessionProvider).profile;
    final int current = profile?.selfAssessedGrade ?? Grade.min;
    final int target = profile?.targetGrade ?? current;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.hairline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('К какому уровню готовитесь', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Text(
                    'Вопросы подбираются под этот уровень. Менять можно в любую '
                    'сторону: освежить основы перед собеседованием — обычное дело.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: <Widget>[
                  for (final int value in Grade.all)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ChoiceTile(
                        title: Grade.title(value),
                        subtitle: value == current
                            ? 'Освежить то, что уже умею'
                            : (value < current
                                ? 'Ниже текущего — повторить основы'
                                : Grade.hint(value)),
                        selected: value == target,
                        enabled: _saving == null,
                        trailing: _saving == value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : null,
                        onTap: () => _select(value),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
