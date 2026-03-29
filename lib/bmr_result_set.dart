class BmrResultSet {
  const BmrResultSet({
    required this.basal,
    required this.level15,
    required this.level175,
    required this.level20,
  });

  final int basal;
  final int level15;
  final int level175;
  final int level20;

  static const BmrResultSet zero = BmrResultSet(
    basal: 0,
    level15: 0,
    level175: 0,
    level20: 0,
  );
}
