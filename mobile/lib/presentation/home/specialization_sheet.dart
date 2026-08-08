import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/taxonomy.dart';
import '../common/choice_tile.dart';
import '../providers.dart';

/// Смена специализации.
///
/// Прогресс хранится по каждой отдельно, поэтому переключение ничего не теряет:
/// вернувшись, человек застаёт свои рейтинги и пройденные вопросы на месте.
Future<void> showSpecializationSheet(BuildContext context, WidgetRef ref) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTypography.radiusLarge)),
      ),
      builder: (BuildContext context) => const _SpecializationSheet(),
    );

class _SpecializationSheet extends ConsumerStatefulWidget {
  const _SpecializationSheet();

  @override
  ConsumerState<_SpecializationSheet> createState() => _SpecializationSheetState();
}

class _SpecializationSheetState extends ConsumerState<_SpecializationSheet> {
  String? _switching;

  Future<void> _select(Specialization specialization, int grade) async {
    setState(() => _switching = specialization.id);
    try {
      await ref.read(sessionProvider.notifier).completeOnboarding(
            specializationId: specialization.id,
            grade: grade,
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _switching = null);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    final SessionState session = ref.watch(sessionProvider);
    final String? current = session.specializationId;
    final int grade = session.profile?.primary?.selfAssessedGrade ?? 3;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
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
                  Text('Специализация', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Text(
                    'Прогресс по каждой хранится отдельно — переключение ничего не теряет.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Flexible(
              child: ref.watch(taxonomyProvider).when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (Object error, StackTrace _) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(error.toString(), style: theme.textTheme.bodyMedium),
                    ),
                    data: (Taxonomy taxonomy) => _List(
                      taxonomy: taxonomy,
                      current: current,
                      switching: _switching,
                      onSelected: (Specialization specialization) =>
                          _select(specialization, grade),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.taxonomy,
    required this.current,
    required this.switching,
    required this.onSelected,
  });

  final Taxonomy taxonomy;
  final String? current;
  final String? switching;
  final ValueChanged<Specialization> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      children: <Widget>[
        for (final Profession profession in taxonomy.professions) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Text(
              profession.title,
              style: theme.textTheme.labelSmall?.copyWith(color: context.colors.inkMuted),
            ),
          ),
          for (final Specialization specialization in profession.specializations)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ChoiceTile(
                title: specialization.title,
                subtitle: specialization.isActive
                    ? null
                    : 'Банк вопросов ещё готовится',
                selected: specialization.id == current,
                enabled: specialization.isActive && switching == null,
                trailing: switching == specialization.id
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : (specialization.isActive ? null : const SoonBadge()),
                onTap: () => onSelected(specialization),
              ),
            ),
        ],
      ],
    );
  }
}
