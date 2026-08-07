import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/grade.dart';
import '../../domain/models/taxonomy.dart';
import '../common/async_button.dart';
import '../providers.dart';

/// Онбординг в три шага: профессия → специализация → грейд.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  Profession? _profession;
  Specialization? _specialization;
  int _grade = Grade.middle;
  bool _isSaving = false;

  Future<void> _finish() async {
    final Specialization? specialization = _specialization;
    if (specialization == null) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ref.read(sessionProvider.notifier).completeOnboarding(
            specializationId: specialization.id,
            grade: _grade,
          );
    } on Object catch (error) {
      if (mounted) {
        showError(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _back() {
    if (_step == 0) {
      return;
    }
    setState(() => _step -= 1);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Taxonomy> taxonomy = ref.watch(taxonomyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForStep()),
        leading: _step == 0
            ? null
            : IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_step + 1) / 3, minHeight: 4),
        ),
      ),
      body: taxonomy.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => _ErrorState(
          error: error,
          onRetry: () => ref.invalidate(taxonomyProvider),
        ),
        data: (Taxonomy data) => SafeArea(child: _buildStep(data)),
      ),
    );
  }

  String _titleForStep() => switch (_step) {
        0 => 'Кем вы работаете',
        1 => 'Ваш стек',
        _ => 'Ваш уровень',
      };

  Widget _buildStep(Taxonomy taxonomy) {
    switch (_step) {
      case 0:
        return _ProfessionStep(
          professions: taxonomy.professions,
          selected: _profession,
          onSelected: (Profession profession) => setState(() {
            _profession = profession;
            _specialization = null;
            _step = 1;
          }),
        );
      case 1:
        return _SpecializationStep(
          profession: _profession!,
          selected: _specialization,
          onSelected: (Specialization specialization) => setState(() {
            _specialization = specialization;
            _step = 2;
          }),
        );
      default:
        return _GradeStep(
          grade: _grade,
          isSaving: _isSaving,
          specialization: _specialization!,
          onChanged: (int grade) => setState(() => _grade = grade),
          onSubmit: _finish,
        );
    }
  }
}

class _ProfessionStep extends StatelessWidget {
  const _ProfessionStep({
    required this.professions,
    required this.selected,
    required this.onSelected,
  });

  final List<Profession> professions;
  final Profession? selected;
  final ValueChanged<Profession> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: professions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final Profession profession = professions[index];
        final bool available = profession.hasActive;
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            title: Text(profession.title),
            subtitle: Text('${profession.specializations.length} направлени(й)'),
            trailing: available
                ? const Icon(Icons.chevron_right)
                : const _SoonBadge(),
            onTap: () => onSelected(profession),
          ),
        );
      },
    );
  }
}

class _SpecializationStep extends StatelessWidget {
  const _SpecializationStep({
    required this.profession,
    required this.selected,
    required this.onSelected,
  });

  final Profession profession;
  final Specialization? selected;
  final ValueChanged<Specialization> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: profession.specializations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final Specialization specialization = profession.specializations[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            title: Text(specialization.title),
            subtitle: specialization.isActive
                ? Text('${specialization.topics.length} разделов вопросов')
                : const Text('Готовим банк вопросов'),
            trailing: specialization.isActive
                ? const Icon(Icons.chevron_right)
                : const _SoonBadge(),
            enabled: specialization.isActive,
            onTap: specialization.isActive ? () => onSelected(specialization) : null,
          ),
        );
      },
    );
  }
}

class _GradeStep extends StatelessWidget {
  const _GradeStep({
    required this.grade,
    required this.isSaving,
    required this.specialization,
    required this.onChanged,
    required this.onSubmit,
  });

  final int grade;
  final bool isSaving;
  final Specialization specialization;
  final ValueChanged<int> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Это стартовая точка, а не приговор: после 20 ответов приложение измерит '
            'уровень само и подстроит выдачу.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: Grade.all.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (BuildContext context, int index) {
              final int value = Grade.all[index];
              final bool isSelected = value == grade;
              return Card(
                color: isSelected ? theme.colorScheme.primaryContainer : null,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(Grade.title(value)),
                  subtitle: Text(Grade.hint(value)),
                  trailing: isSelected ? const Icon(Icons.check_circle) : null,
                  onTap: () => onChanged(value),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: AsyncButton(
            label: 'Начать тренировку',
            isLoading: isSaving,
            onPressed: onSubmit,
          ),
        ),
      ],
    );
  }
}

class _SoonBadge extends StatelessWidget {
  const _SoonBadge();

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: const Text('скоро'),
      visualDensity: VisualDensity.compact,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}
