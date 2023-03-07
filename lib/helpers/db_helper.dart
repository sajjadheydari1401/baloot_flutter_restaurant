import 'package:mousavi/models/models.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'myapp.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE products(id TEXT PRIMARY KEY, title TEXT, price REAL)',
        );
        await db.execute(
          'CREATE TABLE profiles(title TEXT NOT NULL DEFAULT عنوان, address TEXT NOT NULL DEFAULT آدرس, phone TEXT NOT NULL DEFAULT تلفن)',
        );
        await db.execute(
            ' CREATE TABLE invoices( id TEXT PRIMARY KEY, total_price REAL NOT NULL, datetime INTEGER NOT NULL, product_titles TEXT NOT NULL, product_prices TEXT NOT NULL, product_quantities TEXT NOT NULL, table_number INTEGER NOT NULL DEFAULT 0)');
      },
      version: 1,
    );
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateProfile(
      String title, String address, String phone) async {
    final db = await database();
    await db.update(
      'profiles',
      {
        'title': title,
        'address': address,
        'phone': phone,
      },
    );
  }

  static Future<void> insertInvoice(
    String id,
    double totalPrice,
    int dateTime,
    List<String> productTitles,
    List<double> productPrices,
    List<String> productQuantities,
    int tableNumber,
  ) async {
    final db = await DBHelper.database();
    final productTitlesString = productTitles.join(',');
    final productPricesString =
        productPrices.map((p) => p.toString()).join(',');
    final productQuantitiesString =
        productQuantities.map((q) => q.toString()).join(',');

    final data = {
      'id': id,
      'total_price': totalPrice,
      'datetime': dateTime,
      'product_titles': productTitlesString,
      'product_prices': productPricesString,
      'product_quantities': productQuantitiesString,
      'table_number': tableNumber,
    };

    await db.insert(
      'invoices',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteProduct(String productId) async {
    final db = await DBHelper.database();
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  static Future<void> deleteInvoice(String invoiceId) async {
    final db = await DBHelper.database();
    await db.delete(
      'invoices',
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
  }

  static Future<List<Map<String, dynamic>>> getData(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    final db = await DBHelper.database();
    return db.query(table, where: where, whereArgs: whereArgs);
  }
}
