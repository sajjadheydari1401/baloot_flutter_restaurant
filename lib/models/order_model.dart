class Order {
  final String title;
  final double fee;
  int? qty;
  late double totalFee;

  Order({
    double totalFee = 0.0,
    required this.fee,
    required this.qty,
    required this.title,
  }) : totalFee = totalFee;

  void updateTotalFee() {
    totalFee = fee * qty!;
  }
}
