/// Грейд — целое 0–6. Числовая шкала обязательна: по ней считается выдача.
class Grade {
  const Grade._();

  static const int intern = 0;
  static const int junior = 1;
  static const int juniorPlus = 2;
  static const int middle = 3;
  static const int middlePlus = 4;
  static const int senior = 5;
  static const int lead = 6;

  static const int min = intern;
  static const int max = lead;

  static const Map<int, String> titles = {
    intern: 'Стажёр',
    junior: 'Junior',
    juniorPlus: 'Junior+',
    middle: 'Middle',
    middlePlus: 'Middle+',
    senior: 'Senior',
    lead: 'Lead / Staff',
  };

  static const Map<int, String> hints = {
    intern: 'Пишу код под присмотром',
    junior: 'Закрываю простые задачи сам',
    juniorPlus: 'Уверенно работаю в рамках задачи',
    middle: 'Веду фичу от постановки до релиза',
    middlePlus: 'Проектирую сервисы, помогаю другим',
    senior: 'Отвечаю за архитектуру и решения',
    lead: 'Отвечаю за команду и направление',
  };

  static String title(int grade) => titles[grade] ?? 'Грейд $grade';

  static String hint(int grade) => hints[grade] ?? '';

  static List<int> get all => List<int>.generate(max + 1, (int index) => index);
}
