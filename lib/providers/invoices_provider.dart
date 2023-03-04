import 'package:mousavi/models/invoice_model.dart';
import 'package:flutter/foundation.dart';

import '../helpers/db_helper.dart';

class Invoices with ChangeNotifier {
  List<Invoice> _items = [];

  List<Invoice> get items {
    return [..._items];
  }

  Invoice findById(String id) {
    return _items.firstWhere((invoice) => invoice.id == id);
  }

  Future<void> addInvoice(
    String id,
    List<String> productTitles,
    List<double> productPrices,
    List<int?> productQuantities,
    double totalInvoicePrice,
    int? tableNumber,
  ) async {
    final newInvoice = Invoice(
      id: id,
      totalPrice: totalInvoicePrice,
      dateTime: DateTime.now().millisecondsSinceEpoch,
      productTitles: productTitles,
      productPrices: productPrices,
      productQuantities: productQuantities,
      tableNumber: tableNumber ?? 0,
    );
    _items.add(newInvoice);
    notifyListeners();

    await DBHelper.insertInvoice(
      id,
      newInvoice.totalPrice,
      newInvoice.dateTime,
      productTitles,
      productPrices,
      productQuantities,
      tableNumber ?? 0,
    );
  }

  Future<void> fetchAndSetInvoices() async {
    try {
      final dataList = await DBHelper.getData('invoices');
      final List<Invoice> loadedInvoices = await loadedInvoicesFuture(dataList);
      _items = loadedInvoices;
      notifyListeners();
    } catch (error) {
      print('Error fetching invoices: $error');
    }
  }
}

Future<List<Invoice>> loadedInvoicesFuture(
    List<Map<String, dynamic>> maps) async {
  final List<Invoice> loadedInvoices = List.generate(maps.length, (i) {
    final invoice = Invoice.fromMap(maps[i]);
    return invoice;
  });

  return loadedInvoices;
}
