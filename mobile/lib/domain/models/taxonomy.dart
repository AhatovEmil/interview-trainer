/// Дерево профессий и тем, как его отдаёт GET /api/v1/taxonomy.
class Taxonomy {
  const Taxonomy({required this.professions, required this.grades});

  final List<Profession> professions;
  final List<GradeOption> grades;

  factory Taxonomy.fromJson(Map<String, dynamic> json) => Taxonomy(
        professions: (json['professions'] as List<dynamic>)
            .map((dynamic item) => Profession.fromJson(item as Map<String, dynamic>))
            .toList(),
        grades: (json['grades'] as List<dynamic>)
            .map((dynamic item) => GradeOption.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  /// Специализации, доступные в MVP. Остальные показываются как «скоро».
  List<Specialization> get activeSpecializations => professions
      .expand((Profession profession) => profession.specializations)
      .where((Specialization specialization) => specialization.isActive)
      .toList();
}

class Profession {
  const Profession({
    required this.id,
    required this.title,
    required this.specializations,
  });

  final String id;
  final String title;
  final List<Specialization> specializations;

  factory Profession.fromJson(Map<String, dynamic> json) => Profession(
        id: json['id'] as String,
        title: json['title'] as String,
        specializations: (json['specializations'] as List<dynamic>)
            .map((dynamic item) => Specialization.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  bool get hasActive =>
      specializations.any((Specialization specialization) => specialization.isActive);
}

class Specialization {
  const Specialization({
    required this.id,
    required this.title,
    required this.isActive,
    required this.topics,
  });

  final String id;
  final String title;
  final bool isActive;
  final List<Topic> topics;

  factory Specialization.fromJson(Map<String, dynamic> json) => Specialization(
        id: json['id'] as String,
        title: json['title'] as String,
        isActive: json['is_active'] as bool,
        topics: (json['topics'] as List<dynamic>)
            .map((dynamic item) => Topic.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class Topic {
  const Topic({required this.code, required this.title, required this.subtopics});

  final String code;
  final String title;
  final List<Subtopic> subtopics;

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        code: json['code'] as String,
        title: json['title'] as String,
        subtopics: (json['subtopics'] as List<dynamic>)
            .map((dynamic item) => Subtopic.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class Subtopic {
  const Subtopic({required this.code, required this.title});

  final String code;
  final String title;

  factory Subtopic.fromJson(Map<String, dynamic> json) => Subtopic(
        code: json['code'] as String,
        title: json['title'] as String,
      );
}

class GradeOption {
  const GradeOption({required this.value, required this.code, required this.title});

  final int value;
  final String code;
  final String title;

  factory GradeOption.fromJson(Map<String, dynamic> json) => GradeOption(
        value: json['value'] as int,
        code: json['code'] as String,
        title: json['title'] as String,
      );
}
