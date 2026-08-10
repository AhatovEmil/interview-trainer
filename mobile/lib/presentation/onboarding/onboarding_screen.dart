import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/plural.dart';
import '../../domain/models/grade.dart';
import '../../domain/models/taxonomy.dart';
import '../common/async_button.dart';
import '../common/choice_tile.dart';
import '../common/section_label.dart';
import '../providers.dart';

/// Единственный вопрос при первом запуске — стек.
///
/// Раньше здесь было четыре шага: профессия, стек, текущий уровень и целевой.
/// Три из них лишние. Стек приложение угадать не может — без него неизвестно,
/// какие вопросы показывать. Уровень может: он выставляется одной кнопкой на
/// главном экране и всё равно измеряется по ответам. Спрашивать на старте то,
/// что человек ещё не готов решать, значит ставить анкету между ним и первым
/// вопросом.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String? _saving;

  Future<void> _choose(Specialization specialization) async {
    setState(() => _saving = specialization.id);
    try {
      await ref.read(sessionProvider.notifier).completeOnboarding(
            specializationId: specialization.id,
            // Уровень по умолчанию — середина шкалы. Это не утверждение о
            // человеке, а точка отсчёта: банк на middle самый полный, а
            // сменить уровень можно с главного экрана в два касания.
            targetGrade: Grade.middle,
          );
    } on Object catch (error) {
      if (mounted) {
        setState(() => _saving = null);
        showError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Таксономия лежит в ресурсах приложения: ждать нечего и падать нечему.
    final Taxonomy taxonomy = ref.watch(taxonomyProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ваш стек')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: <Widget>[
            Text(
              'С чем вы работаете. Уровень выберете на главном экране — '
              'и сможете менять его когда угодно.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            for (final Profession profession in taxonomy.professions) ...<Widget>[
              SectionLabel(profession.title),
              const SizedBox(height: 10),
              for (final Specialization specialization in profession.specializations)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SpecializationTile(
                    specialization: specialization,
                    isSaving: _saving == specialization.id,
                    enabled: _saving == null,
                    onTap: () => _choose(specialization),
                  ),
                ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpecializationTile extends StatelessWidget {
  const _SpecializationTile({
    required this.specialization,
    required this.isSaving,
    required this.enabled,
    required this.onTap,
  });

  final Specialization specialization;
  final bool isSaving;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool available = specialization.isActive;

    return ChoiceTile(
      title: specialization.title,
      subtitle: available
          ? withPlural(
              specialization.topics.length,
              'раздел вопросов',
              'раздела вопросов',
              'разделов вопросов',
            )
          : 'Готовим банк вопросов',
      enabled: available && enabled,
      trailing: switch ((isSaving, available)) {
        (true, _) => const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        (_, false) => const SoonBadge(),
        _ => null,
      },
      onTap: onTap,
    );
  }
}
