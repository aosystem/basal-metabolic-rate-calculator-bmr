import 'package:basalmetabolism/bmr_result_set.dart';

class BmrCalculator {
  static BmrResultSet calculateSetA({
    required int height,
    required int weight,
    required int age,
    required int gender,
  }) {
    final double rawBase = (gender == 1)
        ? 66.4730 + (13.7516 * weight) + (5.0033 * height) - (6.7550 * age)
        : 655.0955 + (9.5634 * weight) + (1.8496 * height) - (4.6756 * age);
    final int base = rawBase.toInt();
    final int level15 = (base * 1.5).toInt();
    final int level175 = (base * 1.75).toInt();
    final int level20 = (base * 2).toInt();
    return BmrResultSet(
      basal: base,
      level15: level15,
      level175: level175,
      level20: level20,
    );
  }

  static BmrResultSet calculateSetB({
    required int height,
    required int weight,
    required int age,
    required int gender,
  }) {
    final double baseTerm =
        0.1238 + (0.0481 * weight) + (0.0234 * height) - (0.0138 * age);
    final double rawBase = (gender == 1)
        ? ((baseTerm - 0.5473) * 1000) / 4.186
        : ((baseTerm - (0.5473 * 2)) * 1000) / 4.186;
    final int base = rawBase.toInt();
    final int level15 = (base * 1.5).toInt();
    final int level175 = (base * 1.75).toInt();
    final int level20 = (base * 2).toInt();
    return BmrResultSet(
      basal: base,
      level15: level15,
      level175: level175,
      level20: level20,
    );
  }
}
