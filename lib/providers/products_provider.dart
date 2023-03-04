import 'package:uuid/uuid.dart';
import '../models/product_model.dart';
import 'package:flutter/foundation.dart';
import '../helpers/db_helper.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> addProduct(
    String productTitle,
    double productPrice,
  ) async {
    final newProduct = Product(
      id: const Uuid().v4(),
      title: productTitle,
      price: productPrice,
    );
    _items.add(newProduct);
    notifyListeners();
    await DBHelper.insert('products', {
      'id': newProduct.id,
      'title': newProduct.title,
      'price': newProduct.price,
    });
  }

  Future<void> removeProduct(String productId) async {
    final productIndex =
        _items.indexWhere((product) => product.id == productId);
    if (productIndex >= 0) {
      _items.removeAt(productIndex);
      notifyListeners();
      await DBHelper.deleteProduct(productId);
    }
  }

  Future<void> fetchAndSetProducts() async {
    try {
      final dataList = await DBHelper.getData('products');
      if (dataList != null) {
        _items = dataList
            .map(
              (item) => Product(
                id: item['id'],
                title: item['title'],
                price: item['price'],
              ),
            )
            .toList();
        notifyListeners();
      }
    } catch (error) {
      print('Error fetching products: $error');
    }
  }
}
