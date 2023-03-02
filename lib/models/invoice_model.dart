class Invoice {
  final String id;
  final double totalPrice;
  final int dateTime;
  final List<String> productTitles;
  final List<double> productPrices;
  final List<dynamic> productQuantities;
  final int isDeleted;
  final int? tableNumber;


  Invoice({
    required this.id,
    required this.totalPrice,
    required this.dateTime,
    required this.productTitles,
    required this.productPrices,
    required this.productQuantities,
    required this.isDeleted,
    this.tableNumber,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'totalPrice': totalPrice,
      'dateTime': dateTime,
      'productTitles': productTitles.join(','),
      'productPrices': productPrices.join(','),
      'productQuantities': productQuantities.join(','),
      'is_deleted': isDeleted,
      'table_number': tableNumber,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      totalPrice: map['total_price'] ?? 0,
      dateTime: map['datetime'] as int? ?? 0,
      productTitles: (map['product_titles'] as String?)?.split(',') ?? [],
      productPrices: (map['product_prices'] as String?)
              ?.split(',')
              .map((p) => double.parse(p))
              .toList() ??
          [],
      productQuantities: (map['product_quantities'] as String?)
              ?.split(',')
              .map((q) => int.parse(q))
              .toList() ??
          [],
      isDeleted: map['is_deleted'] ?? 0,
      tableNumber: map['table_number'] ?? 0,
    );
  }

  Invoice copyWith({
    String? id,
    double? totalPrice,
    int? dateTime,
    List<String>? productTitles,
    List<double>? productPrices,
    List<int>? productQuantities,
    int? isDeleted,
    int? tableNumber,
  }) {
    return Invoice(
      id: id ?? this.id,
      totalPrice: totalPrice ?? this.totalPrice,
      dateTime: dateTime ?? this.dateTime,
      productTitles: productTitles ?? this.productTitles,
      productPrices: productPrices ?? this.productPrices,
      productQuantities: productQuantities ?? this.productQuantities,
      isDeleted: isDeleted ?? this.isDeleted,
      tableNumber: isDeleted ?? this.isDeleted,
    );
  }
}
