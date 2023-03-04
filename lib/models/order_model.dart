class Order {
  final String title;
  final double fee;
  String qty;
  late double totalFee;

  Order({
    this.totalFee = 0.0,
    required this.fee,
    required this.qty,
    required this.title,
  });

  void updateTotalFee() {
    totalFee = fee * int.parse(qty);
  }
}
